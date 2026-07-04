-- keymaps.lua から呼ぶアクション関数群
-- 複数行のロジックはここに集約し、keymaps.lua 側は map(...) の羅列に保つ
local M = {}

-- neo-tree など特殊バッファ以外の「ファイルウィンドウ」数を数える
local function count_file_wins()
  local n = 0
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
    if ft ~= "neo-tree" then
      n = n + 1
    end
  end
  return n
end

-- スマートなバッファ削除（ウィンドウレイアウトを崩さない）
-- 他にバッファがあれば切り替えてから削除、なければ空バッファに差し替え
function M.smart_bdelete()
  -- 保存はしない: 未保存バッファは bdelete(bang なし) が E89 で弾くので、誤って閉じない
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs <= 1 then
    -- 最後の1バッファ: 削除して alpha ダッシュボードに戻る
    if bufs[1] then
      vim.cmd("bdelete " .. bufs[1].bufnr)
    end
    vim.cmd("Alpha")
    -- bdelete 後に nvim が自動生成する [No Name] バッファを除去
    vim.schedule(function()
      for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if buf.name == "" then
          pcall(vim.cmd, "bwipeout " .. buf.bufnr)
        end
      end
    end)
  else
    -- 他にバッファがある: 前のバッファに切り替えてから削除
    local cur = vim.fn.bufnr()
    vim.cmd("bprev")
    vim.cmd("bdelete " .. cur)
  end
end

-- ウィンドウを閉じる + そのバッファも削除
-- ファイルウィンドウが1つだけのときは閉じない（レイアウトが崩れるため）
function M.close_win_and_buf()
  if count_file_wins() <= 1 then
    vim.notify("ファイルウィンドウが1つのため閉じません", vim.log.levels.WARN)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  vim.cmd("close")
  if #vim.fn.win_findbuf(bufnr) == 0 then
    vim.cmd("bdelete " .. bufnr)
  end
end

-- ウィンドウを閉じるだけ（バッファは残す）
-- close_win_and_buf と同じく、ファイルウィンドウが1つだけなら閉じない
function M.close_win()
  if count_file_wins() <= 1 then
    vim.notify("ファイルウィンドウが1つのため閉じません", vim.log.levels.WARN)
    return
  end
  vim.cmd("close")
end

-- 現在のバッファを縦/横分割した新ウィンドウへ移動（VSCode のタブをドラッグ相当）
-- 元ウィンドウは前のバッファに戻し、同じバッファの二重表示を避ける。
-- orientation: "v"=縦分割 / "s"=横分割
function M.move_buf_split(orientation)
  local cur_buf = vim.fn.bufnr()
  local cur_win = vim.api.nvim_get_current_win()
  vim.cmd(orientation == "v" and "vsplit" or "split")
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, cur_buf)
  -- 元ウィンドウは前のバッファへ
  vim.api.nvim_set_current_win(cur_win)
  vim.cmd("bprev")
  vim.api.nvim_set_current_win(new_win)
end

-- ウィンドウのズーム トグル（Herdr の prefix+z 相当）
-- 現在ウィンドウを新規タブで最大化し、もう一度押すとタブを閉じて元のレイアウトに戻す。
-- タブ＝ズーム用に使うので、ズーム中かどうかはタブ変数 t:zoomed で判定する。
function M.toggle_zoom()
  local ok, zoomed = pcall(vim.api.nvim_tabpage_get_var, 0, "zoomed")
  if ok and zoomed then
    vim.cmd("tabclose")
  else
    vim.cmd("tab split")
    vim.api.nvim_tabpage_set_var(0, "zoomed", true)
  end
end

-- スペルチェック トグル
function M.toggle_spell()
  vim.opt.spell = not vim.opt.spell:get()
  vim.notify("Spell check: " .. (vim.opt.spell:get() and "ON" or "OFF"))
end

-- 折り返し トグル（コードを一時的に折り返したいとき用）
function M.toggle_wrap()
  vim.opt_local.wrap = not vim.opt_local.wrap:get()
  vim.opt_local.linebreak = vim.opt_local.wrap:get()
  vim.notify("Wrap: " .. (vim.opt_local.wrap:get() and "ON" or "OFF"))
end

-- 現在バッファのパスを + レジスタ（システムクリップボード）へコピー
-- mode: "repo"=git ルート相対 / ""=cwd 相対 / ":p"=絶対 / ":t"=ファイル名のみ
-- git ルート相対は .git を上方向に探し、見つからなければ cwd 相対へフォールバックする
function M.yank_path(mode)
  if mode == "repo" then
    local file = vim.fn.expand("%:p")
    if file == "" then
      vim.notify("No file in buffer", vim.log.levels.WARN)
      return
    end
    local root = vim.fs.root(file, ".git")
    local path = root and file:sub(#root + 2) or vim.fn.expand("%")
    vim.fn.setreg("+", path)
    vim.notify("Yanked: " .. path)
    return
  end

  local path = vim.fn.expand("%" .. (mode or ""))
  if path == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify("Yanked: " .. path)
end

return M
