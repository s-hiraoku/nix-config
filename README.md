# nix-config

Nix Home Manager による開発環境の構成管理。

## 構成

```
nix-config/
├── flake.nix              # 依存関係と環境の定義
├── flake.lock             # 依存関係のバージョン固定
└── modules/
    ├── common.nix         # 共通設定（パッケージ、git 等）
    ├── personal.nix       # 個人用（git email, ghq パス）
    ├── work.nix           # 会社用（git email, ghq パス）
    ├── tmux.nix           # tmux 設定
    ├── lazygit.nix        # lazygit 設定
    ├── zsh.nix            # zsh 設定
    ├── neovim.nix         # neovim 設定
    ├── ghostty.nix        # ghostty 設定
    ├── nvim/              # neovim Lua ファイル
    ├── zsh/               # zsh スクリプト
    └── scripts/           # ユーティリティスクリプト
```

## セットアップ

### 1. Nix のインストール

```sh
sh <(curl -L https://nixos.org/nix/install)
```

インストール後、ターミナルを再起動する。

### 2. リポジトリのクローンと適用

```sh
git clone https://github.com/s-hiraoku/nix-config.git
cd nix-config
```

個人 PC の場合:

```sh
home-manager switch --flake '.#hiraoku.shinichi'
```

会社 PC の場合:

```sh
home-manager switch --flake '.#hiraoku.shinichi@PC-05481'
```

## 環境の切り替え

同じ PC で環境を切り替えたい場合は、対応するコマンドを再実行するだけで切り替わる。

```sh
# 個人用に切り替え
home-manager switch --flake '.#hiraoku.shinichi'

# 会社用に切り替え
home-manager switch --flake '.#hiraoku.shinichi@PC-05481'
```

## アップデート

### Nix パッケージの更新

`flake.lock` に記録されている依存関係を最新にする:

```sh
nix flake update
home-manager switch --flake '.#hiraoku.shinichi'
```

### 設定変更の適用

`modules/` 内のファイルを編集した後:

```sh
home-manager switch --flake '.#hiraoku.shinichi'
```

## 拡張方法

### パッケージを追加する

`modules/common.nix` の `home.packages` にパッケージを追加:

```nix
home.packages = with pkgs; [
  fzf
  ripgrep
  # ここに追加
  jq
  wget
];
```

パッケージは [Nix Packages Search](https://search.nixos.org/packages) で検索できる。

### プログラムの設定を追加する

`modules/common.nix` に `programs.<name>` ブロックを追加:

```nix
programs.bat = {
  enable = true;
  config = {
    theme = "TwoDark";
  };
};
```

対応プログラムは [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml) を参照。

### 環境固有の設定を追加する

個人用のみの設定は `modules/personal.nix`、会社用のみの設定は `modules/work.nix` に追加する。

### 新しい環境を追加する

`flake.nix` に `homeConfigurations` を追加し、対応するモジュールを作成:

```nix
# flake.nix
homeConfigurations."username@server" = home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    ./modules/common.nix
    ./modules/server.nix
  ];
};
```

```nix
# modules/server.nix
{ config, pkgs, ... }:

{
  home.username = "username";
  home.homeDirectory = "/home/username";

  # サーバー固有の設定
}
```

### Neovim プラグインを追加する

`modules/nvim/plugins/` に Lua ファイルを追加し、`modules/neovim.nix` に参照を追加:

```lua
-- modules/nvim/plugins/example.lua
return {
  "author/plugin-name",
  opts = {},
}
```

```nix
-- modules/neovim.nix に追加
xdg.configFile."nvim/lua/plugins/example.lua".source = ./nvim/plugins/example.lua;
```

## 秘密情報の管理 (sops + age)

API キーなどの秘密情報は sops で暗号化して Git 管理している。

### 初回セットアップ（新しい PC）

age の鍵を生成:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

表示された公開鍵を `.sops.yaml` に追加して、秘密情報を再暗号化:

```sh
# .sops.yaml に新しい公開鍵を追加した後
sops updatekeys secrets/secrets.yaml
```

### 秘密情報の追加・編集

```sh
sops secrets/secrets.yaml
```

エディタが開くので、平文で編集して保存すると自動で暗号化される。

### 仕組み

- `secrets/secrets.yaml` — 暗号化された秘密情報（Git 管理）
- `~/.config/sops/age/keys.txt` — 復号用の秘密鍵（Git 管理外）
- `load-secrets` — シェル起動時に復号して環境変数に設定
- `.zshrc` に `eval "$(load-secrets)"` を追加して利用

### エラー時の挙動

`load-secrets` は以下の場合、シェル起動時に警告を表示する:

- `secrets/secrets.yaml` が存在しない
- `sops` コマンドが見つからない
- `~/.config/sops/age/keys.txt`（age の秘密鍵）が存在しない
- 復号に失敗した（鍵の不一致など）

## トラブルシューティング

### 既存の設定ファイルと衝突する

home-manager が既存ファイルとの衝突を検知した場合、既存ファイルをバックアップしてから再実行する:

```sh
mv ~/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf.bak
home-manager switch --flake '.#hiraoku.shinichi'
```

### 前の状態に戻したい

home-manager は世代管理をしている:

```sh
# 世代の一覧
home-manager generations

# 前の世代に戻す
/nix/var/nix/profiles/per-user/$USER/home-manager-<N>-link/activate
```

または設定の変更を git で戻して再適用:

```sh
git revert HEAD
home-manager switch --flake '.#hiraoku.shinichi'
```
