-- Lua モジュールのバイトコードをキャッシュして起動を高速化（最優先で有効化する）
vim.loader.enable()

-- Homebrew の PATH を追加（GUI 起動や非ログインシェルからでも brew ツールを認識させる）
local homebrew_bin = vim.fn.isdirectory("/opt/homebrew/bin") == 1 and "/opt/homebrew/bin" -- Apple Silicon
  or "/usr/local/bin" -- Intel Mac
if not vim.env.PATH:find(homebrew_bin, 1, true) then
  vim.env.PATH = homebrew_bin .. ":" .. vim.env.PATH
end

require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lazy")
