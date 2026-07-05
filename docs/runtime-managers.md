# ランタイムマネージャの役割分担

Volta と mise が両方入っているが、管理対象を分けてあり競合しない。

| マネージャ | 管理対象 | 定義場所 |
|---|---|---|
| Volta | Node 本体、npm/pnpm、グローバル CLI(copilot, playwright-cli, difit 等) | `~/.volta`(Nix 管理外) |
| mise | ruby / erlang / elixir | `modules/common.nix` の `home.packages`(本体のみ)+ `~/.config/mise`(Nix 管理外) |

`modules/zsh/zshrc.sh` では Volta の PATH を `~/.volta/bin` が存在する時だけ追加し、mise は `mise activate zsh` で有効化している。mise はプロジェクトに `.mise.toml` があれば precmd フックで PATH の先頭に差し込むため、プロジェクト内では mise が勝つ。

## Node を mise へ一本化する場合の手順

Volta を廃止して mise に寄せたくなったら、以下の順で移行する。**順番を守らないと Node が一時的に消える。**

1. 現在の Volta 管理ツールを控える。

   ```sh
   volta list
   ```

2. mise で Node を入れる(バージョンは volta list の表示に合わせる)。

   ```sh
   mise use -g node@24
   ```

3. グローバル CLI を mise 側で再インストールする。

   ```sh
   mise use -g npm:pnpm npm:@github/copilot npm:@playwright/cli npm:difit npm:opensrc
   ```

4. 新しい shell で `which node` / `which pnpm` が mise の shim を指すことを確認する。

5. `modules/zsh/zshrc.sh` の Volta ブロックを削除して `home-manager switch`。

6. 動作確認後に `~/.volta` を削除する。

   ```sh
   rm -rf ~/.volta
   ```

## 注意

- 会社 PC など別マシンでは Volta / mise の導入状況が違う可能性がある。zshrc は存在チェックで分岐しているので、入っていないマシンでは単に無視される。
- Bun(`~/.bun`)・cargo(`~/.cargo`)も同様に存在チェック付きで PATH に入る。
