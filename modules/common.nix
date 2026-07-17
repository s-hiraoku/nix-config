{ config, pkgs, ... }:

{
  imports = [
    ./herdr.nix
    ./lazygit.nix
    ./zsh.nix
    ./neovim.nix
    ./ghostty.nix
  ];

  home.username = "hiraoku.shinichi";
  home.homeDirectory = "/Users/hiraoku.shinichi";
  home.stateVersion = "25.11";

  home.shellAliases = {
    vim = "nvim";
  };

  home.file.".local/bin/load-secrets" = {
    source = ./scripts/load-secrets.sh;
    executable = true;
  };

  # Claude Code statusline (settings.json の statusLine.command から参照される)
  home.file.".claude/statusline.sh" = {
    source = ./scripts/claude-statusline.py;
    executable = true;
  };

  home.packages = with pkgs; [
    ghq
    delta
    ripgrep
    fd
    gh
    yazi
    tree
    sops
    age
    zsh-powerlevel10k
    imagemagick
    lefthook
    git-cliff
    ruff
    zellij
    gemini-cli
    ni  # antfu/ni: package manager auto-detect
    opencode
    wtp  # overlay 経由 (pkgs/wtp.nix)
    hunk  # overlay 経由 (upstream flake, flake.nix 参照)
    librsvg
    colima
    ffmpeg
    python314
    # --- 開発用 CLI ツール ---
    jq          # JSON プロセッサ (herdr のワークスペース切替でも使用)
    yq-go       # YAML/JSON/XML プロセッサ (jq の YAML 版)
    just        # Makefile 代替のタスクランナー
    watchexec   # ファイル変更で任意コマンドを再実行
    hyperfine   # コマンドのベンチマーク
    xh          # HTTPie 互換の HTTP クライアント
    jless       # JSON ビューア
    dust        # ディスク使用量をツリー表示 (du 代替)
    duf         # ファイルシステム使用状況 (df 代替)
    btop        # リソースモニタ (top 代替)
    tokei       # コード行数統計
    gitleaks    # secrets 混入スキャン (CI と同じものをローカル pre-commit でも)
  ];

  # direnv + nix-direnv: ディレクトリ移動だけで .envrc / flake devShell に入る。
  # nix-direnv は devShell の評価結果をキャッシュして再入場を高速化する。
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # zoxide: zsh 統合 (`z` / `zi`) を宣言管理。
  # 以前は zshrc.sh で `eval "$(zoxide init zsh)"` を手書きしていた。
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # bat: cat 代替。テーマ等を宣言管理 (alias cat=bat は zshrc.sh 側)。
  programs.bat.enable = true;

  # eza: ls 代替。ls/ll/la/lt の alias はこのモジュールが定義する。
  # 以前 zshrc.sh に手書きしていた alias/関数は削除済み。
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  # mise: ランタイム管理 (ruby/erlang/elixir)。zsh activate を宣言管理。
  # 以前は zshrc.sh で `eval "$(mise activate zsh)"` を手書きしていた。
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  # atuin: シェル履歴を SQLite 管理 (^R を置き換え)。
  # up-arrow は zsh デフォルトのまま残す。マシン間同期を使う場合は
  # `atuin register` / `atuin login` を手動で行う (secrets は同期しない)。
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };

  # fzf: 素のパッケージではなく programs.fzf モジュールで導入し、
  # zsh 統合（^R 履歴検索 / ^T ファイル挿入 / ALT-C cd）を有効化する。
  # これがないと ^R が zsh デフォルトの redisplay のままになる。
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "hiraoku.shinichi";
      init.defaultBranch = "main";
      # delta を diff/show/blame の pager に配線する (パッケージは導入済みだった
      # が git 側の設定がなく素の less で表示されていた)。
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;  # n/N で diff セクション間を移動
        line-numbers = true;
      };
      diff.algorithm = "histogram";
      push.autoSetupRemote = true;  # 初回 push の -u が不要になる
      rerere.enabled = true;        # 一度解決した conflict を記憶して再適用
      fetch.prune = true;           # fetch 時にリモートで消えたブランチを掃除
    };
    ignores = [
      ".DS_Store"
      ".direnv/"
      "*.local"
      # 既存の ~/.config/git/ignore (手書き) から移行した項目
      "**/.claude/settings.local.json"
    ];
  };

  # ~/.config/nix/nix.conf を home-manager で一元管理する。
  # 会社 PC のような TLS インスペクション環境では work.nix 側で
  # ssl-cert-file を上書きする。
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  programs.home-manager.enable = true;
}
