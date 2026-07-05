# Herdr 運用メモ

tmux から Herdr へ移行した後の運用メモ。

## 方針

- Herdr 設定は `modules/herdr/config.toml` で管理する。
- Home Manager は `~/.config/herdr/config.toml` に symlink を張る。
- 会社環境・個人環境の両方で同じ設定を使う。
- Ghostty 起動時に Herdr は自動起動しない。
- Herdr 本体は Homebrew で入れる。

## なぜ本体を Nix flake で入れないか

nixpkgs に Herdr は存在するが、Darwin では vendored `libghostty-vt` の Zig build が Apple SDK を見つけられず失敗する。

現時点では aarch64-darwin の実用上、Nix で本体を管理するより Homebrew で入れた方が安定する。Nix 側は `config.toml` と `jq` などの補助ツールだけを管理する。

upstream または nixpkgs 側で Darwin build が直ったら、`flake.nix` の overlay で Herdr 本体も Nix 管理に戻す。

## インストール

```sh
brew install herdr
```

設定を反映:

```sh
home-manager switch --flake '.#hiraoku.shinichi'
```

会社 PC:

```sh
home-manager switch --flake '.#hiraoku.shinichi@PC-05481'
```

## 起動

Ghostty を普通に起動し、必要な時に手動で実行する。

```sh
herdr
```

自動起動しない理由:

- Ghostty 単体の shell を残しておく方がトラブルシュートしやすい。
- Herdr の起動失敗が Ghostty 起動失敗に直結しない。
- 会社環境・個人環境で挙動を揃えられる。

## キーバインド

prefix は `Ctrl-a`。

| Key | 動作 |
|---|---|
| `Ctrl-a ?` | Herdr のヘルプ |
| `Ctrl-a ,` | 設定 |
| `Ctrl-a r` | 設定リロード |
| `Ctrl-a \|` | 左右分割 |
| `Ctrl-a Shift-\` | 左右分割 |
| `Ctrl-a v` | 左右分割の代替 |
| `Ctrl-a -` | 上下分割 |
| `Ctrl-a h` | 左ペインへ |
| `Ctrl-a j` | 下ペインへ |
| `Ctrl-a k` | 上ペインへ |
| `Ctrl-a l` | 右ペインへ |
| `Ctrl-a z` | ズーム |
| `Ctrl-a c` | 新規タブ |
| `Ctrl-a n` | 次タブ |
| `Ctrl-a p` | 前タブ |
| `Ctrl-a 1..9` | 番号でタブ移動 |
| `Ctrl-a Shift-r` | リサイズモード |
| `Ctrl-a [` | コピーモード |
| `Ctrl-a q` | detach |
| `Ctrl-a s` | fzf でワークスペース切替 |
| `Ctrl-a S` | 現在パス名で新規ワークスペース |

## 左右分割について

Herdr の `split_vertical` は左右分割を意味する。tmux の `split-window -h` に相当する。

`|` は端末によって `Shift-\` として届くため、設定では以下を同じ動作にしている。

```toml
split_vertical = ["prefix+|", "prefix+shift+backslash", "prefix+v"]
```

動かない時は以下を確認する。

```sh
herdr
# Herdr 内で
# Ctrl-a ?
# Ctrl-a r
```

`Ctrl-a ?` のヘルプに左右分割が出ていれば Herdr 側には設定が読まれている。`Ctrl-a |` が端末でうまく届かない場合は `Ctrl-a v` を使う。

## zsh / Ghostty との関係

`modules/zsh/early-init.sh` では Herdr の自動起動をしない。以前の tmux 自動起動設定は削除済み。

Herdr 内では Powerlevel10k のマルチライン枠を無効化する。Herdr の画面バッファ管理と p10k の枠線描画が噛み合わず、右端の罫線が残ることがあるため。

Ghostty shell integration は Herdr 外でだけ読み込む。Herdr 内では Ghostty の prompt marker が p10k 表示を壊すことがある。

## 未移植・要確認

- copy mode 内の vi 操作と pbcopy 連携は tmux と完全同等ではない。
- Herdr の copy mode とマウス選択の使い分けは実運用で確認する。
- `image.nvim` の Kitty graphics protocol が Herdr 越しで安定するかは継続確認する。
