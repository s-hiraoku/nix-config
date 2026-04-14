{ config, pkgs, ... }:

{
  imports = [
    ./tmux.nix
    ./lazygit.nix
    ./zsh.nix
    ./neovim.nix
    ./ghostty.nix
  ];

  home.username = "hiraoku.shinichi";
  home.homeDirectory = "/Users/hiraoku.shinichi";
  home.stateVersion = "25.11";

  home.shellAliases = {
    vim = "nvim";
  };

  home.file.".local/bin/load-secrets" = {
    source = ./scripts/load-secrets.sh;
    executable = true;
  };

  home.packages = with pkgs; [
    fzf
    zoxide
    ghq
    delta
    ripgrep
    fd
    bat
    eza
    gh
    yazi
    tree
    mise
    sops
    age
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "hiraoku.shinichi";
      init.defaultBranch = "main";
    };
  };

  programs.home-manager.enable = true;
}
