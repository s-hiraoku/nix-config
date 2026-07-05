# nix-config

Nix Home Manager で macOS の開発環境を管理するリポジトリ。

このリポジトリは公開リポジトリとして運用しているため、秘密情報は sops + age で暗号化し、平文の鍵・証明書・トークンはコミットしない。

## 現在の方針

- Home Manager で dotfiles と CLI ツールを共通管理する。
- 設定は **account** と **host** の 2 軸で分ける。
- Herdr は会社環境・個人環境で共通設定にする。
- Ghostty 起動時に Herdr は自動起動しない。必要な時だけ手動で `herdr` を実行する。
- Herdr 本体は Homebrew で入れ、Nix では設定ファイルだけ管理する。
- Neovim は Kanagawa Wave を標準テーマにする。

## 構成

`flake.nix` で `common + accounts/<name> + hosts/<name>` を組み合わせて Home Manager 構成を作る。

```
nix-config/
├── flake.nix                    # Home Manager 構成の組み立て
├── flake.lock                   # nixpkgs / home-manager の固定
├── modules/
│   ├── common.nix               # 全環境共通
│   ├── accounts/                # アカウント単位の差分
│   │   ├── personal.nix         # 個人用 git email 等
│   │   └── work.nix             # 会社用 git email / JDK / lazygit 設定等
│   ├── hosts/                   # 物理マシン単位の差分
│   │   ├── personal-mbp.nix     # 個人 MacBook 固有設定
│   │   └── work-pc05481.nix     # 会社 PC 固有設定
│   ├── herdr.nix                # Herdr config.toml の配置
│   ├── herdr/config.toml        # Herdr キーバインド
│   ├── ghostty.nix              # Ghostty 設定
│   ├── lazygit.nix              # lazygit 設定
│   ├── neovim.nix               # Neovim Home Manager 設定
│   ├── nvim/                    # Neovim Lua 設定
│   ├── nvim-seeds/              # lazy-lock / spell seed
│   ├── zsh.nix                  # zsh Home Manager 設定
│   ├── zsh/                     # zsh 初期化スクリプト
│   └── scripts/                 # 補助スクリプト
├── docs/
│   ├── herdr.md                 # Herdr 運用メモ
│   ├── nvim.md                  # Neovim 設定マニュアル
│   └── public-repo.md           # 公開リポジトリとしての注意
└── secrets/
    └── secrets.yaml             # sops で暗号化した秘密情報
```

## account / host の分け方

| 構成 | account | host |
|---|---|---|
| 個人 MacBook | `modules/accounts/personal.nix` | `modules/hosts/personal-mbp.nix` |
| 会社 PC | `modules/accounts/work.nix` | `modules/hosts/work-pc05481.nix` |

- **account**: マシンを買い替えても変わらない設定。例: git email、仕事用/個人用の言語やツール設定。
- **host**: 物理マシンに依存する設定。例: 外付け SSD のパス、社内ネットワーク用 CA 証明書の場所。
- **common**: 個人・会社の両方で使う設定。例: Herdr、Neovim、zsh、Ghostty、共通 CLI。

判断に迷ったら「同じアカウントで新しい Mac に移っても使い回すか」で分ける。使い回すなら `accounts/`、そのマシン固有なら `hosts/`。

## セットアップ

### 1. Nix をインストール

```sh
sh <(curl -L https://nixos.org/nix/install)
```

インストール後、ターミナルを再起動する。

### 2. リポジトリを取得

```sh
git clone https://github.com/s-hiraoku/nix-config.git
cd nix-config
```

### 3. Home Manager を適用

個人 MacBook:

```sh
home-manager switch --flake '.#hiraoku.shinichi'
```

会社 PC:

```sh
home-manager switch --flake '.#hiraoku.shinichi@PC-05481'
```

`home-manager` がまだ PATH にない場合:

```sh
nix run home-manager -- switch --flake '.#hiraoku.shinichi'
nix run home-manager -- switch --flake '.#hiraoku.shinichi@PC-05481'
```

