# ランタイムマネージャの役割分担

Volta と mise が両方入っているが、管理対象を分けてあり競合しない。

| マネージャ | 管理対象 | 定義場所 |
|---|---|---|
| Volta | Node 本体、npm/pnpm、グローバル CLI(copilot, playwright-cli, difit 等) | `~/.volta`(Nix 管理外) |
| mise | ruby / erlang / elixir | `modules/common.nix` の `programs.mise`(本体 + zsh 統合)+ `~/.config/mise`(Nix 管理外) |

`modules/zsh/zshrc.sh` では Volta の PATH を `~/.volta/bin` が存在する時だけ追加し、mise は `programs.mise.enableZshIntegration` で有効化している(以前は zshrc.sh に `eval "$(mise activate zsh)"` を手書きしていた)。mise はプロジェクトに `mise.toml` / `.mise.toml` があれば precmd フックで PATH の先頭に差し込むため、プロジェクト内では mise が勝つ。

## mise の trust について

mise は `mise.toml` を**絶対パス単位**で信頼登録する(記録先は `~/.local/state/mise/trusted-configs`)。信頼されていない設定は読み込まれず、ディレクトリに入るたびにエラーが出る。

herdr のワークツリー(`~/.herdr/worktrees/<repo>/worktree-green-cloud-ed8b` のようにランダムな名前で毎回生成される)は、元のクローンを trust 済みでも別パスなので常に未信頼になる。`mise.toml` を持つ repo ではワークツリーに入るたびにエラーが出るため、その場で信頼させる:

```sh
mt        # = mise trust (modules/common.nix の home.shellAliases)
```

関連コマンド:

```sh
mise trust --show      # カレントから親までの信頼状態を表示
mise trust --untrust   # 信頼を取り消す(次回からまた確認される)
mise trust --ignore    # この設定を今後無視する(エラーも出さない)
```

### なぜ `MISE_TRUSTED_CONFIG_PATHS` でツリーごと信頼させないのか

`~/.herdr/worktrees` 配下をまとめて信頼させれば `mt` は不要になるが、**意図的に採用していない**。

`mise trust` は「その設定を dangerous features 有効で parse する」ことを意味し、`mise trust --help` は対象として環境変数・テンプレート・`path:` プラグインバージョンを挙げている。実際、信頼された `mise.toml` に

```toml
[env]
_.source = "./evil.sh"
```

があると、zsh 統合の chpwd フック経由で `cd` するだけで `evil.sh` が実行される(PoC で確認済み)。

ワークツリーは他者が書いたブランチから作ることもあり、さらに herdr はコーディングエージェントを動かすためのツールなので、ワークツリー内のエージェントが `mise.toml` を書けばエージェントの許可プロンプトを迂回して対話シェル側でコード実行できることになる。ワークツリー 1 つあたり `mt` 1 回の手間を払って per-config trust を維持する。

経緯は PR #38 を参照。

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
