{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # nvim のラッパー PATH に追加するツール。treesitter の `:TSUpdate` /
    # auto_install と telescope-fzf-native の `make` はランタイムに C を
    # コンパイルするため、宣言的にコンパイラ・make を供給する
    # (Xcode CLT の有無に依存しないようにする)。tree-sitter CLI も足しておく。
    extraPackages = with pkgs; [
      stdenv.cc # cc / c++ (darwin では clang) を提供
      gnumake
      tree-sitter
    ];
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

  # native spell のユーザー辞書 (zg/zw が追記する) は書き込み可能な場所に
  # 置く必要がある。nix ストアの symlink は読み取り専用のため、そこを
  # spellfile にすると追記が E509 で失敗する (options.lua は書き込み可能な
  # ~/.local/share/nvim/spell を spellfile に指定している)。
  # リポジトリ内のシード (modules/nvim/dic/custom.utf-8.add) を初回のみ
  # そこへコピーする。以後の追記はこの可変ファイルに入るので、リポジトリへ
  # 反映したい単語は手動でシードへコピーし直す。
  home.activation.seedNvimSpellfile = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    spelldir="${config.xdg.dataHome}/nvim/spell"
    run mkdir -p "$spelldir"
    if [ ! -e "$spelldir/custom.utf-8.add" ]; then
      run cp ${./nvim/dic/custom.utf-8.add} "$spelldir/custom.utf-8.add"
      run chmod u+w "$spelldir/custom.utf-8.add"
    fi
  '';

  # lazy.nvim のプラグイン版ピン (lazy-lock.json) を再現可能にする。
  # ~/.config/nvim は recursive symlink だが、lazy はここに lazy-lock.json を
  # ランタイムで書き込む (実ファイル)。宣言的に symlink すると読み取り専用に
  # なり lazy が更新できず、recursive 対象内に置くと実ファイルと衝突するため、
  # リポジトリの seed (modules/nvim-seeds/lazy-lock.json) を新規マシンで初回のみ
  # コピーする。既存の lock はランタイム管理のまま (:Lazy update で更新可)。
  # ピンをリポジトリへ反映したいときは ~/.config/nvim/lazy-lock.json を
  # modules/nvim-seeds/ へ手動コピーしてコミットする。
  home.activation.seedNvimLazyLock = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    lockfile="${config.xdg.configHome}/nvim/lazy-lock.json"
    if [ ! -e "$lockfile" ]; then
      run cp ${./nvim-seeds/lazy-lock.json} "$lockfile"
      run chmod u+w "$lockfile"
    fi
  '';
}
