# Ghostty では Herdr を自動起動しない。プレーンな shell で開き、
# 必要に応じて自分で `herdr` を起動する。
# Herdr の設定は modules/herdr.nix で管理する。
# (以前はここでマルチプレクサを自動起動していたが、Herdr へ移行するにあたり
#  Ghostty 単体でも起動できるようにした。)

# Powerlevel10k instant prompt — マルチプレクサの外でのみ有効化する。
# herdr / tmux 内では p10k の cached prompt 再描画がマルチプレクサの
# スクリーンバッファ管理と衝突し、プロンプトが二重描画・ゴミ文字化する
# ため無効のまま。プレーンな Ghostty shell では体感起動が大きく速くなる。
# 稀に「console output during zsh initialization」警告が出る場合は
# ~/.p10k.zsh で POWERLEVEL9K_INSTANT_PROMPT=quiet を設定する。
if [[ -z "$HERDR_PANE_ID" && -z "$HERDR_ENV" && -z "$TMUX" ]]; then
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi
fi
