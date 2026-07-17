{ pkgs, config, ... }:

{
  # prefix+s のワークスペース切替バインドが workspace list (JSON) の整形に jq を使う。
  home.packages = [ pkgs.jq ];

  # herdr: AI エージェント向けターミナルマルチプレクサ。
  #
  # 本体は Homebrew で導入する (`brew install herdr`)。
  # nixpkgs にも herdr はあるが、Darwin ではソースビルドに失敗する
  # (vendored libghostty-vt の zig ビルドが Apple SDK を見つけられず
  #  DarwinSdkNotFound。nixpkgs の apple-sdk には zig が要求する
  #  SDKSettings.json 形式の Xcode SDK レイアウトが無い。
  #  upstream issue: ogulcancelik/herdr#285)。
  # aarch64-darwin のバイナリキャッシュも無いため、本体は Nix 管理にできない。
  # → 設定 (config.toml) のみここで宣言管理する。upstream / nixpkgs が
  #   Darwin ビルドを直したら flake.nix に overlay を足して本体も Nix へ移行する。
  #
  # 起動は自動化せず、Ghostty のプレーン shell から手動で `herdr` する
  # (Ghostty の自動起動を廃止した経緯は modules/zsh/early-init.sh を参照)。

  # 設定ファイルは ~/.config/herdr/config.toml。
  # 実体は herdr-toolkit repo (https://github.com/s-hiraoku/herdr-toolkit) の
  # config/config.toml で管理し、ここでは mkOutOfStoreSymlink で作業コピーへの
  # リンクだけを宣言する。
  # - その場で編集して herdr の prefix+r で即リロードできる(nix store は読み取り専用のため)
  # - 履歴・キーバインドの試行錯誤は herdr-toolkit 側に残る
  # - 新マシンは ghq get s-hiraoku/herdr-toolkit + home-manager switch で再現
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/ghq/github.com/s-hiraoku/herdr-toolkit/config/config.toml";
}
