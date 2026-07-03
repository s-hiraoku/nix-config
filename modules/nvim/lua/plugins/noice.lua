-- folke/noice.nvim
-- : コマンドをフローティングウィンドウで表示し、入力中にサジェストが出る
-- LSP ドキュメントのレンダリングも強化
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim", -- ポップアップ UI に必須
    },
    opts = {
      -- LSP ドキュメント表示を noice 経由で強化
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        -- 短い write メッセージ (3L, 100B など) をミニ表示に
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
        -- :nmap / :history など行数の多い出力はフロートのポップアップに表示。
        --   画面下部を占有せず、`q` または `<Esc>` で閉じられる（:q 不要）。
        {
          filter = { event = "msg_show", min_height = 8 },
          view = "popup",
        },
      },
      presets = {
        bottom_search = true, -- 検索 (/ ?) は下部のまま
        command_palette = true, -- : コマンドをフローティングで表示 + サジェスト（候補一覧は cmp-cmdline が下に出す）
        -- long_message_to_split はスプリットを開いてレイアウトが崩れるので使わず、
        -- 上の routes で popup に流す。
        long_message_to_split = false,
      },
      -- 通知は snacks.notifier に任せる
      notify = { enabled = true },
    },
    config = function(_, opts)
      -- lazy.nvim がプラグインをインストール中の場合は messages をクリア
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
    keys = {
      {
        "<leader>snh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice: message history",
      },
      {
        "<leader>sna",
        function()
          require("noice").cmd("all")
        end,
        desc = "Noice: all messages",
      },
      {
        "<leader>snd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Noice: dismiss notifications",
      },
    },
  },
}
