# Neovim 設定マニュアル

このリポジトリの Neovim 構成（`modules/nvim/`）の操作マニュアル。どんなプラグインが入っていて、どう操作するのか、キーバインドは何か、を網羅する。

- **リーダーキー**: `,` (comma) / **ローカルリーダー**: `\`
- **プラグインマネージャ**: [lazy.nvim](https://github.com/folke/lazy.nvim)（プラグイン本体はランタイム管理）
- **カラースキーム**: Kanagawa Wave（透過背景）
- **管理方法**: Nix home-manager が `modules/nvim/` を `~/.config/nvim` へ symlink（詳細は [構成とメンテナンス](#構成とメンテナンス)）

> キーバインドが思い出せないときは **`,fk`**（Telescope keymaps 検索）か、`,` を押して少し待つと出る **which-key** ポップアップが早い。

---

## 目次

1. [ディレクトリ構成](#ディレクトリ構成)
2. [基本設定 (options)](#基本設定-options)
3. [キーバインド早見表](#キーバインド早見表)
4. [LSP](#lsp)
5. [補完 (completion)](#補完-completion)
6. [フォーマット / Lint](#フォーマット--lint)
7. [プラグイン詳細](#プラグイン詳細)
8. [自動挙動 (autocmds)](#自動挙動-autocmds)
9. [構成とメンテナンス](#構成とメンテナンス)

---

## ディレクトリ構成

```
modules/nvim/
├── init.lua                    # エントリ。loader キャッシュ有効化 → options → autocmds → keymaps → lazy
├── lua/
│   ├── config/
│   │   ├── options.lua         # vim.opt 基本設定
│   │   ├── autocmds.lua        # 自動挙動（fold 再適用・言語別インデント・文章折り返し等）
│   │   ├── keymaps.lua         # グローバルキーマップ
│   │   ├── keymap-actions.lua  # 複雑なキーマップの実装（ウィンドウ/バッファ操作等）
│   │   ├── git-blame-actions.lua # blame 起点の diff / PR 表示ロジック
│   │   └── lazy.lua            # lazy.nvim ブートストラップ + setup
│   ├── lsp/
│   │   ├── servers.lua         # mason / LSP サーバー設定 + eslint fixAll
│   │   ├── keymaps.lua         # LspAttach 時のバッファローカルキー
│   │   └── ui.lua              # hover / 診断アイコン等の見た目
│   └── plugins/                # 各プラグインの spec（1 ファイル 1 テーマ）
├── dic/                        # スペルチェック辞書（cspell + native spell シード）
```

---

## 基本設定 (options)

- リーダー `,` / ローカルリーダー `\`
- netrw を無効化（neo-tree を使用）
- 行番号 + 相対行番号 (relativenumber)
- インデントはスペース 2（tabstop=2 / shiftwidth=2 / expandtab / smartindent）※言語別上書きあり（後述）
- 折り返しオフ (wrap=false)、スクロール余白 scrolloff=8
- サインカラム常時表示、24bit カラー、カーソル行ハイライト
- 不可視文字を可視化: space/trail=`·`、tab=`» `、eol=`↲`、nbsp=`␣`
- バッファ終端の `~` を非表示、foldcolumn=1
- ステータスラインは画面下部に全幅で 1 本のみ (laststatus=3)
- 検索: hlsearch / incsearch、ignorecase + smartcase（大文字を含むときだけ大小区別）
- swapfile なし / backup なし / **undofile 有効（永続 undo）**
- updatetime=50、timeoutlen=300
- **クリップボードはシステム連携** (unnamedplus)
- 分割は下・右方向に開く (splitbelow / splitright)
- **スペルチェック オン**。spelllang=en_us+cjk（日本語は誤検知しない）、spelloptions=camel
- コード折りたたみは treesitter ベース。**起動時は全展開**（foldlevel=99）

---

## キーバインド早見表

`<leader>` = `,`。カテゴリの頭文字でグループ分けされている（`f`=find、`h`=git hunk、`b`=buffer、`w`=window、`d`=diagnostics、`t`=toggle、`m`=markdown、`y`=yank、`s`=search/spell）。

### ウィンドウ / 分割

| Key | 動作 |
|-----|------|
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | 左 / 下 / 上 / 右のウィンドウへ移動 |
| `<leader>wq` | ウィンドウを閉じてバッファも削除（最後の 1 つなら警告して閉じない） |
| `<leader>wc` | ウィンドウを閉じる（バッファは残す） |
| `<leader>z` | ウィンドウのズーム トグル（新規タブで最大化、再押下で戻す。Herdr prefix+z 相当） |
| `<leader>qa` | 全て終了 (`:qa`) |

### バッファ

| Key | 動作 |
|-----|------|
| `<Tab>` | 次のバッファ (`:bnext`) |
| `<S-Tab>` | 前のバッファ (`:bprev`) |
| `<leader>bd` | スマートなバッファ削除（レイアウトを崩さず切替後に削除。最後の 1 つなら Alpha に戻る。未保存は保護） |
| `<leader>bw` | 保存 (`:w`) |
| `<leader>br` | 変更を破棄して再読込 (`:e!`) |
| `<leader>bv` | 現在バッファを縦分割の新ウィンドウへ移動 |
| `<leader>bs` | 現在バッファを横分割の新ウィンドウへ移動 |

> `<Tab>` を normal モードのバッファ切替に使うため、端末によっては `<C-i>`（jumplist 前進）が効かない場合がある。

### ファイル / パスのコピー

| Key | 動作 |
|-----|------|
| `<leader>yp` | git ルート相対パスをクリップボードへコピー（git 外なら cwd 相対） |
| `<leader>yP` | 絶対パスをコピー |
| `<leader>yn` | ファイル名のみコピー |

### 検索 / 移動

| Key | 動作 |
|-----|------|
| `<Esc>` | 検索ハイライトを消す (`:nohlsearch`) |
| `n` / `N` | 次 / 前の検索結果（画面中央に寄せる `nzzzv`） |
| `J` | 行連結（カーソル位置維持） |

### 編集 / ビジュアル

| Mode | Key | 動作 |
|------|-----|------|
| v | `<` / `>` | 選択を保持したままインデント左 / 右 |
| x | `p` | ヤンクレジスタを汚さず貼り付け（連続貼り付け可） |
| v | `J` / `K` | 選択範囲を下 / 上へ移動 |
| x | `<leader>tw` | 選択を HTML/JSX タグで囲む（続けて `div>` 等を入力。nvim-surround） |

### insert モード（zsh / readline 風の行編集）

| Key | 動作 |
|-----|------|
| `<C-k>` | 行末まで削除（zsh `^K`） |
| `<C-d>` | 前方の単語を削除（zsh `^D`） |
| `<C-a>` | 行頭へ（zsh `^A`。Herdr prefix と競合するため、Herdr 内では prefix ではなく insert mode の `<C-a>` として届く場面で使う） |
| `<C-_>` | 現在行のコメントトグル（端末で `^/` は `^_` として届く） |

### 診断 (diagnostics)

| Key | 動作 |
|-----|------|
| `<leader>dn` | 次の診断へジャンプ（メッセージ表示） |
| `<leader>dp` | 前の診断へジャンプ |
| `<leader>de` | カーソル位置の診断をフロート表示 |
| `<leader>dl` | 診断一覧（Telescope） |

### トグル系

| Key | 動作 |
|-----|------|
| `<leader>sp` | スペルチェック トグル |
| `<leader>tr` | 行の折り返し トグル |

### マクロ記録

| Key | 動作 |
|-----|------|
| `q` | **無効化**（IME / マルチプレクサ操作ミスによる記録暴発を防ぐ） |

> 意図的なマクロ記録の割り当ては現状コメントアウトで未定義。

---

## LSP

サーバーは `mason-lspconfig` の `ensure_installed` で自動導入。全サーバーに `cmp_nvim_lsp` の capabilities が適用される。

| Server | 対象 | 備考 |
|--------|------|------|
| **vtsls** | TypeScript / JavaScript | tsserver ラッパー（型情報・補完が充実、`ts_ls` の代替）。package.json auto-import 有効 |
| **eslint** | ESLint 診断 + 保存時 fixAll | import 順・tailwind class 順を自動修正。`workingDirectories.mode = "auto"` |
| **pyright** | Python | |
| **lua_ls** | Lua | `vim` をグローバル認識、サードパーティチェック無効 |
| **tailwindcss** | Tailwind CSS | |
| **yamlls** | YAML | GitHub workflow / action / docker-compose のスキーマを自動マッピング |

**外部ツール**（`mason-tool-installer` で導入）: `stylua` / `yamlfmt` / `ruff`（フォーマッタ）、`shellcheck`（linter）、`cspell@8.19.4`（スペル。9.x は Node ≥22.18 必須のため 8.x 固定）。**prettier は mason に入れず、各プロジェクトの `node_modules` から解決**する。

**保存時の順序**: `eslint fixAll` → `prettier`（conform に一本化し順序を確定。詳細は [フォーマット / Lint](#フォーマット--lint)）。

### LSP キーバインド（バッファローカル、LspAttach 時）

| Key | 動作 |
|-----|------|
| `gd` | 定義へ（Telescope）。候補 1 個かつ同一ファイル内なら直接ジャンプ、複数ならリスト。node_modules は除外 |
| `gl` | 定義へ（node_modules も含む。依存の `.d.ts` に飛べる） |
| `gD` | 宣言へ |
| `gi` | 実装へ |
| `grr` | 参照一覧（Telescope、常にリスト表示） |
| `K` | ホバー（型・ドキュメント表示。フロート内で `<Esc>` / `q` で閉じる） |
| `<leader>rn` | リネーム |
| `<leader>ca` | コードアクション |
| `<leader>de` | 診断をフロート表示 |

> 定義・参照の Telescope リストでは `<C-v>` = 縦分割、`<C-x>` = 横分割で開ける。診断ジャンプは早見表の `<leader>dn` / `<leader>dp` を参照。

---

## 補完 (completion)

エンジンは **nvim-cmp**（`InsertEnter` / `CmdlineEnter` でロード）。スニペットは **LuaSnip**（+ friendly-snippets）。

- **ソース**（優先順）: ① `nvim_lsp`・`luasnip` → ② `buffer`・`path`
- **並び**: Field / Property を優先（props-first）

### insert モードのキー

| Key | 動作 |
|-----|------|
| `<C-Space>` | 補完メニューを開く |
| `<CR>` | 確定（選択中の候補を採用） |
| `<Tab>` | メニュー表示中は次候補 / スニペット展開・ジャンプ / それ以外はフォールバック |
| `<S-Tab>` | メニュー表示中は前候補 / スニペット後退 |
| `<C-e>` | メニュー表示中は閉じる / それ以外は行末へ (`<End>`) |
| `<C-b>` | メニュー表示中はドキュメント上スクロール / それ以外は後方単語へ |
| `<C-f>` | メニュー表示中はドキュメント下スクロール / それ以外は前方単語へ |

**コマンドライン補完**: `:` は path→cmdline、`/` `?` 検索は buffer ソース。

---

## フォーマット / Lint

### フォーマット（conform.nvim、保存時 + `<leader>fm`）

| ファイルタイプ | フォーマッタ |
|----------------|--------------|
| TS / TSX / JS / JSX | prettier |
| json / jsonc | prettier |
| html / css | prettier |
| yaml | **yamlfmt**（クォート種の制御のため。設定 `~/.config/yamlfmt/.yamlfmt`） |
| python | ruff_format |
| lua | stylua |

- prettier は各プロジェクトの `node_modules` から解決し、`.prettierrc` 等の設定を尊重
- **保存時**: `eslint fixAll`（import 順・tailwind class 順）→ prettier の順で実行（`timeout_ms=1000`）
- **手動**: `<leader>fm`（normal / visual）で現在バッファ / 選択範囲を整形

### Lint（nvim-lint）

`BufWritePost` / `BufReadPost` / `InsertLeave` で実行。

| ファイルタイプ | linter |
|----------------|--------|
| TS / TSX / JS / JSX | cspell |
| python | ruff, cspell |
| lua / markdown | cspell |
| sh | shellcheck |

- cspell は `dic/cspell.json` をグローバル設定として参照（無視単語は `dic/custom-words.txt`）
- ESLint 診断は eslint LSP に集約（eslint_d は不使用）

---

## プラグイン詳細

### ファイル探索

#### neo-tree.nvim — ファイルエクスプローラ

| Key | 動作 |
|-----|------|
| `<leader>e` | ツリーの表示トグル |
| `<leader>o` | ツリーにフォーカス |

ツリーウィンドウ内:

| Key | 動作 |
|-----|------|
| `s` / `S` | 左右分割 / 上下分割で開く |
| `.` | カーソル下ディレクトリをルートに |
| `<bs>` | 親ディレクトリをルートに |
| `;` | フォルダ内インクリメンタルジャンプ（文字入力で一致ノードへ。Esc/Enter 確定、BS で削除） |
| `<left>` | 開いてるフォルダを閉じる / 閉じてるなら親フォルダ行へ |
| `<right>` | カーソル下フォルダを開く |
| `F` | 現在ファイルへの追従 ON/OFF（lualine に状態表示） |

- `.env` 等のドットファイルは表示、gitignore 対象は非表示。外部変更をリアルタイム検知。
- `nvim <dir>` でディレクトリ起動するとツリーを開いてエディタにフォーカスを戻す。

#### telescope.nvim — ファジーファインダー

グローバル（`<leader>f` 系ほか）:

| Key | 動作 |
|-----|------|
| `<leader>ff` | ファイル検索 |
| `<leader>fg` | ライブ grep（`rg`、隠しファイルも対象） |
| `<leader>fb` | バッファ一覧 |
| `<leader>fh` | ヘルプタグ |
| `<leader>fd` | ディレクトリ検索 → 選択で neo-tree で開く |
| `<leader>fr` / `<leader>fR` | 最近のファイル（cwd 限定 / 全体） |
| `<leader>fc` | カーソル下の単語で grep |
| `<leader>fk` | キーマップ検索（全モード） |
| `<leader>:` | コマンド履歴 |
| `<leader>dl` | 診断一覧 |
| `<leader>hP` | git status（変更ファイル、diff プレビュー付き） |

プロンプト内（zsh 風行編集、insert）:

| Key | 動作 |
|-----|------|
| `<Esc>` | 閉じる |
| `<C-g>` | プレビュー表示/非表示 ＋ パス表示（smart ⇔ フル相対）を連動トグル |
| `<M-↑/↓/←/→>` | プレビューをスクロール |
| `<C-p>` / `<C-n>` | 入力履歴を前 / 次（永続化） |
| `<C-u>` / `<C-k>` | 行頭まで / 行末まで削除 |
| `<C-f>` / `<C-b>` | 次の単語 / 前の単語へ |
| `<C-d>` | 後方の単語を削除 |

> 候補移動は素の `↑`/`↓` と `Tab`/`S-Tab`（`C-n`/`C-p` は履歴に割当済みのため）。`C-w` は insert 標準の前方単語削除。

### Git

#### gitsigns.nvim — 変更行表示 & hunk 操作

変更サインは `▎`。キーはバッファローカル:

| Key | 動作 |
|-----|------|
| `<leader>hj` / `<leader>hk` | 次 / 前の hunk（末尾で反対側へループ） |
| `<leader>hs` | hunk のステージ / アンステージ（トグル） |
| `<leader>hr` | hunk をリセット |
| `<leader>hp` | hunk をプレビュー |
| `<leader>hb` | 行の blame 表示 |
| `<leader>hd` | blame 行コミットの**このファイル**の差分（git show の簡素ビュー、`q` で閉じる） |
| `<leader>hD` | blame 行コミットの**全変更ファイル**（diffview で開く） |
| `<leader>ho` | blame 行コミットの **PR** 番号・URL を取得しクリップボードへコピー（未コミット / PR 無しは中断） |

#### diffview.nvim — コミット差分閲覧

`:DiffviewOpen` 等 or `<leader>hD` 経由でロード。ビュー内 `q` で全体を一発クローズ。グローバルに `<leader>hQ`（`:DiffviewClose`）でどこからでも閉じられる。

#### lazygit.nvim — nvim 内で lazygit を起動

| Key | 動作 |
|-----|------|
| `<leader>gg` | lazygit をフローティングウィンドウで開く（プロジェクトルート） |
| `<leader>gf` | 現在ファイルのリポジトリで lazygit を開く |

lazygit 本体・設定（delta ページャ、`<C-g>` の AI コミット）は `modules/lazygit.nix` で管理。

### 編集支援

#### nvim-surround — 囲み操作
`ys`（追加）/ `cs`（変更）/ `ds`（削除）などの標準キー。ビジュアルで `<leader>tw` は HTML/JSX タグ囲み。

#### Comment.nvim — コメントトグル

| Key | 動作 |
|-----|------|
| `gcc` / `gbc` | 行コメント / ブロックコメント トグル |
| `gc` / `gb`（n/o/x） | 行 / ブロックコメント（オペレータ・選択対応） |

insert では `<C-_>`（= `^/`）で現在行トグル。

#### vim-visual-multi — マルチカーソル（VSCode cmd+d 相当）

| Key | 動作 |
|-----|------|
| `<C-n>` | カーソル下の単語を選択 & 次の同単語を追加 |
| `<C-Down>` / `<C-Up>` | 下 / 上にカーソル追加 |
| `<C-x>`（VM 中） | 現在の選択をスキップ |
| `u`（VM 中） | Undo |

フロー: `C-n` で選択 → 連打で追加 → `c`/`i` で同時編集 → `Esc`×2 で解除。

#### その他（キーマップなし・自動動作）
- **nvim-autopairs** — 括弧の自動閉じ（insert 時）
- **nvim-ts-autotag** — HTML/JSX/TSX タグの自動補完・自動リネーム
- **vim-matchup** — 対応する括弧・タグを常時ハイライト（はみ出しはポップアップ表示）
- **todo-comments.nvim** — `TODO`/`FIXME`/`HACK` 等をハイライト。`<leader>tl` で一覧（Telescope）、`]t` / `[t` で次 / 前へ

### UI / 表示

- **kanagawa.nvim** — カラースキーム（Wave、透過背景）
- **bufferline.nvim** — 上部のバッファタブ（`<Tab>`/`<S-Tab>` で移動）
- **lualine.nvim** — 下部ステータスライン。Neo-tree 追従・git branch/diff・診断・spell・wrap・lazy 更新件数・LSP サーバ名・行数を表示
- **noice.nvim** — `:` コマンドをフロート表示 & 入力サジェスト。`<leader>snh`（履歴）/ `<leader>sna`（全メッセージ）/ `<leader>snd`（通知クリア）
- **indent-blankline.nvim** — インデントガイド（`▏`）
- **which-key.nvim** — キー入力途中でバインド一覧をポップアップ（helix プリセット）
- **alpha-nvim** — 引数なし起動時のダッシュボード。ヘッダーは `ascii.nvim` の `art.text.neovim.sharp`。`f`=検索 / `r`=最近 / `g`=grep / `e`=新規 / `h`=checkhealth / `?`=help / `q`=終了

### 言語 / Markdown / 画像

- **nvim-treesitter** — 構文解析・ハイライト・fold。対象パーサーは ts/js/tsx/python/lua/json/yaml/html/css/markdown/bash 等。未導入言語は自動インストール
- **render-markdown.nvim** — nvim 内で Markdown をリッチ表示（見出しアイコン・コードブロック背景・チェックボックス・表）。`<leader>mp` でトグル
- **markdown-preview.nvim** — ブラウザでライブプレビュー（スクロール同期）。`<leader>mv` でトグル
- **image.nvim** — nvim 内で画像・Markdown 内画像をインライン表示。kitty graphics protocol（**Ghostty 等の対応端末**）+ ImageMagick が必要

---

## 自動挙動 (autocmds)

- **マクロ記録の通知** — 記録開始で WARN、終了で INFO を通知（noice が既定メッセージを隠すため明示）
- **treesitter fold の再適用** — 各バッファで非同期解析後に fold（全展開）を確実に有効化
- **言語別インデント** — python / go は 4、それ以外はグローバルの 2
- **文章向け折り返し** — markdown / text / gitcommit では wrap + linebreak + breakindent を有効化

---

## 構成とメンテナンス

### 適用

```bash
# 会社 PC
nix run home-manager -- switch --flake '.#hiraoku.shinichi@PC-05481'
```

`~/.config/nvim` は `modules/nvim/` を **recursive symlink** したもの（各ファイルが nix ストアへの読み取り専用 symlink）。ディレクトリ自体は実体なので lazy.nvim が `lazy-lock.json` を書き込める。設定更新のたびに `vim.loader` の luac キャッシュを破棄する activation が走る（nix ストアの mtime 固定でキャッシュが腐るのを防ぐ）。

### プラグインの追加・更新

- **追加**: `modules/nvim/lua/plugins/` に spec を置く → switch
- **更新**: `:Lazy update`（ランタイムで `~/.config/nvim/lazy-lock.json` が更新される）
- **ピンをリポジトリへ反映**: `~/.config/nvim/lazy-lock.json` を `modules/nvim-seeds/lazy-lock.json` へコピーしてコミット（新規マシンはこの seed から初回コピーされる）

### スペル辞書

- native spell の追加語（`zg`/`zw`）は書き込み可能な **`~/.local/share/nvim/spell/custom.utf-8.add`** に入る（`~/.config/nvim` は読み取り専用のため）
- リポジトリへ永続化するには、そのファイルの差分を `modules/nvim/dic/custom.utf-8.add`（seed）へ手動コピーしてコミット
- cspell の無視単語は `modules/nvim/dic/custom-words.txt` に直接追記
- 詳細は `modules/nvim/dic/README.md`

### ランタイム依存（Nix で供給済み）

`programs.neovim.extraPackages` で以下を宣言: C コンパイラ（treesitter パーサー / telescope-fzf-native のビルド用）・`gnumake`・`tree-sitter`。画像表示用の ImageMagick は `common.nix` で導入。
