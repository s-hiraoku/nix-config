{ pkgs, ... }:

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
  # tmux との併用可能: 手動で `tmux` / `herdr` を使い分ける。

  # 設定ファイルは ~/.config/herdr/config.toml。
  # 内容は modules/herdr/config.toml で管理し、home-manager が symlink を張る。
  xdg.configFile."herdr/config.toml".source = ./herdr/config.toml;
}
