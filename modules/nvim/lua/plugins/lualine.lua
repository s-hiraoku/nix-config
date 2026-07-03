-- ステータスライン
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin-macchiato",
        component_separators = "|",
        section_separators = { left = "", right = "" },
        -- ステータスラインを画面全体で1本にする（ウィンドウ幅に依存しない）
        globalstatus = true,
        disabled_filetypes = {
          winbar = { "alpha", "neo-tree" },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          -- Neo-tree のファイル追従 ON/OFF（tree 上で F でトグル）
          -- 追従中=点灯色の 󰈈 / 非追従=消灯色の 󰈉。アイコンと色の両方で出し分ける（nil/未設定は ON 扱い）
          {
            function()
              return vim.g.neotree_follow_enabled ~= false and "󰈈" or "󰈉"
            end,
            color = function()
              return { fg = vim.g.neotree_follow_enabled ~= false and "#a6da95" or "#6e738d" }
            end,
          },
          "branch",
          "diff",
          "diagnostics",
        },
        -- ファイル名は winbar で表示しているのでステータスラインからは省略
        lualine_c = {},
        lualine_x = {
          -- spell の ON/OFF（<leader>sp）。OFF を表すスラッシュ版アイコンが無いため、色だけで出し分ける
          {
            function()
              return "󰓆"
            end,
            color = function()
              return { fg = vim.opt_local.spell:get() and "#a6da95" or "#6e738d" }
            end,
          },
          -- wrap の ON/OFF（<leader>tr）: 󰖶 ON(点灯色) / 󰯟 OFF(消灯色)
          {
            function()
              return vim.opt_local.wrap:get() and "󰖶" or "󰯟"
            end,
            color = function()
              return { fg = vim.opt_local.wrap:get() and "#a6da95" or "#6e738d" }
            end,
          },
          -- lazy.nvim のアップデート件数を右側に表示
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = { fg = "#ff9e64" },
          },
          "encoding",
          "fileformat",
          "filetype",
          -- アタッチ中の LSP サーバ名（例:  lua_ls）。複数あればカンマ区切り。なければ非表示。
          {
            function()
              local names = {}
              for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                table.insert(names, c.name)
              end
              return "" .. table.concat(names, ",")
            end,
            cond = function()
              return #vim.lsp.get_clients({ bufnr = 0 }) > 0
            end,
            color = { fg = "#8aadf4" },
          },
        },
        lualine_y = { "progress" },
        -- 現在行:列 と ファイル全体の行数を表示
        lualine_z = {
          "location",
          {
            function()
              return vim.fn.line("$") .. " 行"
            end,
          },
        },
      },
      -- winbar はファイルパスのみ（ステータスラインと役割分担）
      winbar = {
        lualine_c = { { "filename", path = 1 } },
      },
      inactive_winbar = {
        lualine_c = { { "filename", path = 1 } },
      },
    })
  end,
}
