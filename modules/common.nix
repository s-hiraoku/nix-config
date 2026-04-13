{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.shellAliases = {
    vim = "nvim";
  };

  home.file.".local/bin/load-secrets" = {
    source = ./scripts/load-secrets.sh;
    executable = true;
  };

  home.packages = with pkgs; [
    fzf
    zoxide
    ghq
    delta
    ripgrep
    fd
    bat
    eza
    gh
    yazi
    tree
    sops
    age
  ];

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    escapeTime = 0;
    historyLimit = 50000;
    baseIndex = 1;
    mouse = true;
    prefix = "C-a";
    keyMode = "vi";

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

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --dark --paging=never --side-by-side --line-numbers";
        }
      ];
      customCommands = [
        {
          key = "<c-g>";
          description = "AI Commit (Claude Code)";
          context = "files";
          output = "terminal";
          command = ''bash -c '
            diff=$(git diff --cached)
            if [ -z "$diff" ]; then
              echo "Error: No staged changes found."
              read -n 1 -s -r -p "Press any key to continue..."
              exit 1
            fi
            echo "Generating commit message with Claude..."
            msg=$(echo "$diff" | claude -p --model haiku \
              "Generate a single-line commit message in Conventional Commits format: type(scope): description. Type must be one of: feat, fix, docs, style, refactor, test, chore. Base the message strictly on the provided diff. Output ONLY the commit message, nothing else." 2>&1)
            if [ $? -ne 0 ] || [ -z "$msg" ]; then
              echo "Error: Failed to generate commit message."
              echo "$msg"
              read -n 1 -s -r -p "Press any key to continue..."
              exit 1
            fi
            git commit -e -m "$msg"
          ' '';
          loadingText = "Generating commit message with Claude...";
        }
      ];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim/init.lua".text = ''
    require("config.lazy")
  '';

  xdg.configFile."nvim/lua/config/options.lua".text = ''
    vim.g.mapleader = ","
    vim.g.maplocalleader = ","
  '';

  xdg.configFile."nvim/lua/config/autocmds.lua".source = ./nvim/config/autocmds.lua;
  xdg.configFile."nvim/lua/config/lazy.lua".source = ./nvim/config/lazy.lua;

  xdg.configFile."nvim/lua/plugins/neo-tree.lua".text = ''
    return {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        window = {
          position = "left",
          width = 30,
          mappings = {
            ["<esc>"] = "none",
          },
        },
      },
    }
  '';

  xdg.configFile."nvim/lua/plugins/claudecode.lua".text = ''
    return {
      "coder/claudecode.nvim",
      opts = {
        terminal_cmd = "synapse claude -- --dangerously-skip-permissions",
      },
      config = function(_, opts)
        require("claudecode").setup(opts)
        vim.keymap.set("t", "<C-]>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
      end,
    }
  '';

  programs.ghostty = {
    enable = true;
    package = null;
    enableZshIntegration = true;
    settings = {
      # Appearance
      theme = "TokyoNight Night";
      window-theme = "dark";
      background = "#000000";
      background-opacity = 0.7;
      background-blur = 13;
      font-family = "HackGen Console NF";
      font-size = 13;
      font-thicken = true;
      unfocused-split-opacity = 0.6;
      scrollback-limit = 200000;
      window-padding-color = "extend";
      macos-option-as-alt = "left";
      confirm-close-surface = true;
      shell-integration-features = "no-title";
      window-inherit-working-directory = true;

      # Quick Terminal
      quick-terminal-position = "top";

      keybind = [
        # Quick Terminal
        "global:ctrl+backquote=toggle_quick_terminal"

        # Alt — split移動
        "alt+h=goto_split:left"
        "alt+j=goto_split:down"
        "alt+k=goto_split:up"
        "alt+l=goto_split:right"
        "alt+left=goto_split:left"
        "alt+down=goto_split:down"
        "alt+up=goto_split:up"
        "alt+right=goto_split:right"

        # Alt — split操作
        "alt+n=new_split:auto"
        "alt+f=toggle_split_zoom"
        "alt+equal=equalize_splits"

        # Alt — タブ直接ジャンプ
        "alt+one=goto_tab:1"
        "alt+two=goto_tab:2"
        "alt+three=goto_tab:3"
        "alt+four=goto_tab:4"
        "alt+five=goto_tab:5"
        "alt+six=goto_tab:6"
        "alt+seven=goto_tab:7"
        "alt+eight=goto_tab:8"
        "alt+nine=goto_tab:9"

        # Ctrl+p — Paneモード
        "ctrl+p>h=goto_split:left"
        "ctrl+p>j=goto_split:down"
        "ctrl+p>k=goto_split:up"
        "ctrl+p>l=goto_split:right"
        "ctrl+p>left=goto_split:left"
        "ctrl+p>down=goto_split:down"
        "ctrl+p>up=goto_split:up"
        "ctrl+p>right=goto_split:right"
        "ctrl+p>n=new_split:auto"
        "ctrl+p>d=new_split:down"
        "ctrl+p>r=new_split:right"
        "ctrl+p>x=close_surface"
        "ctrl+p>f=toggle_split_zoom"
        "ctrl+p>e=equalize_splits"

        # Ctrl+t — Tabモード
        "ctrl+t>h=previous_tab"
        "ctrl+t>k=previous_tab"
        "ctrl+t>left=previous_tab"
        "ctrl+t>up=previous_tab"
        "ctrl+t>l=next_tab"
        "ctrl+t>j=next_tab"
        "ctrl+t>right=next_tab"
        "ctrl+t>down=next_tab"
        "ctrl+t>n=new_tab"
        "ctrl+t>x=close_tab"
        "ctrl+t>one=goto_tab:1"
        "ctrl+t>two=goto_tab:2"
        "ctrl+t>three=goto_tab:3"
        "ctrl+t>four=goto_tab:4"
        "ctrl+t>five=goto_tab:5"
        "ctrl+t>six=goto_tab:6"
        "ctrl+t>seven=goto_tab:7"
        "ctrl+t>eight=goto_tab:8"
        "ctrl+t>nine=goto_tab:9"
        "ctrl+t>shift+h=move_tab:-1"
        "ctrl+t>shift+l=move_tab:1"
        "ctrl+t>shift+left=move_tab:-1"
        "ctrl+t>shift+right=move_tab:1"

        # リサイズ
        "ctrl+comma=resize_split:left,20"
        "ctrl+period=resize_split:right,20"
        "ctrl+semicolon=resize_split:down,20"
        "ctrl+apostrophe=resize_split:up,20"
        "ctrl+n>e=equalize_splits"

        # macOS
        "cmd+d=new_split:right"
        "cmd+shift+d=new_split:down"
        "cmd+k=clear_screen"
      ];
    };
  };

  programs.home-manager.enable = true;
}
