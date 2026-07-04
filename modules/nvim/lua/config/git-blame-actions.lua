-- gitsigns blame (<leader>hb) で見える「カーソル行のコミット」を起点にした追加アクション。
--   - diff_file_at_commit : そのコミットの「このファイル」の差分（git show を 1 split に表示する簡素ビュー）
--   - commit_details      : そのコミット全体の変更ファイル一覧 + 各差分（diffview）
--   - open_pr             : そのコミットを取り込んだ PR の番号と URL
-- キーマップは gitsigns の on_attach 側 (plugins/ui.lua) で束ねている。
local M = {}

-- カーソル行を最後に変更したコミットの hash を git blame で取得する。
-- 未コミット行 (000000...) や git 管理外・失敗時は nil を返し、理由を通知する。
local function blame_hash()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file in buffer", vim.log.levels.WARN)
    return nil
  end
  local line = vim.fn.line(".")
  local dir = vim.fn.fnamemodify(file, ":h")
  local out = vim.fn.systemlist({
    "git",
    "-C",
    dir,
    "blame",
    "-L",
    line .. "," .. line,
    "--porcelain",
    "--",
    file,
  })
  if vim.v.shell_error ~= 0 or not out[1] then
    vim.notify("git blame に失敗しました（git 管理外？）", vim.log.levels.WARN)
    return nil
  end
  -- porcelain の 1 行目: "<hash> <orig_line> <final_line> [<num_lines>]"
  local hash = out[1]:match("^(%x+)")
  if not hash or hash:match("^0+$") then
    vim.notify("未コミットの行です", vim.log.levels.WARN)
    return nil
  end
  return hash, file
end

-- このファイルの「そのコミットでの差分」を git show で取得し、スクラッチ split に表示する。
-- diffview の 3 ペインではなく 1 ウィンドウだけの簡素ビュー。q で閉じる。
function M.diff_file_at_commit()
  local hash, file = blame_hash()
  if not hash then
    return
  end
  local dir = vim.fn.fnamemodify(file, ":h")
  local out = vim.fn.systemlist({ "git", "-C", dir, "show", hash, "--", file })
  if vim.v.shell_error ~= 0 then
    vim.notify("git show に失敗しました", vim.log.levels.ERROR)
    return
  end
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "git" -- コミットヘッダ + diff をハイライト
  -- 同名バッファが既にあると set_name が失敗するので pcall で握りつぶす
  pcall(vim.api.nvim_buf_set_name, buf, "git show " .. hash:sub(1, 7) .. " -- " .. vim.fn.fnamemodify(file, ":t"))
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, desc = "閉じる" })
end

-- そのコミット全体の変更ファイル一覧 + 各ファイル差分を diffview で開く。
function M.commit_details()
  local hash = blame_hash()
  if not hash then
    return
  end
  vim.cmd("DiffviewOpen " .. hash .. "^!")
end

-- そのコミットを取り込んだ PR の番号と URL を gh で取得し、通知 + クリップボードへコピー。
-- ブラウザは開かない（WezTerm なら ⌘+クリックで開ける）。
function M.open_pr()
  local hash, file = blame_hash()
  if not hash then
    return
  end
  if vim.fn.executable("gh") == 0 then
    vim.notify("gh が見つかりません", vim.log.levels.ERROR)
    return
  end
  local cwd = vim.fn.fnamemodify(file, ":h")
  vim.system({
    "gh",
    "api",
    "repos/{owner}/{repo}/commits/" .. hash .. "/pulls",
    "--jq",
    'if length>0 then "\\(.[0].number)\\t\\(.[0].html_url)" else empty end',
  }, { cwd = cwd, text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        vim.notify("PR の取得に失敗しました:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
        return
      end
      local out = vim.trim(res.stdout or "")
      local num, url = out:match("^(%d+)\t(.+)$")
      if not num then
        vim.notify(
          "このコミットに紐づく PR が見つかりません (" .. hash:sub(1, 7) .. ")",
          vim.log.levels.WARN
        )
        return
      end
      vim.fn.setreg("+", url)
      vim.notify(
        "PR #" .. num .. "\n" .. url .. "\n(URL をクリップボードにコピー / ⌘+クリックで開けます)"
      )
    end)
  end)
end

return M
