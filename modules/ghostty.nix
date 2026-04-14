{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = null;
    # Zsh integration is manually sourced in zshrc.sh (only outside tmux)
    # because Ghostty's PS1 marker injection breaks p10k's nested parameter expansions.
    enableZshIntegration = false;
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
}
