# nix-config

## Git push

このリポジトリは個人アカウント `s-hiraoku` のものなので、プッシュ時は `-c` オプションで一時的にアカウントを指定する。

```bash
GH_TOKEN=$(gh auth token -u s-hiraoku) git push origin main
```
