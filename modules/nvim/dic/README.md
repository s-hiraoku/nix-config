# ユーザー辞書 (spell)

このディレクトリにスペルチェック用のユーザー辞書を置く。スペルチェックは2系統:

1. **native spell**（コメント/文字列・markdown 対象）
2. **cspell**（nvim-lint 経由。コードの識別子＝変数名・JSX なども対象、VSCode 風）

## ファイル

| ファイル | 用途 |
|---------|------|
| `custom.utf-8.add` | native spell の無視単語リスト（`zg` で追記される）。1 行 1 単語 |
| `custom.utf-8.add.spl` | nvim が自動生成するコンパイル済み（コミット不要） |
| `cspell.json` | cspell のグローバル設定（nvim-lint が `--config` で参照） |
| `custom-words.txt` | cspell の無視単語リスト。1 行 1 単語。手で追記する |

## native spell の使い方

カーソルを波線の単語に合わせて:

| キー | 動作 |
|------|------|
| `zg` | カーソル下の単語を「正しい単語」として `custom.utf-8.add` に登録 |
| `zw` | 「誤り」として登録 |
| `zug` | 直前の `zg` を取り消し |
| `]s` / `[s` | 次/前の typo へ移動 |
| `z=` | 修正候補を表示 |

`opt.spellfile`（`lua/config/options.lua`）でこのファイルを参照している。
