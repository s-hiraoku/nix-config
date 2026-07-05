-- カラースキーム（Kanagawa Wave）
return {
  "rebelot/kanagawa.nvim",
  name = "kanagawa",
  lazy = false,
  priority = 1000,
  opts = {
    theme = "wave",
    transparent = true,
    terminalColors = true,
    overrides = function(colors)
      local palette = colors.palette
      local theme = colors.theme
      return {
        -- ウィンドウの区切り線をハッキリさせる。
        WinSeparator = { fg = palette.waveBlue2, bold = true },
        -- 行番号を見やすく（非カレント行を少し明るく、カレント行は黄色＋太字）
        LineNr = { fg = palette.fujiGray },
        CursorLineNr = { fg = palette.carpYellow, bold = true },
        -- 空白ドット / タブ矢印を薄く表示（listchars 用）
        Whitespace = { fg = palette.sumiInk4 },
        NonText = { fg = palette.sumiInk4 },
        -- 透過背景だとホバー等のフロートも透けて読みづらいので、
        -- フロートだけは不透明な背景＋見やすい枠線色にする
        NormalFloat = { bg = theme.ui.bg_m3 },
        FloatBorder = { bg = theme.ui.bg_m3, fg = palette.waveBlue2 },
      }
    end,
  },
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.cmd.colorscheme("kanagawa-wave")
  end,
}
