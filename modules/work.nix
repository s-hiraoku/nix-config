{ config, pkgs, ... }:

{
  home.username = "hiraoku.shinichi";
  home.homeDirectory = "/Users/hiraoku.shinichi";

  home.sessionVariables = {
    P10K_THEME_PATH = "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme";
  };

  programs.git.settings = {
    user.name = "hiraoku.shinichi";
    user.email = "hiraoku.shinichi@synergy101.jp";
    ghq.root = "/Users/hiraoku.shinichi/ghq";
  };
}
