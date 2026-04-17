{ config, pkgs, ... }:

{
  programs.git.settings = {
    user.email = "s.hiraoku@gmail.com";
    ghq.root = "/Volumes/SSD/ghq";
  };
}
