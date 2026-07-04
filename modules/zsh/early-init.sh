# Ghostty では Herdr を自動起動しない。プレーンな shell で開き、
# 必要に応じて自分で `herdr` を起動する。
# Herdr の設定は modules/herdr.nix で管理する。
# (以前はここでマルチプレクサを自動起動していたが、Herdr へ移行するにあたり
#  Ghostty 単体でも起動できるようにした。)

# Powerlevel10k instant prompt — disabled to avoid rendering artifacts in Herdr.
# p10k's cached prompt replay conflicts with multiplexer screen buffer management,
# causing double-drawn prompts with stray characters.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
