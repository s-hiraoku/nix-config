# Auto-start tmux in Ghostty (skip in nested tmux, VSCode, etc.)
# MUST run before p10k instant prompt — p10k redirects file descriptors,
# which breaks exec tmux and causes Ghostty to crash on launch.
if [[ -n "$GHOSTTY_RESOURCES_DIR" && -z "$TMUX" && -z "$VSCODE_PID" && -z "$INSIDE_EMACS" ]]; then
  if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
  _last=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -E '^[0-9]+$' | sort -n | tail -1)
  _next=$(( ${_last:-0} + 1 ))
  exec tmux new-session -s "$_next"
fi

# Powerlevel10k instant prompt — disabled to avoid rendering artifacts in tmux.
# p10k's cached prompt replay conflicts with tmux's screen buffer management,
# causing double-drawn prompts with stray characters.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
