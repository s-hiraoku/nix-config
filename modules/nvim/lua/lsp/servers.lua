-- Mason / LSP サーバーのセットアップとサーバー別設定
-- plugins/lsp_config.lua の config から require("lsp.servers").setup() で呼ぶ。
local M = {}

function M.setup()
  require("mason").setup()
  require("mason-tool-installer").setup({
    ensure_installed = {
      -- フォーマッター（conform.nvim から呼ぶ。prettier はプロジェクトの
      -- node_modules から解決するためここには含めない）
      "stylua",
      "yamlfmt",
      "ruff",
      -- linter（nvim-lint から呼ぶ）
      "shellcheck",
      -- スペルチェック（コード識別子も対象、nvim-lint から呼ぶ）
      -- cspell 9.x は Node >=22.18 必須。現環境(22.16)で動く 8.x に固定。
      { "cspell", version = "8.19.4" },
    },
    auto_update = false,
    run_on_start = true,
  })
  require("mason-lspconfig").setup({
    -- ts_ls の代わりに vtsls（tsserver ラッパー。型情報・補完が充実）を使う
    -- eslint LSP で診断 + 保存時 fixAll（import 順・tailwind class 順を自動修正）
    ensure_installed = { "vtsls", "eslint", "pyright", "lua_ls", "tailwindcss", "yamlls" },
    -- 旧 ts_ls がインストール済みでも二重起動しないよう除外
    automatic_enable = { exclude = { "ts_ls" } },
  })

  -- nvim-cmp との統合: 全サーバーに capabilities を適用
  vim.lsp.config("*", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  })

  -- yamlls 固有設定
  vim.lsp.config("yamlls", {
    settings = {
      yaml = {
        keyOrdering = false,
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
          ["https://json.schemastore.org/github-action.json"] = ".github/actions/*/action.{yml,yaml}",
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
        },
      },
    },
  })

  -- lua_ls 固有設定
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    },
  })

  -- vtsls（TypeScript / JavaScript）固有設定
  vim.lsp.config("vtsls", {
    settings = {
      typescript = {
        preferences = { includePackageJsonAutoImports = "auto" },
      },
      javascript = {
        preferences = { includePackageJsonAutoImports = "auto" },
      },
    },
  })

  -- eslint: 診断 + 保存時 fixAll
  --   tailwind class 順・import 順などを「警告を出している eslint ルール自体」で
  --   修正するので、rustywind のような独自順との不整合が起きず警告も消える。
  vim.lsp.config("eslint", {
    settings = { workingDirectories = { mode = "auto" } },
  })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserEslintFixAll", {}),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if not client or client.name ~= "eslint" then
        return
      end
      -- このバッファの保存直前に eslint の全自動修正を同期実行する
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = ev.buf,
        callback = function()
          pcall(function()
            client:request_sync("workspace/executeCommand", {
              command = "eslint.applyAllFixes",
              arguments = {
                {
                  uri = vim.uri_from_bufnr(ev.buf),
                  version = vim.lsp.util.buf_versions[ev.buf],
                },
              },
            }, 3000, ev.buf)
          end)
        end,
      })
    end,
  })
end

return M
