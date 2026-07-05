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
4. `gh pr create --base main` で ready-for-review PR を作成 (`.github/pull_request_template.md` が自動で適用される)
5. 自己レビューの後、GitHub 上でマージ

draft PR は明示的に依頼された場合だけ作成する。通常は `--draft` を付けない。

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

`GH_TOKEN=$(gh auth token -u s-hiraoku)` はコマンド実行時だけ token を環境変数に渡すための書き方。token の値をファイルやコミットメッセージに残さない。

## 公開リポジトリとしての確認

このリポジトリは public。コミット前に以下を確認する。

```bash
git status --short
git diff --check
git diff --cached
rg -n "BEGIN (RSA|OPENSSH|EC|DSA|PRIVATE)|github_pat_|ghp_[A-Za-z0-9_]+|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}" .
rg -n "(password|passwd|secret|token|api[_-]?key|private[_-]?key)" .
```

`secrets/secrets.yaml` は sops 暗号化済みなら Git 管理してよい。age の秘密鍵、復号済み secrets、証明書、`.env`、API token はコミットしない。詳細は `docs/public-repo.md`。
