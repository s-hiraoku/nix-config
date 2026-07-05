# 公開リポジトリ運用メモ

このリポジトリは public で運用する。便利さのために dotfiles を公開しているが、秘密情報と公開メタデータは分けて扱う。

## 現状のチェック結果

現在の tree では、以下のような平文 secrets は見つかっていない。

- GitHub token
- OpenAI API key
- AWS access key
- private key
- PEM private key
- 平文 API token

`secrets/secrets.yaml` は sops で暗号化済み。age の公開鍵と secret 名は見えるが、値は暗号化されている。

## 公開されているメタデータ

次の情報は設定の都合でリポジトリ上に見える。

- 個人/会社の git email
- host 構成名
- macOS の home directory path
- 個人環境の ghq path
- 会社ネットワーク用 CA 証明書の配置先
- sops の age recipient public key
- encrypted secrets の key 名

これらは「秘密鍵・トークン」ではないが、public repo では個人情報・所属・環境情報として扱う。

## 判断基準

public に置いてよいもの:

- 再現可能な設定
- 公開されても権限を与えない ID
- 暗号化済み secrets
- age recipient の公開鍵
- ツールの設定やキーバインド

public に置かないもの:

- API token
- password
- private key
- age secret key
- 証明書の秘密鍵
- 復号済み secrets
- `.env`
- 顧客名・案件名・社内 URL など業務上の非公開情報

## sops + age

暗号化 secrets:

```sh
sops secrets/secrets.yaml
```

age 秘密鍵:

```text
~/.config/sops/age/keys.txt
```

`keys.txt` は絶対にコミットしない。

新しい PC を追加する場合:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

表示された公開鍵だけを `.sops.yaml` に追加し、既存 secrets を再暗号化する。

```sh
sops updatekeys secrets/secrets.yaml
```

## 誤コミット防止

`.gitignore` で以下を除外する。

- `.env` / `.env.*`
- `*.key`
- `*.pem`
- `*.p12`
- `*.pfx`
- `keys.txt`
- `*.age-key`
- `certs/`
- `secrets/*.dec.yaml`
- `secrets/*.plain.yaml`
- `secrets/*.decrypted.*`

コミット前に見るもの:

```sh
git status --short
git diff --check
git diff --cached
```

秘密情報らしい文字列を確認する例:

```sh
rg -n "BEGIN (RSA|OPENSSH|EC|DSA|PRIVATE)|github_pat_|ghp_[A-Za-z0-9_]+|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}" .
rg -n "(password|passwd|secret|token|api[_-]?key|private[_-]?key)" .
```

## Git history

current tree に secrets がなくても、過去コミットに残っていれば public repo では見える。

履歴まで確認する例:

```sh
git grep -n -I -E "BEGIN (RSA|OPENSSH|EC|DSA|PRIVATE)|github_pat_|ghp_[A-Za-z0-9_]+|AKIA[0-9A-Z]{16}" $(git rev-list --all)
```

もし平文 secret を過去にコミットしていた場合:

1. その secret を失効・再発行する。
2. 必要なら history rewrite を行う。
3. GitHub の secret scanning alert を確認する。

history rewrite は clone 済み環境に影響するため、実行前に方針を決める。

## 今後の改善候補

- gitleaks などの secret scanner を CI に追加する。
- work 固有で公開したくない設定が増えたら private overlay repo に分離する。
- public に出したくない email は GitHub noreply address に切り替える。
