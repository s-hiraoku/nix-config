-- キーマッピング
-- 複数行ロジックは config/keymap-actions.lua に分離し、ここは map(...) の羅列に保つ
-- desc は英語に統一。実 Ex コマンドを呼ぶものは [:cmd] プレフィックスを付ける。
local map = vim.keymap.set
local act = require("config.keymap-actions")

-- ウィンドウ移動
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window below" })
map("n", "<C-k>", "<C-w>k", { desc = "Window above" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- バッファ移動
map("n", "<Tab>", "<cmd>bnext<CR>", { silent = true, desc = "[:bnext] Next buffer" })
map("n", "<S-Tab>", "<cmd>bprev<CR>", { silent = true, desc = "[:bprev] Prev buffer" })

-- バッファ操作
map("n", "<leader>bd", act.smart_bdelete, { desc = "Close buffer (smart)" })
map("n", "<leader>bw", "<cmd>w<CR>", { desc = "[:w] Save buffer" })
map("n", "<leader>br", "<cmd>e!<CR>", { desc = "[:e!] Reload buffer (discard changes)" })
-- バッファを縦/横分割した新ウィンドウへ移動（元の窓は前のバッファへ）
map("n", "<leader>bv", function()
  act.move_buf_split("v")
end, { desc = "Move buffer to vertical split" })
map("n", "<leader>bs", function()
  act.move_buf_split("s")
end, { desc = "Move buffer to horizontal split" })

-- ウィンドウ操作
map("n", "<leader>wq", act.close_win_and_buf, { desc = "Close window and delete buffer" })
map("n", "<leader>wc", act.close_win, { desc = "Close window" })
map("n", "<leader>z", act.toggle_zoom, { desc = "Toggle window zoom" })
map("n", "<leader>qa", "<cmd>qa<CR>", { desc = "[:qa] Quit all" })

-- 検索ハイライトをクリア
map("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "[:nohlsearch] Clear search highlight" })

-- ビジュアルモードでインデント保持
map("v", "<", "<gv", { desc = "Indent left (keep selection)" })
map("v", ">", ">gv", { desc = "Indent right (keep selection)" })

-- ビジュアルで貼り付けてもヤンクしたレジスタを汚さない（連続貼り付け可能に）
-- ※ ノーマルモードの p には影響しない
map("x", "p", [["_dP]], { desc = "Paste without yanking" })

-- 行移動 (ビジュアルモード)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- カーソル位置を維持しながら行結合
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- 検索時にカーソルを中央に
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

-- マクロ記録の暴発防止
-- IME 有効のまま tmux ペイン切替を失敗すると stray な `q`+レジスタ文字が紛れ込み、
-- 無音でマクロ記録が始まる→which-key がトリガーを suspend し続け、leader が効かなくなる。
-- 素の q では記録を始めないようにし、意図的に記録したいときだけ <leader>Q を使う。
map("n", "q", "<Nop>", { desc = "Disabled (macro record暴発防止 / 記録は <leader>Q)" })
-- 意図的にマクロ記録したくなったら下行を有効化する
-- map("n", "<leader>Q", "q", { desc = "Record macro (deliberate)" })

-- 現在バッファのパスをコピー（+ レジスタ＝システムクリップボード）
-- yp は git ルート相対（git 外なら cwd 相対にフォールバック）
map("n", "<leader>yp", function()
  act.yank_path("repo")
end, { desc = "Yank path (git-root relative)" })
map("n", "<leader>yP", function()
  act.yank_path(":p")
end, { desc = "Yank absolute path" })
map("n", "<leader>yn", function()
  act.yank_path(":t")
end, { desc = "Yank file name" })

-- Git: diffview を一発で閉じる（<leader>hD で開く 3 ペインを q で1枚ずつ閉じる手間を回避）。
-- diffview のどのペインからでも、途中で別バッファを開いた後でも効くようグローバルに置く。
-- 他の <leader>h 系（hunk/blame）は git バッファ限定で gitsigns の on_attach 側にある。
map("n", "<leader>hQ", "<cmd>DiffviewClose<CR>", { desc = "[:DiffviewClose] Close diffview" })

-- 診断 (diagnostics) ジャンプ。<leader>d グループに統一（一覧は <leader>dl、浮動表示は <leader>de）。
-- 標準の ]d / [d と同じ vim.diagnostic.jump を呼ぶ。float=true でジャンプ先のメッセージも表示。
map("n", "<leader>dn", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Diagnostic: next" })
map("n", "<leader>dp", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Diagnostic: prev" })

-- トグル系
map("n", "<leader>sp", act.toggle_spell, { desc = "Toggle spell check" })
map("n", "<leader>tr", act.toggle_wrap, { desc = "Toggle line wrap" })

-- 選択範囲を HTML/JSX タグで囲む（VSCode の htmltagwrap 相当）
-- ビジュアルで選択 → <leader>tw → 続けて `div>` のようにタグ名を入力。
-- 内部的には nvim-surround のビジュアル surround（S）+ タグ指定（t）を発火する。
map("x", "<leader>tw", "St", { remap = true, desc = "Wrap selection in HTML/JSX tag" })

-- insert モード: zsh(readline/emacs)風の行編集
--   既に nvim 標準: ^U(カーソル前を削除) / ^W(前の単語を削除=backward-kill-word) / ^H(Backspace)
--   ^B ^F ^E は cmp と兼用（メニュー表示中=docs スクロール/abort / 非表示=単語移動・行末）→ plugins/completion.lua で定義
--   ^J ^] ^, ^. → Copilot 占有 / ^R ^T ^V → nvim 標準を温存
map("i", "<C-k>", "<C-o>D", { desc = "Kill to end of line (zsh ^K)" })
map("i", "<C-d>", "<C-o>dw", { desc = "Kill word forward (zsh ^D) ※insert の dedent を上書き" })
-- ^A=行頭。tmux prefix(C-a) と競合するため tmux 内では C-a C-a の2回押しで届く
map("i", "<C-a>", "<Home>", { desc = "Beginning of line (zsh ^A)" })

-- insert モードのまま現在行をコメントトグル（Comment.nvim の gcc を <C-o> で1発実行）
-- 端末で ^/ は ^_ として届く。remap=true は gcc がプラグイン定義のため必須。
map("i", "<C-_>", "<C-o>gcc", { remap = true, desc = "Toggle comment (current line)" })
