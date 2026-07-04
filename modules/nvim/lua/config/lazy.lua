-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  install = { colorscheme = { "habamax" } },
  -- アップデートチェックは有効だが通知ポップアップは出さない
  -- アップデート件数は lualine のステータスバーに表示される
  checker = { enabled = true, notify = false },
  -- luarocks / hererocks を無効化
  -- 企業 VPN の SSL 証明書が Lua ダウンロードをブロックするため
  -- image.nvim は magick_cli を使うので luarocks 不要
  rocks = { enabled = false },
})
