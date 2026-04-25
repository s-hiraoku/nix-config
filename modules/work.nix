{ config, lib, pkgs, ... }:

let
  # 会社ネットワーク (Cato Networks) の TLS インスペクション向け Root CA。
  catoRootCA = "${config.home.homeDirectory}/certs/CatoNetworksTrustedRootCA.pem";

  # nixpkgs が提供する Mozilla CA bundle。
  # システムファイル (/etc/ssl/nix-certs.pem) に依存せず、flake.lock で
  # バージョン固定されているので完全に再現可能。
  nixCA = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

  # 上記 CA bundle + Cato Root CA を連結したファイル。
  # /tmp は再起動で消えるので、永続 path を使う。
  # home-manager の activation で毎回再生成されるため、ライブラリ更新
  # (nix flake update) や再起動を跨いでも drift しない。
  combinedCA = "${config.home.homeDirectory}/.local/share/nix-config/ca-bundle.pem";

  # openapi-generator-cli などの Java ツール用 JDK。
  # LTS (Java 17) を採用。openapi-generator-cli v7.x は Java 11 以上を要求。
  jdk = pkgs.jdk17;
in
{
  home.packages = [ jdk ];

  home.sessionVariables = {
    # .home は platform ごとの正しい JAVA_HOME path を返す
    JAVA_HOME = jdk.home;

    # lazygit の AI コミットメッセージ生成プロンプト (日本語版)。
    # common 側のデフォルト (英語) を会社 PC では日本語に差し替える。
    LAZYGIT_COMMIT_PROMPT = "ステージ済みの diff を読んで、Conventional Commits 形式 `type(scope): description` で 1 行の日本語コミットメッセージを出力してください。type は feat, fix, docs, style, refactor, test, chore のいずれかのみ。マークダウンや余計な説明は不要。メッセージ本文のみを返してください。";
  };

  # Node.js は OS のトラストストアを見ないため Cato Root CA を個別に注入する。
  # flake の pure evaluation 中は host filesystem を見られず builtins.pathExists が
  # 常に false になりうるので、存在判定は zsh 起動時に行う。
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -r "${catoRootCA}" ]]; then
      export NODE_EXTRA_CA_CERTS="${catoRootCA}"
    else
      unset NODE_EXTRA_CA_CERTS
    fi
  '';

  # activation 時に pkgs.cacert の bundle と Cato cert を連結して永続化する。
  # - Cato cert がある場合: combined bundle (Cato cert 込み)
  # - Cato cert がない場合: pkgs.cacert のみコピー (Cato 無し環境フォールバック)
  # どちらでも combinedCA が必ず存在するので nix.conf の ssl-cert-file が壊れない。
  # pkgs.cacert は nix store 内のファイルなので必ず読める。
  home.activation.buildCombinedCA = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$(dirname "${combinedCA}")"
    if [ -f "${catoRootCA}" ]; then
      run sh -c 'cat "${nixCA}" "${catoRootCA}" > "${combinedCA}"'
    else
      run cp "${nixCA}" "${combinedCA}"
      echo "warning(work.nix): Cato cert not found at ${catoRootCA}, using pkgs.cacert only" >&2
    fi
  '';

  # nix client の ssl-cert-file を永続の combined bundle に向ける。
  # common.nix の nix.conf を上書きする。
  xdg.configFile."nix/nix.conf".text = lib.mkForce ''
    experimental-features = nix-command flakes
    ssl-cert-file = ${combinedCA}
  '';

  programs.git.settings = {
    user.email = "hiraoku.shinichi@synergy101.jp";
    ghq.root = "${config.home.homeDirectory}/ghq";
  };
}
