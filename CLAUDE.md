# nix-config

## Git ワークフロー

`main` への直接 push は禁止。すべての変更は feature branch を切って PR 経由で取り込む。

### ブランチ命名

Conventional Commits のプレフィックスと揃える。`<概要>` はケバブケース (例: `feature/neovim-lsp`)。

- `feature/<概要>` — 新機能、新パッケージ、新モジュールの追加
- `fix/<概要>` — バグ修正、設定の破綻修正
- `hotfix/<概要>` — 今すぐ直さないと環境が使えない緊急修正
- `refactor/<概要>` — 振る舞いを変えない内部改善
- `docs/<概要>` — README、CLAUDE.md などドキュメントのみ
- `chore/<概要>` — `flake.lock` 更新や雑務

### コミットメッセージ

Conventional Commits 形式。スコープがある場合は付ける。例:

- `feat(zsh): autosuggestion を追加`
- `fix(work): Cato Networks 証明書パスの存在チェックを追加`
- `chore: flake.lock を更新`

### フロー

1. `git switch -c <branch>` でブランチを切る
2. 作業してコミット
3. push してブランチをリモートに上げる
4. `gh pr create --base main` で PR を作成 (`.github/pull_request_template.md` が自動で適用される)
5. 自己レビューの後、GitHub 上でマージ

### push / PR 作成コマンド

#### 個人 PC

```bash
git push -u origin <branch>
gh pr create --base main
```

#### 会社 PC

会社 PC では別の GitHub アカウントにログインしているため、個人アカウント `s-hiraoku` のトークンを一時的に指定する必要がある。**push と `gh pr create` の両方**で必要。

```bash
GH_TOKEN=$(gh auth token -u s-hiraoku) git push -u origin <branch>
GH_TOKEN=$(gh auth token -u s-hiraoku) gh pr create --base main
```
