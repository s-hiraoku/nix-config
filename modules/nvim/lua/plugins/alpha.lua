-- スタートダッシュボード
-- nvim を引数なしで起動したときのみ表示
return {
  "goolord/alpha-nvim",
  dependencies = {
    "MaximilianLloyd/ascii.nvim",
  },
  event = "VimEnter",
  cond = function()
    return vim.fn.argc() == 0
  end,
  config = function()
    local alpha = require("alpha")
    local ascii = require("ascii")
    local dashboard = require("alpha.themes.dashboard")

    -- Kanagawa Wave カラー
    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7e9cd8" }) -- crystalBlue
    vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#7fb4ca" }) -- springBlue
    vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#dcd7ba" }) -- fujiWhite
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#727169" }) -- fujiGray

    local header_lines = ascii.art.text.neovim.sharp
    dashboard.section.header.val = header_lines
    dashboard.section.header.opts.hl = "AlphaHeader"

    -- ──────────────────────────────────────
    -- ボタン
    -- ──────────────────────────────────────
    local btn = dashboard.button
    dashboard.section.buttons.val = {
      btn("f", "󰈞  Find file", "<cmd>Telescope find_files<CR>"),
      btn("r", "󱋡  Recent files", "<cmd>lua require('telescope.builtin').oldfiles({ cwd_only = true })<CR>"),
      btn("g", "󰊄  Find text", "<cmd>Telescope live_grep<CR>"),
      btn("e", "󰈔  New file", "<cmd>ene<CR>"),
      btn("h", "󰋭  Health check", "<cmd>checkhealth<CR>"),
      btn("?", "󰋖  Help", "<cmd>help<CR>"),
      btn("q", "󰗼  Quit", "<cmd>qa<CR>"),
    }
    for _, b in ipairs(dashboard.section.buttons.val) do
      if b.opts then
        b.opts.hl = "AlphaButtons"
        b.opts.hl_shortcut = "AlphaShortcut"
      end
    end

    -- ──────────────────────────────────────
    -- フッター
    -- ──────────────────────────────────────
    local v = vim.version()
    dashboard.section.footer.val = string.format("NVIM v%d.%d.%d", v.major, v.minor, v.patch)
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- ──────────────────────────────────────
    -- レイアウト（画面中央に配置）
    -- ──────────────────────────────────────
    local header_h = #header_lines
    local buttons_h = #dashboard.section.buttons.val
    local content_h = header_h + 2 + buttons_h + 1 + 1 -- header + pads + buttons + pad + footer

    dashboard.config.layout = {
      {
        type = "padding",
        val = function()
          return math.max(0, math.floor((vim.fn.winheight(0) - content_h) / 2))
        end,
      },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)
  end,
}
