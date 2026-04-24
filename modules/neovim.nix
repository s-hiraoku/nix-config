{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;
  xdg.configFile."nvim/lua/config/options.lua".source = ./nvim/config/options.lua;
  xdg.configFile."nvim/lua/config/autocmds.lua".source = ./nvim/config/autocmds.lua;
  xdg.configFile."nvim/lua/config/lazy.lua".source = ./nvim/config/lazy.lua;
  xdg.configFile."nvim/lua/plugins/neo-tree.lua".source = ./nvim/plugins/neo-tree.lua;
  xdg.configFile."nvim/lua/plugins/claudecode.lua".source = ./nvim/plugins/claudecode.lua;
  xdg.configFile."nvim/lua/plugins/snacks-image.lua".source = ./nvim/plugins/snacks-image.lua;
  xdg.configFile."nvim/lua/plugins/fugitive.lua".source = ./nvim/plugins/fugitive.lua;
}
