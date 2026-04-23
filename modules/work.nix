{ config, lib, pkgs, ... }:

let
  # 暫定対応: 会社ネットワーク (Cato Networks) の TLS インスペクション向けに
  # Node.js へ Root CA を信頼させる。Node.js は OS のトラストストアを見ないため。
  # flake の pure evaluation 中は host filesystem を見られず builtins.pathExists が
  # 常に false になりうるため、存在判定は zsh 起動時に行う。
  # TODO: 社内ネットワーク側で証明書配布が整理されたら削除。
  catoRootCA = "${config.home.homeDirectory}/certs/CatoNetworksTrustedRootCA.pem";

  # openapi-generator-cli などの Java ツール用 JDK。
  # LTS (Java 17) を採用。openapi-generator-cli v7.x は Java 11 以上を要求。
  jdk = pkgs.jdk17;
in
{
  home.packages = [ jdk ];

  home.sessionVariables = {
    # .home は platform ごとの正しい JAVA_HOME path を返す
    # (macOS: zulu-17.jdk/Contents/Home / Linux: lib/openjdk)
    JAVA_HOME = jdk.home;
  };

  programs.zsh.initContent = lib.mkAfter ''
    if [[ -r "${catoRootCA}" ]]; then
      export NODE_EXTRA_CA_CERTS="${catoRootCA}"
    else
      unset NODE_EXTRA_CA_CERTS
    fi
  '';

  programs.git.settings = {
    user.email = "hiraoku.shinichi@synergy101.jp";
    ghq.root = "${config.home.homeDirectory}/ghq";
  };
}
