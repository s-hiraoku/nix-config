-- LSP の見た目: ホバー/シグネチャのフロート枠線・パディング、診断アイコン
-- plugins/lsp_config.lua の config から require("lsp.ui").setup() で呼ぶ。
local M = {}

-- ホバー / シグネチャウィンドウを rounded border + max_width 付きに
local function setup_handlers()
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    vim.lsp.handlers.hover(
      err,
      result,
      ctx,
      vim.tbl_deep_extend("force", config or {}, { border = "rounded", max_width = 80 })
    )
  end
  vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
    vim.lsp.handlers.signature_help(
      err,
      result,
      ctx,
      vim.tbl_deep_extend("force", config or {}, { border = "rounded", max_width = 80 })
    )
  end
end

-- LSP フロート（ホバー/シグネチャ）を開いたとき:
--   ・<Esc> / q で閉じられるようにする
--   ・フロート内で K を押しても man（General Commands Manual）が
--     開かないように K を無効化する
-- K を2回押してフロートに入った後の操作性を改善する。
local function override_floating_preview()
  local orig_open_floating_preview = vim.lsp.util.open_floating_preview
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    opts.max_width = opts.max_width or 80
    opts.max_height = opts.max_height or 25
    opts.wrap = opts.wrap ~= false

    -- パディング: 上下に空行、各行の左に1スペースを足して窮屈さを解消する。
    -- マークダウンのコードフェンス(```)は列頭判定が崩れると描画が壊れるので
    -- フェンス行だけはそのまま（左パディングしない）にする。
    if type(contents) == "table" then
      local padded = { "" }
      for _, line in ipairs(contents) do
        if type(line) == "string" and line:match("^```") then
          padded[#padded + 1] = line
        else
          padded[#padded + 1] = " " .. tostring(line)
        end
      end
      padded[#padded + 1] = ""
      contents = padded
    end

    local bufnr, winnr = orig_open_floating_preview(contents, syntax, opts, ...)
    local function close()
      if winnr and vim.api.nvim_win_is_valid(winnr) then
        pcall(vim.api.nvim_win_close, winnr, true)
      end
    end
    local kopts = { buffer = bufnr, nowait = true, silent = true }
    vim.keymap.set("n", "<Esc>", close, kopts)
    vim.keymap.set("n", "q", close, kopts)
    vim.keymap.set("n", "K", "<Nop>", kopts) -- man を開かせない
    return bufnr, winnr
  end
end

-- 診断アイコン設定
local function setup_diagnostics()
  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "",
      },
    },
    virtual_text = true,
    underline = true,
  })
end

function M.setup()
  setup_handlers()
  override_floating_preview()
  setup_diagnostics()
end

return M
