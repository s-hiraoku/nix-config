{ config, lib, pkgs, ... }:

let
  # 暫定対応: 会社ネットワーク (Cato Networks) の TLS インスペクション向けに
  # Node.js へ Root CA を信頼させる。Node.js は OS のトラストストアを見ないため。
  # 証明書が未配置の環境 (新規 PC セットアップ中など) でも switch が壊れないよう、
  # ファイルが実在する場合のみ環境変数を設定する。
  # TODO: 社内ネットワーク側で証明書配布が整理されたら削除。
  catoRootCA = "${config.home.homeDirectory}/certs/CatoNetworksTrustedRootCA.pem";
in
{
  home.sessionVariables = lib.optionalAttrs (builtins.pathExists catoRootCA) {
    NODE_EXTRA_CA_CERTS = catoRootCA;
  };

  programs.git.settings = {
    user.email = "hiraoku.shinichi@synergy101.jp";
    ghq.root = "${config.home.homeDirectory}/ghq";
  };
}
