{ config, pkgs, lib, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = lib.mkMerge [
      # tmux auto-start + p10k instant prompt: must run before compinit (order 570)
      (lib.mkBefore (builtins.readFile ./zsh/early-init.sh))
      # Main configuration (default order 1000)
      ''
        # Set Powerlevel10k theme path from Nix store
        export P10K_THEME_PATH="${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"

        ${builtins.readFile ./zsh/zshrc.sh}
      ''
    ];
  };
}
