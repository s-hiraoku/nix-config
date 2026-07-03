-- ディレクトリツリー

-- カーソル下フォルダの中身を対象に、入力文字でインクリメンタルジャンプする。
-- "hoge" と打つと h→o→g→e の順で「打った文字列以上で最初に一致する子ノード」へ移動。
-- 実体が無ければ辞書順でその直後のノードに止まる。Esc / Enter で確定。
local function neotree_jump_in_folder(state)
  local renderer = require("neo-tree.ui.renderer")
  local node = state.tree:get_node()
  if not node then
    return
  end
  -- 対象フォルダ: ディレクトリならそれ自身、ファイルなら親フォルダ
  local folder_id = node.type == "directory" and node:get_id() or node:get_parent_id()
  if not folder_id then
    return
  end
  local children = state.tree:get_nodes(folder_id)
  if not children or #children == 0 then
    return
  end

  -- 入力中の文字列を neo-tree ペーン上部に検索ボックスとして表示する
  -- （noice.nvim に拾われず常に大きく見えるよう、フローティングウィンドウを使う）
  local treewin = vim.api.nvim_get_current_win()
  local treewidth = vim.api.nvim_win_get_width(treewin)
  local buf = vim.api.nvim_create_buf(false, true)
  local function render_prompt(q)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " 🔍 " .. q })
  end
  render_prompt("")
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = treewin,
    anchor = "NW",
    row = 0,
    col = 0,
    width = math.max(treewidth - 2, 10),
    height = 1,
    style = "minimal",
    border = "rounded",
    zindex = 250,
    focusable = false,
  })
  vim.api.nvim_set_option_value("winhighlight", "Normal:IncSearch,FloatBorder:IncSearch", { win = win })

  local query = ""
  while true do
    -- query「以上」で最初に一致する子ノードへ（辞書順、大文字小文字無視）
    local target
    for _, child in ipairs(children) do
      if child.name:lower() >= query:lower() then
        target = child
        break
      end
    end
    if target then
      renderer.focus_node(state, target:get_id())
    end
    render_prompt(query)
    vim.cmd("redraw")
    local ok, ch = pcall(vim.fn.getcharstr)
    if not ok then
      break
    end
    if ch == "\27" or ch == "\r" or ch == "\n" then -- Esc / Enter で確定
      break
    elseif ch == "\8" or ch == "\127" then -- BS で1文字削除
      query = query:sub(1, -2)
    elseif #ch == 1 then
      query = query .. ch
    end
  end
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

-- `,` 押下時のエントリ。カーソルが閉じたフォルダ上なら先に開いてから検索。
local function neotree_jump_entry(state)
  local node = state.tree:get_node()
  if not node then
    return
  end
  if node.type == "directory" and not node:is_expanded() then
    local fs = require("neo-tree.sources.filesystem")
    if node.loaded == false then
      -- 子ノード未スキャン: 非同期ロード後にジャンプ
      fs.toggle_directory(state, node, nil, false, false, function()
        vim.schedule(function()
          neotree_jump_in_folder(state)
        end)
      end)
    else
      -- ロード済みで折りたたみ中: 同期展開してからジャンプ
      node:expand()
      require("neo-tree.ui.renderer").redraw(state)
      neotree_jump_in_folder(state)
    end
    return
  end
  neotree_jump_in_folder(state)
end

-- `←` 開いているフォルダ上なら閉じる、それ以外はカーソルノードの親フォルダ行へジャンプ
local function neotree_jump_to_parent(state)
  local node = state.tree:get_node()
  if not node then
    return
  end
  -- カーソルが展開中のフォルダにあるなら閉じる（`→` の対の動作）
  if node.type == "directory" and node:is_expanded() then
    require("neo-tree.sources.filesystem").toggle_directory(state, node)
    return
  end
  local parent_id = node:get_parent_id()
  if parent_id then
    require("neo-tree.ui.renderer").focus_node(state, parent_id)
  end
end

-- `→` カーソル下フォルダを開く（既に開いている/ファイルなら何もしない）
local function neotree_open_folder(state)
  local node = state.tree:get_node()
  if node and node.type == "directory" and not node:is_expanded() then
    require("neo-tree.sources.filesystem").toggle_directory(state, node)
  end
end

