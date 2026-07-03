-- LspAttach 時のキーマッピング（バッファローカル）
-- plugins/lsp_config.lua の config から require("lsp.keymaps").setup() で呼ぶ。
local M = {}

-- buf_request_all の結果を Location/LocationLink のフラットな配列にまとめる。
local function collect_locations(results)
  local locations = {}
  for _, res in pairs(results) do
    local result = res.result
    if result then
      -- 単一の Location/LocationLink か、その配列かのどちらか。
      if result.uri or result.targetUri then
        table.insert(locations, result)
      else
        for _, loc in ipairs(result) do
          table.insert(locations, loc)
        end
      end
    end
  end
  return locations
end

-- 候補が「カーソル位置そのものの定義（自分自身）」だけかを判定する。
local function is_self_only(locations, cur_uri, row, col)
  if #locations ~= 1 then
    return false
  end
  local loc = locations[1]
  local uri = loc.uri or loc.targetUri
  local range = loc.range or loc.targetSelectionRange or loc.targetRange
  if uri ~= cur_uri or not range then
    return false
  end
  local s, e = range.start, range["end"]
  local after_start = row > s.line or (row == s.line and col >= s.character)
  local before_end = row < e.line or (row == e.line and col <= e.character)
  return after_start and before_end
end

-- 定義へジャンプ。先に LSP へ問い合わせ、以下の通り振る舞いを分ける:
--   候補なし / 自分自身のみ        → 何もしない
--   候補1件かつ同一ファイル内      → telescope を出さず直接ジャンプ
--   それ以外（複数・別ファイル）    → 従来どおり telescope で一覧表示
local function goto_definition(picker_opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/definition" })
  if #clients == 0 then
    return
  end
  local encoding = clients[1].offset_encoding
  local params = vim.lsp.util.make_position_params(0, encoding)
  local cur_uri = vim.uri_from_bufnr(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  vim.lsp.buf_request_all(bufnr, "textDocument/definition", params, function(results)
    local locations = collect_locations(results)
    if #locations == 0 then
      return
    end
    if is_self_only(locations, cur_uri, row, col) then
      return
    end
    -- 候補が1件で同一ファイル内なら telescope を挟まず直接ジャンプ。
    if #locations == 1 then
      local loc = locations[1]
      if (loc.uri or loc.targetUri) == cur_uri then
        vim.cmd("normal! m'") -- ジャンプリストに現在位置を残す
        vim.lsp.util.show_document(loc, encoding, { focus = true })
        return
      end
    end
    require("telescope.builtin").lsp_definitions(picker_opts)
  end)
end

-- 1 バッファ分のキーマップを張る（LspAttach コールバックから呼ばれる）
local function on_attach(ev)
  local opts = { buffer = ev.buf }
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
  end

  -- gd: 候補が複数あればフロート＋プレビュー一覧を出す（jump_type="never"）。候補上で Ctrl+v/Ctrl+x で分割オープン。
  -- ただし候補がカーソル位置そのもの（自分自身の定義）だけのときは何もしない。
  -- telescope の defaults.file_ignore_patterns（node_modules 等）が効くため、依存先へは飛ばない。
  map("gd", function()
    goto_definition({ jump_type = "never" })
  end, "LSP: definition (telescope)")
  -- gl: node_modules 等も含めて定義へジャンプ（file_ignore_patterns を無効化）。
  -- 依存ライブラリの .d.ts を見たいときはこちら。gd 側は通常通り node_modules を除外したまま。
  map("gl", function()
    goto_definition({ jump_type = "never", file_ignore_patterns = {} })
  end, "LSP: definition incl. node_modules (telescope)")
  map("gD", vim.lsp.buf.declaration, "LSP: go to declaration")
  map("gi", vim.lsp.buf.implementation, "LSP: go to implementation")
  -- 参照一覧: 標準 grr を telescope 化（フロート＋プレビュー、候補上で Ctrl+v/Ctrl+x で分割オープン）。
  -- jump_type="never" で候補が1件でも必ず一覧を出す（gd と挙動を揃える）。
  -- gr 単体マッピングは廃止（標準の grX と衝突して曖昧待ちになるため）。gr はプレフィックス専用。
  map("grr", function()
    require("telescope.builtin").lsp_references({ jump_type = "never" })
  end, "LSP: references (telescope)")

  -- grn (rename) は nvim 0.12 標準のまま使用（シンボル名＋全参照箇所をまとめてリネーム）。
  -- 以下も nvim 0.12 標準デフォルト。今は使わないため記載のみ（使うなら有効化）:
  --   gri = vim.lsp.buf.implementation()   -- 抽象/インターフェース → 具体実装へジャンプ
  --   grt = vim.lsp.buf.type_definition()  -- その変数の「型」の定義へジャンプ
  --   gra = vim.lsp.buf.code_action()      -- import 整理・quick fix 等のコードアクション
  -- grx (codelens.run) は使わないため無効化（何もしない）
  vim.keymap.set("n", "grx", "<Nop>", vim.tbl_extend("force", opts, { desc = "disabled" }))
  map("K", vim.lsp.buf.hover, "LSP: hover")
  map("<leader>rn", vim.lsp.buf.rename, "LSP: rename")
  map("<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
  map("<leader>de", vim.diagnostic.open_float, "LSP: show diagnostics")
end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = on_attach,
  })
end

return M
