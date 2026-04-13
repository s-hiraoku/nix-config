{ config, pkgs, ... }:

{
  home.sessionVariables = {
    P10K_THEME_PATH = "/Volumes/SSD/powerlevel10k/powerlevel10k.zsh-theme";
  };

  programs.git.settings = {
    user.email = "s.hiraoku@gmail.com";
    ghq.root = "/Volumes/SSD/ghq";
  };
}
