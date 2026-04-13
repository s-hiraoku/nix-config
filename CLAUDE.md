# nix-config

## Git push

### 個人 PC

通常通り `git push` で OK。

### 会社 PC

会社 PC では別の GitHub アカウントにログインしているため、個人アカウント `s-hiraoku` のトークンを一時的に指定してプッシュする。

```bash
GH_TOKEN=$(gh auth token -u s-hiraoku) git push origin main
```
