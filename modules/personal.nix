{ config, pkgs, ... }:

{
  home.username = "hiraoku.shinichi";
  home.homeDirectory = "/Users/hiraoku.shinichi";

  programs.git.settings = {
    user.name = "hiraoku.shinichi";
    user.email = "s.hiraoku@gmail.com";
    ghq.root = "/Volumes/SSD/ghq";
  };
}
