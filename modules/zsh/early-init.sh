# Ghostty ではマルチプレクサを自動起動しない。プレーンな shell で開き、
# 必要に応じて自分で `tmux` または `herdr` を起動する (両方インストール済み)。
# tmux の設定は modules/tmux.nix、herdr の設定は modules/herdr.nix に残してある。
# (以前はここで `exec tmux new-session` して Ghostty=常に tmux にしていたが、
#  herdr と併用したいため自動起動を廃止した。)

# Powerlevel10k instant prompt — disabled to avoid rendering artifacts in tmux.
# p10k's cached prompt replay conflicts with tmux's screen buffer management,
# causing double-drawn prompts with stray characters.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
