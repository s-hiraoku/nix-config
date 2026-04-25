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
    zsh-powerlevel10k
    imagemagick
    lefthook
    git-cliff
    ruff
    zellij
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "hiraoku.shinichi";
      init.defaultBranch = "main";
    };
  };

  # ~/.config/nix/nix.conf を home-manager で一元管理する。
  # 会社 PC のような TLS インスペクション環境では work.nix 側で
  # ssl-cert-file を上書きする。
  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  programs.home-manager.enable = true;
}
