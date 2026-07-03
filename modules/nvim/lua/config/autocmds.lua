-- 自動コマンド（autocmd）
-- options.lua は「静的なオプション設定」に専念し、
-- FileType などのイベントで動的に挙動を変えるものはこのファイルに集約する。
local autocmd = vim.api.nvim_create_autocmd

-- マクロ記録の可視化
--   noice が既定の "recording @x" メッセージを隠すため、記録の開始/終了を通知で明示する。
--   万一 q 無効化をすり抜けて記録が始まっても、無音で which-key が死ぬ事態に気づける。
autocmd("RecordingEnter", {
  callback = function()
    vim.notify("マクロ記録開始 @" .. vim.fn.reg_recording(), vim.log.levels.WARN)
  end,
})
autocmd("RecordingLeave", {
  callback = function()
    vim.notify("マクロ記録終了", vim.log.levels.INFO)
  end,
})

-- treesitter ベースの fold を per-buffer に再適用する
--   options.lua で fold のグローバル既定を設定しているが、treesitter は
--   バッファ読み込み後に非同期で解析するため、FileType イベントで
--   per-buffer に再設定して fold を確実に有効化する。
autocmd("FileType", {
  callback = function()
    -- 特殊バッファ（neo-tree / terminal など）はスキップ
    if vim.bo.buftype ~= "" then
      return
    end
    vim.schedule(function()
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt_local.foldlevel = 99
      vim.opt_local.foldlevelstart = 99
      vim.opt_local.foldenable = true
    end)
  end,
})

-- 言語ごとのインデント幅（スペース）
--   グローバルは 2（options.lua で設定済み）。ここで異なる言語だけ上書きする。
--   typescript/javascript/tsx/json/yaml/lua/html/css は既定の 2 を使用。
local indent_by_ft = {
  python = 4,
  go = 4, -- go は tab だが幅だけ揃える
}
autocmd("FileType", {
  callback = function(args)
    local width = indent_by_ft[args.match]
    if width then
      vim.bo[args.buf].tabstop = width
      vim.bo[args.buf].shiftwidth = width
      vim.bo[args.buf].softtabstop = width
    end
  end,
})

-- 折り返し設定
--   markdown / text / gitcommit は文章なので折り返す（単語境界 + インデント揃え）。
--   コード（typescript 等）は既定の折り返しなし（options.lua の opt.wrap=false）のまま。
--   一時的に折り返したくなったら <leader>tr でトグルできる（keymaps.lua）。
autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- 単語の途中で折り返さない
    vim.opt_local.breakindent = true -- 折り返し行のインデントを揃える
  end,
})