-- ファイル追従 (follow_current_file) のランタイム トグル。
-- neo-tree はバッファ移動時に VIM_BUFFER_ENTER から M.follow() を直接呼ぶため、
-- state.follow_current_file.enabled を倒すだけでは追従が止まらない。
-- そこで M.follow をラップし、追従 OFF の間は素通りさせる。
-- 状態は vim.g.neotree_follow_enabled に持たせ、lualine からも色分けで参照する
-- （Copilot と同じく nil/未設定は ON 扱い）。
local function ensure_follow_wrapped()
  local fs = require("neo-tree.sources.filesystem")
  if fs._follow_wrapped then
    return
  end
  fs._follow_wrapped = true
  local orig_follow = fs.follow
  fs.follow = function(...)
    if vim.g.neotree_follow_enabled == false then
      return false
    end
    return orig_follow(...)
  end
end

-- neo-tree ウィンドウ上で押して、ファイル追従の ON/OFF を切り替える
local function neotree_toggle_follow()
  ensure_follow_wrapped()
  vim.g.neotree_follow_enabled = vim.g.neotree_follow_enabled == false
  vim.notify("Neo-tree follow: " .. (vim.g.neotree_follow_enabled and "ON" or "OFF"))
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  -- `nvim .` でディレクトリ起動したとき neo-tree を自動で開く
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local argv0 = vim.fn.argv(0)
        if argv0 ~= "" and vim.fn.isdirectory(argv0) == 1 then
          vim.schedule(function()
            -- ファイルツリーを開いてエディタ側にフォーカスを戻す
            vim.cmd("Neotree show")
            vim.cmd("wincmd l")
          end)
        end
      end,
    })
  end,
  opts = {
    close_if_last_window = true, -- neo-tree だけ残ったら自動で閉じる
    -- インデント線はデフォルト（│ / └）のまま使う。
    -- "▏" など細いグリフに変えると、ディレクトリ外のファイルに線が残ったり
    -- 線が消失したりと描画が不安定になるため、安定したデフォルトを採用する。
    -- バッファが全部閉じられたとき空バッファを開く（レイアウト崩れ防止）
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.opt_local.signcolumn = "auto"
        end,
      },
    },
    window = {
      width = 35,
      mappings = {
        ["<space>"] = "none", -- <leader> と競合しないように無効化
        ["s"] = "open_vsplit", -- 左右に分割して開く
        ["S"] = "open_split", -- 上下に分割して開く
        ["."] = "set_root", -- カーソル下のディレクトリをルートに
        ["<bs>"] = "navigate_up", -- 親ディレクトリをルートに
        -- カーソル下フォルダの中身を文字入力でインクリメンタルジャンプ
        [";"] = { neotree_jump_entry, desc = "Tree: jump within folder" },
        -- 開いているフォルダなら閉じる / それ以外は親フォルダ行へジャンプ
        ["<left>"] = { neotree_jump_to_parent, desc = "Tree: close folder / jump to parent" },
        -- カーソル下フォルダを開く（ファイルは何もしない）
        ["<right>"] = { neotree_open_folder, desc = "Tree: open folder" },
        -- ファイル追従（開いているファイルへ自動ジャンプ）の ON/OFF をトグル
        ["F"] = { neotree_toggle_follow, desc = "Tree: toggle follow current file" },
        -- neo-tree カーソル下のノードを Copilot Chat に追加（d = directory）
        --   ディレクトリ → #glob:<rel_path>/** でファイル一覧を渡す
        --   ファイル     → #file:<path> でファイル内容を渡す
        ["<leader>pd"] = {
          function(state)
            local node = state.tree:get_node()
            if not node then
              return
            end
            local path = node:get_id()
            local cwd = vim.fn.getcwd()
            -- cwd からの相対パスに変換
            local rel = path
            if path:sub(1, #cwd + 1) == cwd .. "/" then
              rel = path:sub(#cwd + 2)
            end
            local resource
            if node.type == "directory" then
              resource = "glob:`" .. rel .. "/**`"
            else
              resource = "file:`" .. path .. "`"
            end
            require("CopilotChat").open({ resources = resource })
          end,
          desc = "Copilot: add node to chat",
        },
      },
    },
    filesystem = {
      use_libuv_file_watcher = true, -- 外部変更をリアルタイムで検知
      filtered_items = {
        visible = true, -- フィルタされたアイテムを常に表示
        hide_dotfiles = false, -- .env などを表示
        hide_gitignored = true,
      },
      follow_current_file = {
        enabled = true, -- 開いているファイルをツリーで追従
      },
    },
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Tree: toggle" },
    { "<leader>o", "<cmd>Neotree focus<CR>", desc = "Tree: focus" },
  },
}
