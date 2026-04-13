{ config, pkgs, ... }:

{
  home.username = "hiraoku.shinichi";
  home.homeDirectory = "/Users/hiraoku.shinichi";

  home.sessionVariables = {
    P10K_THEME_PATH = "/Volumes/SSD/powerlevel10k/powerlevel10k.zsh-theme";
  };

  programs.git.settings = {
    user.name = "hiraoku.shinichi";
    user.email = "s.hiraoku@gmail.com";
    ghq.root = "/Volumes/SSD/ghq";
  };
}
