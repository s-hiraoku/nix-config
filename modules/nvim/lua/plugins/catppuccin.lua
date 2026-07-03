-- カラースキーム（Catppuccin Macchiato）
return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "macchiato", -- "latte" | "frappe" | "macchiato" | "mocha"
    transparent_background = true,
    -- 透過背景で見づらくなった部分のハイライト調整
    custom_highlights = function(colors)
      return {
        -- ウィンドウの区切り線をハッキリさせる（太字＋明るめの色）
        WinSeparator = { fg = colors.blue, bold = true },
        -- 行番号を見やすく（非カレント行を少し明るく、カレント行は黄色＋太字）
        LineNr = { fg = colors.overlay1 },
        CursorLineNr = { fg = colors.yellow, bold = true },
        -- 空白ドット / タブ矢印を薄く表示（listchars 用）
        Whitespace = { fg = colors.surface1 },
        NonText = { fg = colors.surface1 },
        -- 透過背景だとホバー等のフロートも透けて読みづらいので、
        -- フロートだけは不透明な背景＋見やすい枠線色にする
        NormalFloat = { bg = colors.mantle },
        FloatBorder = { bg = colors.mantle, fg = colors.blue },
      }
    end,
    integrations = {
      bufferline = true,
      gitsigns = true,
      lsp_trouble = false,
      mason = true,
      neo_tree = true,
      noice = true,
      telescope = { enabled = true },
      treesitter = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
