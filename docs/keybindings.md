# キーバインド全体マップ

Ghostty / herdr / tmux の 3 層で操作体系が分かれている。このリポジトリでの設計方針と、層をまたいだ対応表をここにまとめる。

## 設計方針

- **Ghostty ネイティブ**(`alt+*` / `ctrl+p` / `ctrl+t` / `cmd+*`)は「マルチプレクサを使っていない時」の分割・タブ操作。
- **herdr / tmux**(prefix `Ctrl-a`)はマルチプレクサ内の操作。prefix は両者で共通にしてあり、どちらを起動しても同じ指の動きで使える。
- 方向操作は全層で **vim 風 `h/j/k/l`** に統一。
- herdr と tmux は同時に使わない前提(どちらも prefix が `Ctrl-a` のため、ネストすると prefix が衝突する)。

## 対応表

| 操作 | Ghostty (素の shell) | herdr / tmux (`Ctrl-a` prefix) |
|---|---|---|
| 左右分割 | `cmd+d` / `alt+n` | `prefix \|`(または `prefix v`) |
| 上下分割 | `cmd+shift+d` | `prefix -` |
| ペイン移動 | `alt+h/j/k/l` または `ctrl+p > h/j/k/l` | `prefix h/j/k/l` |
| ペインズーム | `alt+f` | `prefix z` |
| ペインリサイズ | `ctrl+,` `ctrl+.` `ctrl+;` `ctrl+'` | tmux: `prefix H/J/K/L`(リピート可)<br>herdr: `prefix Shift-r` でリサイズモード |
| 新規タブ/ウィンドウ | `cmd+t` / `ctrl+t > n` | `prefix c` |
| 次/前タブ | `ctrl+t > l` / `ctrl+t > h` | `prefix n` / `prefix p` |
| 番号でタブ移動 | `alt+1..9` / `ctrl+t > 1..9` | `prefix 1..9` |
| セッション/ワークスペース切替 | — | `prefix s`(fzf) |
| セッション/ワークスペース作成 | — | `prefix S`(現在パス名) |
| detach | — | herdr: `prefix q` / tmux: `prefix d` |
| コピーモード | —(スクロールバック選択) | `prefix [`(vi keymap、`y` で pbcopy) |
| 設定リロード | `cmd+shift+,` | `prefix r` |
| Quick Terminal | `ctrl+\``(グローバル) | — |

## 各層の詳細

- Ghostty: `modules/ghostty.nix`
- herdr: `modules/herdr/config.toml`、運用メモは [herdr.md](herdr.md)
- tmux: `modules/tmux.nix`、運用メモは [tmux.md](tmux.md)

## テーマ

見た目は Kanagawa Wave に統一する。

| 層 | テーマ | 定義場所 |
|---|---|---|
| Ghostty | Kanagawa Wave(同梱テーマ) | `modules/ghostty.nix` |
| Neovim | kanagawa.nvim (Wave) | `modules/nvim/lua/plugins/kanagawa.lua` |
| tmux | Kanagawa 風パレット(手書き) | `modules/tmux.nix` |
| herdr | catppuccin(**未統一**。Kanagawa テーマが herdr に追加されたら揃える) | `modules/herdr/config.toml` |
