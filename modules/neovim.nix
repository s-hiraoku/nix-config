{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Neovim 設定一式 (旧 dotfiles の自作フルスクラッチ構成) を modules/nvim/ で管理する。
  # recursive = true により各ファイルを個別 symlink で配置し、~/.config/nvim 自体は
  # 実ディレクトリのままにする。これで lazy.nvim が lazy-lock.json を書き込める。
  # プラグイン本体は lazy.nvim がランタイム管理 (nix では宣言しない)。
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  # init.lua の vim.loader.enable() は Lua バイトコードを mtime+サイズで
  # キャッシュするが、nix ストアのファイルは mtime が常に固定 (1970) のため、
  # 設定を更新しても同サイズだと古いキャッシュが居座り変更が反映されない。
  # switch のたびに loader キャッシュを破棄して必ず新しい設定を読ませる。
  home.activation.clearNvimLoaderCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run rm -rf "${config.xdg.cacheHome}/nvim/luac"
  '';
}
