-- 基本設定
-- mapleader は keymaps.lua より前に設定する必要がある
vim.g.mapleader = ","

-- netrw（組み込みファイラー）を無効化 → neo-tree を使うため
-- init.lua より前に読み込まれる必要があるため options.lua の先頭で設定する
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = true

-- インデント
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- 表示
opt.wrap = false
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.termguicolors = true
opt.cursorline = true

-- 不可視文字の可視化（VSCode の renderWhitespace 相当）
--   space → 薄いドット / tab → 矢印
--   ドットの色は ui.lua の Whitespace ハイライト（custom_highlights）で薄くしている
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  eol = "↲",
  extends = "»",
  precedes = "«",
  nbsp = "␣",
  space = "·",
}

-- バッファ終端（最終行より下）の `~` を消してスッキリ見せる
-- （VSCode のように最終行の下を空白として見せる）
opt.fillchars = {
  eob = " ",
  foldinner = " ",
}
vim.o.foldcolumn = "1"

-- ステータスラインを画面下部に1本だけ表示（ウィンドウ分割しても全幅で1本）
-- lualine 側でも globalstatus=true を設定している
opt.laststatus = 3

-- 検索
-- hlsearch=true で一致箇所をハイライト。<Esc> で消去（keymaps.lua に設定済み）
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- ファイル
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- パフォーマンス
opt.updatetime = 50
opt.timeoutlen = 300

-- クリップボード
opt.clipboard = "unnamedplus"

-- 分割方向
opt.splitbelow = true
opt.splitright = true

-- スペルチェック（typo を波線表示）
-- cjk を追加することで漢字・ひらがな等の日本語を誤検知しない
-- treesitter のおかげでコードでは主にコメント/文字列だけがチェック対象になる
-- （<leader>sp でトグル可能）
opt.spell = true
opt.spelllang = { "en_us", "cjk" }
-- camelCase / snake_case を単語ごとに分割して判定（コードの誤検知を減らす）
opt.spelloptions = "camel"
-- ユーザー辞書: ~/.local/share/nvim/spell/custom.utf-8.add（書き込み可能な場所）
--   zg で「正しい単語」として登録（このファイルに追記される）
--   zw で「誤り」として登録 / zug で取り消し
--   登録すると nvim が自動で .spl にコンパイルする
--   NOTE: ~/.config/nvim は nix ストアの読み取り専用 symlink なので追記できない。
--   modules/neovim.nix が modules/nvim/dic/custom.utf-8.add をここへシードする。
--   リポジトリへ反映したい単語はシードへ手動でコピーし直す。
opt.spellfile = vim.fn.stdpath("data") .. "/spell/custom.utf-8.add"

-- コード折りたたみ（treesitter ベース）
-- グローバルデフォルトを設定
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- 起動時は全て展開した状態にする
opt.foldlevelstart = 99 -- バッファを開いた時も全展開
opt.foldenable = true
-- fold の per-buffer 再適用・言語別インデント・折り返しは autocmds.lua を参照
