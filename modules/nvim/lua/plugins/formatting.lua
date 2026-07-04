-- フォーマッター設定
-- フォーマッター本体: stylua / yamlfmt / ruff は lua/lsp/servers.lua の
-- mason-tool-installer ensure_installed で起動時に自動インストールされる。
-- prettier は各プロジェクトの node_modules から自動解決（util.from_node_modules）。
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  config = function()
    local conform = require("conform")

    conform.setup({
      -- prettier はプロジェクトの設定(.prettierrc / printWidth 等)を自動で読む。
      -- tailwind class 順・import 順は eslint の保存時 fixAll に任せる
      -- （lsp_config.lua）。rustywind は eslint と順序ルールが食い違うため不採用。
      -- yaml は prettier ではなく yamlfmt を使用（クォート種の制御のため）。
      -- yamlfmt のグローバル設定: ~/.config/yamlfmt/.yamlfmt
      formatters_by_ft = {
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "yamlfmt" },
        html = { "prettier" },
        css = { "prettier" },
        python = { "ruff_format", stop_after_first = true },
        lua = { "stylua" },
      },
      -- 保存時整形は conform に一本化する。まず eslint の fixAll を同期実行し
      -- (import 順・tailwind class 順)、その後 prettier 等を走らせることで
      -- 「eslint → prettier」の順序を確定させる (lsp/servers.lua の説明参照)。
      format_on_save = function(bufnr)
        require("lsp.servers").eslint_fix_sync(bufnr)
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    })

    vim.keymap.set({ "n", "v" }, "<leader>fm", function()
      conform.format({ async = true, lsp_format = "fallback" })
    end, { desc = "Format: format buffer / selection" })
  end,
}
