{ config, pkgs, ... }:

{
  home.username = "hiraoku.shinichi";
  home.homeDirectory = "/Users/hiraoku.shinichi";

  programs.git.settings = {
    user.name = "hiraoku.shinichi";
    user.email = "hiraoku.shinichi@synergy101.jp";
    ghq.root = "/Users/hiraoku.shinichi/ghq";
  };
}
