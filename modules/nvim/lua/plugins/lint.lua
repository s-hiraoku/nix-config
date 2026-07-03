-- Linter（conform は formatter 専用なので別途）
-- 各 linter は mason で入れる: eslint_d, ruff, shellcheck
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- cspell をグローバル設定（~/.config/nvim/dic/cspell.json）で動かす。
    -- ここに無視単語リスト（custom-words.txt）を登録できる。
    local ok_cspell, cspell = pcall(function()
      return lint.linters.cspell
    end)
    if ok_cspell and type(cspell) == "table" and type(cspell.args) == "table" then
      local cfg = vim.fn.expand("~/.config/nvim/dic/cspell.json")
      -- "lint" サブコマンドの直後に --config を差し込む
      table.insert(cspell.args, 2, cfg)
      table.insert(cspell.args, 2, "--config")
    end

    -- eslint の診断・自動修正は eslint LSP（lsp_config.lua）に一本化したので
    -- ここでは eslint_d を使わない。
    lint.linters_by_ft = {
      javascript = { "cspell" },
      typescript = { "cspell" },
      javascriptreact = { "cspell" },
      typescriptreact = { "cspell" },
      python = { "ruff", "cspell" },
      lua = { "cspell" },
      markdown = { "cspell" },
      sh = { "shellcheck" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
