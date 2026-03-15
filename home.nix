{ config, pkgs, ... }:

{
  home.username = "hiraoku.shinichi";
  home.homeDirectory = "/Users/hiraoku.shinichi";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    fzf
    zoxide
    ghq
    delta
    ripgrep
    fd
  ];

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    escapeTime = 0;
    historyLimit = 50000;
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    prefix = "C-a";

    extraConfig = ''
      # True Color対応
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Neovimのautoread等のために必要
      set -g focus-events on

      # ペインも1始まり
      set -g pane-base-index 1
      set -g renumber-windows on

      # 設定リロード
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # ペイン分割（現在のパスを引き継ぐ）
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # 新規ウィンドウ（現在のパスを引き継ぐ）
      bind c new-window -c "#{pane_current_path}"

      # ペイン移動（Vim風）
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ペインリサイズ
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ペインズームイン/アウト
      bind z resize-pane -Z

      # ウィンドウ移動
      bind -r p previous-window
      bind -r n next-window

      # コピーモード（vi）
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe "pbcopy"

      # ステータスバー
      set -g status on
      set -g status-interval 5
      set -g status-position bottom

      # 色設定（Catppuccin Mocha風）
      set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
      set -g window-status-current-style "bg=#313244,fg=#89b4fa,bold"
      set -g pane-border-style "fg=#313244"
      set -g pane-active-border-style "fg=#89b4fa"
      set -g message-style "bg=#313244,fg=#cdd6f4"

      # 左側：セッション名
      set -g status-left-length 30
      set -g status-left "#[bg=#89b4fa,fg=#1e1e2e,bold] #S #[default] "

      # 右側：時刻
      set -g status-right-length 50
      set -g status-right "#{?client_prefix,#[bg=#f38ba8 fg=#1e1e2e bold] PREFIX ,#[fg=#a6adc8]} %Y-%m-%d %H:%M "

      # セッション管理
      bind S new-session -c "#{pane_current_path}" -s "#{b:pane_current_path}"
      bind s display-popup -E "tmux list-sessions | fzf | cut -d: -f1 | xargs tmux switch-client -t"

      # タイトル設定
      set -g allow-rename off
      set -g automatic-rename on
      set -g set-titles on
      set -g automatic-rename-format '#{?#{m/r:^(zsh|bash|fish|sh)$,#{pane_current_command}},#{=/42/...:pane_title},#{?#{pane_title},#{=/28/...:pane_title} · ,}#{pane_current_command}}'
      set -g set-titles-string '#S · #{window_name}'
      set -g window-status-format ' #I:#{=/34/...:window_name} '
      set -g window-status-current-format ' #I:#{=/34/...:window_name} '
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;  # $EDITOR=nvim
  };

  programs.ghostty = {
    enable = true;
    package = null;  # macOSではApp Storeからインストール済み
    enableZshIntegration = true;
    settings = {
      shell-integration-features = "no-title";
      window-inherit-working-directory = true;
    };
  };

  programs.home-manager.enable = true;
}
