{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      # Set Powerlevel10k theme path from Nix store
      export P10K_THEME_PATH="${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"

      ${builtins.readFile ./zsh/zshrc.sh}
    '';
  };
}
