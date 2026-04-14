{ config, pkgs, ... }:

{
  # P10K_THEME_PATH is now set in zsh.nix initContent from Nix store

  programs.git.settings = {
    user.email = "hiraoku.shinichi@synergy101.jp";
    ghq.root = "/Users/hiraoku.shinichi/ghq";
  };
}
