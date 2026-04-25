# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Nix profile は Homebrew より優先する。
# brew shellenv が /opt/homebrew を PATH 先頭に差し込むので、その後で
# Nix profile を再度前出しして gh / git / ripgrep 等の重複を Nix 側で勝たせる。
if [[ -d "$HOME/.nix-profile/bin" ]]; then
  export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
fi

# Powerlevel10k theme (path set per-machine via P10K_THEME_PATH)
if [[ -n "$P10K_THEME_PATH" && -r "$P10K_THEME_PATH" ]]; then
  source "$P10K_THEME_PATH"
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zsh-autosuggestions, zsh-syntax-highlighting, and completions
# are now managed by home-manager (programs.zsh.autosuggestion / syntaxHighlighting)

# PATH additions
export PATH="$PATH:$HOME/.cache/lm-studio/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export PATH="$PATH:$HOME/Library/Python/3.11/bin"

# Local env
[[ -r "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# MCP (Model Context Protocol) Configuration for Claude Code
export MCP_CONFIG_FILE="$HOME/.config/claude-code/mcp.json"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# ghq-fzf
function ghq-fzf() {
  local repo=$(ghq list | fzf --query "$*" --preview "bat --color=always $(ghq root)/{}/README.md 2>/dev/null || ls -la $(ghq root)/{}")
  if [ -n "$repo" ]; then
    cd "$(ghq root)/$repo"
  fi
}
alias g='ghq-fzf'

# wtp (worktree plus)
if whence -p wtp >/dev/null 2>&1; then
  eval "$(wtp shell-init zsh)"
fi

_wtp_bin() {
  whence -p wtp 2>/dev/null
}

wtpcode() {
  local wtp_cmd
  wtp_cmd=$(_wtp_bin)
  [[ -z "$wtp_cmd" ]] && { echo "wtp not found in PATH" >&2; return 127; }
  code "$($wtp_cmd cd "$1")"
}

wtpghostty() {
  local wtp_cmd
  local target_path

  wtp_cmd=$(_wtp_bin)
  [[ -z "$wtp_cmd" ]] && { echo "wtp not found in PATH" >&2; return 127; }

  target_path=$($wtp_cmd cd "$1") || return 1

  osascript - "$target_path" <<'APPLESCRIPT'
on run argv
  set targetPath to item 1 of argv

  tell application "System Events" to set isRunning to exists process "Ghostty"

  tell application "Ghostty" to activate
  if isRunning then
    delay 0.1
  else
    delay 0.3
  end if

  tell application "System Events"
    keystroke "t" using {command down}
    delay 0.1
    keystroke "cd " & quoted form of targetPath
    key code 36
  end tell
end run
APPLESCRIPT
}

# zoxide
eval "$(zoxide init zsh)"

# Aliases
alias yolo='claude --dangerously-skip-permissions'
alias cat="bat"
alias ls='eza --icons'
unalias ll la 2>/dev/null
ll() { eza -l -g --icons --git --header "${@:-.}"; }
la() { eza -la -g --icons --git --header "${@:-.}"; }
alias lt='eza --tree --level=2 --icons'

# tmux/ghostty pane titles
_codex_shorten_middle() {
  local input="$1"
  local max_len="${2:-32}"
  local len=${#input}

  if (( len <= max_len )); then
    printf '%s' "$input"
    return
  fi

  local left=$(( (max_len - 1) / 2 ))
  local right=$(( max_len - left - 1 ))
  printf '%s...%s' "${input[1,left]}" "${input[-right,-1]}"
}

_tmux_context_host() {
  [[ -z "$SSH_CONNECTION" ]] && return
  hostname -s 2>/dev/null || printf '%s' "${HOST%%.*}"
}

_tmux_context_label() {
  local branch=""
  local root=""
  local sha=""
  local repo_label=""

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    repo_label=$(_codex_shorten_middle "$root" 18)

    if branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null); then
      branch=$(_codex_shorten_middle "$branch" 28)
      printf '%s [%s]' "$repo_label" "$branch"
    else
      sha=$(git rev-parse --short HEAD 2>/dev/null)
      printf '%s [det:%s]' "$repo_label" "$sha"
    fi
    return
  fi

  printf '%s' "$(_codex_shorten_middle "${PWD:t}" 24)"
}

_tmux_context_title() {
  local host=""
  local label=""

  host=$(_tmux_context_host)
  label=$(_tmux_context_label)

  if [[ -n "$host" ]]; then
    printf '%s:%s' "$host" "$label"
  else
    printf '%s' "$label"
  fi
}

_update_terminal_context_title() {
  local title
  title=$(_tmux_context_title)

  if [[ -n "$TMUX" ]]; then
    tmux select-pane -T "$title" >/dev/null 2>&1 || true
    return
  fi

  [[ -z "$GHOSTTY_RESOURCES_DIR" ]] && return
  print -Pn "\e]0;${title}"
}

chpwd_functions=(${chpwd_functions:#_update_terminal_context_title})
chpwd_functions+=(_update_terminal_context_title)
precmd_functions=(${precmd_functions:#_update_terminal_context_title})
precmd_functions+=(_update_terminal_context_title)

DISABLE_AUTO_TITLE="true"

# mise (runtime version manager)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Load encrypted secrets (sops + age)
if command -v load-secrets &>/dev/null && [[ -f "${SOPS_SECRETS_FILE:-$HOME/nix-config/secrets/secrets.yaml}" ]]; then
  eval "$(load-secrets)"
fi

# Vite+ bin (https://viteplus.dev)
[[ -r "$HOME/.vite-plus/env" ]] && . "$HOME/.vite-plus/env"

# Ghostty shell integration — only outside tmux.
# Inside tmux, Ghostty's PS1 marker injection (%{…%}) breaks p10k's nested
# parameter expansions, causing literal ":-}}" to appear in the prompt.
if [[ -n "$GHOSTTY_RESOURCES_DIR" && -z "$TMUX" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi
