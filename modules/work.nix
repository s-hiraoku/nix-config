{ config, pkgs, ... }:

{
  home.sessionVariables = {
    P10K_THEME_PATH = "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme";
  };

  programs.git.settings = {
    user.email = "hiraoku.shinichi@synergy101.jp";
    ghq.root = "/Users/hiraoku.shinichi/ghq";
  };
}
