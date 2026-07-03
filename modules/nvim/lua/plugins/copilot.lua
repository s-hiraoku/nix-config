-- GitHub Copilot 統合
-- copilot.lua  : インライン補完（ghost text）
--
-- 初回認証手順:
--   1. nvim を開いて :Copilot auth を実行
--   2. ワンタイムコードが表示される → ブラウザで https://github.com/login/device を開いてコードを入力
--   3. 認証完了後、インライン補完が有効になる
return {
  -- インライン補完エンジン（ゴーストテキスト）
  --
  -- 方針: インライン補完（薄字ゴースト）は自動表示する。
  --   ツリー型の補完メニューには出さないので邪魔にならない。
  --   <C-j> を押さない限り何も挿入されない。
  --   操作:
  --     <C-j>     … サジェストを受け入れる
  --     <C-l>     … サジェストを再呼び出し / 次の候補へ
  --     <C-k>     … 前の候補へ
  --     <C-]>     … サジェストを消す
  --     <leader>tc … Copilot 自体の ON/OFF トグル（ステータスバーに表示）
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- ステータスバー（lualine）表示用の状態フラグ
      vim.g.copilot_enabled = true

      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true, -- 薄字ゴーストを自動表示
          hide_during_completion = false, -- cmp メニュー表示中もゴーストを出す（受け入れは <C-j>、cmp は <CR>）
          -- 組み込み keymap は「候補が表示中のときだけ」有効で挙動が読みづらいため、
          -- keymap は全部 false にして下で明示的に割り当てる。
          keymap = {
            accept = false,
            accept_word = false,
            accept_line = false,
            next = false,
            prev = false,
            dismiss = false,
          },
        },
        panel = {
          enabled = false,
        },
        filetypes = {
          ["*"] = true,
        },
      })

      local map = vim.keymap.set
      map("i", "<C-j>", function()
        local sug = require("copilot.suggestion")
        if sug.is_visible() then
          sug.accept()
        end
      end, { desc = "Copilot: accept suggestion" })
      -- C-k/C-l は insert モードの kill-line / ウィンドウ移動と被るため C-./C-, へ移設。
      -- ※ C-. / C-, は WezTerm の Kitty キーボードプロトコル経由でのみ届く（非対応端末では無反応）。
      map("i", "<C-.>", function()
        require("copilot.suggestion").next()
      end, { desc = "Copilot: show / next suggestion" })
      map("i", "<C-,>", function()
        require("copilot.suggestion").prev()
      end, { desc = "Copilot: previous suggestion" })
      map("i", "<C-]>", function()
        require("copilot.suggestion").dismiss()
      end, { desc = "Copilot: dismiss suggestion" })

      -- Copilot 全体の ON/OFF トグル（vim.g.copilot_enabled をステータスバーが参照）
      map("n", "<leader>tc", function()
        vim.g.copilot_enabled = not vim.g.copilot_enabled
        vim.cmd(vim.g.copilot_enabled and "Copilot enable" or "Copilot disable")
        vim.notify("Copilot: " .. (vim.g.copilot_enabled and "ON" or "OFF"))
      end, { desc = "Copilot: toggle on/off" })
    end,
  },
}
