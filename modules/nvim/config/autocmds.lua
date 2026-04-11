-- Transparent background to match Ghostty terminal opacity
local function set_transparent_bg()
  local transparent_groups = {
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "FloatBorder",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
  }
  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true }),
  callback = set_transparent_bg,
})

set_transparent_bg()