## 日常運用

### 設定変更を適用する

```sh
home-manager switch --flake '.#hiraoku.shinichi'
```

会社 PC:

```sh
home-manager switch --flake '.#hiraoku.shinichi@PC-05481'
```

### PR マージ後にこの PC へ反映する

```sh
cd ~/nix-config
git pull --ff-only
home-manager switch --flake '.#hiraoku.shinichi'
```

サンドボックス環境などで Nix の cache 書き込みが制限される場合:

```sh
XDG_CACHE_HOME=/private/tmp/codex-nix-cache home-manager switch --flake '.#hiraoku.shinichi'
```

## Herdr

Herdr は tmux からの移行先として共通設定にしている。会社環境・個人環境のどちらにも `modules/common.nix` 経由で入る。

本体は Nix flake では入れない。Darwin では nixpkgs 版 Herdr のソースビルドが失敗するため、現時点では Homebrew で導入し、設定だけ Home Manager で管理する。

```sh
brew install herdr
```

起動:

```sh
herdr
```

Ghostty 起動時の自動 Herdr 起動は無効。プレーンな shell を開いてから、必要な時だけ手動で `herdr` を起動する。

主要キー:

| Key | 動作 |
|---|---|
| `Ctrl-a ?` | ヘルプ |
| `Ctrl-a r` | 設定リロード |
| `Ctrl-a \|` / `Ctrl-a Shift-\` / `Ctrl-a v` | 左右分割 |
| `Ctrl-a -` | 上下分割 |
| `Ctrl-a h/j/k/l` | ペイン移動 |
| `Ctrl-a z` | ズーム |
| `Ctrl-a c` | 新規タブ |
| `Ctrl-a n/p` | 次/前タブ |
| `Ctrl-a 1..9` | 番号でタブ移動 |
| `Ctrl-a Shift-r` | リサイズモード |
| `Ctrl-a s` | fzf でワークスペース切替 |
| `Ctrl-a S` | 現在パス名でワークスペース作成 |
| `Ctrl-a q` | detach |

詳細は [docs/herdr.md](docs/herdr.md)。

## Ghostty / zsh

- Ghostty は Home Manager で設定する。
- Ghostty shell integration は Herdr 外でだけ読み込む。
- Herdr 内では Powerlevel10k のマルチライン枠を無効化して表示崩れを避ける。
- `fzf` は Home Manager の `programs.fzf.enableZshIntegration` で管理する。
- `Ctrl-r` は zsh の `redisplay` ではなく `fzf-history-widget` に明示的に bind する。

`Ctrl-r` が効かない時の確認:

```sh
bindkey '^R'
```

期待値:

```text
"^R" fzf-history-widget
```

## Neovim

Neovim は `modules/nvim/` の Lua 設定を Home Manager で `~/.config/nvim` に配置する。

主な方針:

- プラグインマネージャは lazy.nvim。
- カラースキームは Kanagawa Wave。
- Alpha dashboard のロゴは `ascii.nvim` の `art.text.neovim.sharp`。
- lualine も Kanagawa に合わせる。
- 画像表示は Ghostty の Kitty graphics protocol と ImageMagick を使う。
- plugin lock は `modules/nvim-seeds/lazy-lock.json` を seed として管理する。

詳細なキーバインド、LSP、フォーマット、プラグイン一覧は [docs/nvim.md](docs/nvim.md)。

### Neovim プラグインを追加する

`modules/nvim/lua/plugins/` に lazy.nvim spec を追加する。

```lua
return {
  "author/plugin-name",
  opts = {},
}
```

必要に応じて `home-manager switch` し、Neovim で `:Lazy sync` を実行する。lock をリポジトリに反映する場合は `~/.config/nvim/lazy-lock.json` を `modules/nvim-seeds/lazy-lock.json` にコピーしてコミットする。

## Nix パッケージを更新する

Nix で管理しているツールのバージョンは `flake.lock` に固定された nixpkgs のリビジョンに紐づく。

| やりたいこと | コマンド |
|---|---|
| nixpkgs だけ更新 | `nix flake update nixpkgs` |
| 全 input を更新 | `nix flake update` |
| 設定を適用 | `home-manager switch --flake '.#hiraoku.shinichi'` |

標準フロー:

```sh
nix flake update nixpkgs
home-manager switch --flake '.#hiraoku.shinichi'
git diff
```

会社 PC での反映:

```sh
git pull --ff-only
home-manager switch --flake '.#hiraoku.shinichi@PC-05481'
```

注意:

- nixpkgs の `nixos-unstable` は更新タイミングにより、特定ツールのバージョンが期待より古い場合がある。
- 更新後は `--version` で必要なツールのバージョンを確認する。
- 問題があれば `flake.lock` の変更コミットを `git revert` して戻せる。

## 秘密情報

秘密情報は sops + age で暗号化して Git 管理する。age の秘密鍵、復号済み secrets、証明書、API token はコミットしない。

初回セットアップ:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

表示された age 公開鍵を `.sops.yaml` に追加し、既存 secrets を再暗号化する。

```sh
sops updatekeys secrets/secrets.yaml
```

秘密情報の編集:

```sh
sops secrets/secrets.yaml
```

仕組み:

- `secrets/secrets.yaml`: sops で暗号化した secrets。Git 管理対象。
- `~/.config/sops/age/keys.txt`: 復号用の秘密鍵。Git 管理外。
- `load-secrets`: shell 起動時に `secrets/secrets.yaml` を復号し、環境変数として export する。

公開リポジトリとしての注意点は [docs/public-repo.md](docs/public-repo.md)。

## 拡張方法

### 共通パッケージを追加する

`modules/common.nix` の `home.packages` に追加する。

```nix
home.packages = with pkgs; [
  ripgrep
  fd
  jq
];
```

パッケージは [Nix Packages Search](https://search.nixos.org/packages) で探す。

### account 固有設定を追加する

- 個人アカウント全体に効く設定: `modules/accounts/personal.nix`
- 会社アカウント全体に効く設定: `modules/accounts/work.nix`

### host 固有設定を追加する

特定マシンだけで必要な設定は `modules/hosts/<host>.nix` に置く。

新しい個人 PC を追加する例:

```nix
"hiraoku.shinichi@MacBook-Pro-2" = mkHome [
  ./modules/accounts/personal.nix
  ./modules/hosts/personal-mbp2.nix
];
```

## トラブルシューティング

### 既存の設定ファイルと衝突する

Home Manager が既存ファイルとの衝突を検知した場合は、既存ファイルを退避してから再実行する。

```sh
mv ~/.config/herdr/config.toml ~/.config/herdr/config.toml.bak
home-manager switch --flake '.#hiraoku.shinichi'
```

### 前の Home Manager 世代に戻す

```sh
home-manager generations
/nix/var/nix/profiles/per-user/$USER/home-manager-<N>-link/activate
```

設定変更自体を戻す場合:

```sh
git revert HEAD
home-manager switch --flake '.#hiraoku.shinichi'
```

### Herdr の縦分割が効かない

`|` は端末や keyboard protocol によって `Shift-\` として届くことがある。設定では以下を同じ左右分割に割り当てている。

- `Ctrl-a |`
- `Ctrl-a Shift-\`
- `Ctrl-a v`

まず `Ctrl-a ?` で Herdr 側の実際のキーバインド表示を確認し、`Ctrl-a r` で設定を再読み込みする。

### fzf の `Ctrl-r` が効かない

`bindkey '^R'` が `"^R" redisplay` を返す場合、fzf の zsh integration が読み込まれていないか、後続設定で上書きされている。

このリポジトリでは `modules/common.nix` と `modules/zsh/zshrc.sh` で `fzf-history-widget` を明示的に有効化している。反映後に新しい shell を開いて再確認する。

## 参考

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Packages Search](https://search.nixos.org/packages)
- [NixOS options / Home Manager options](https://nix-community.github.io/home-manager/options.xhtml)
