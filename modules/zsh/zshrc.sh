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

# herdr (Ghostty ベースの独自ターミナル) の VT 幅計算と p10k のマルチライン枠が
# 噛み合わず、右端コネクタ (─╮ / ─╯) が正しい桁に載らずゴミ文字として取り残される
# (罫線コーナーがプロンプト外の行に浮く症状)。$HERDR_PANE_ID が立つ herdr 内でのみ
# 枠 (装飾) を無効化する。セグメント・powerline・アイコンは影響を受けない。
# p10k はこれらのパラメータをプロンプト描画時に読むため source 後の上書きで有効。
if [[ -n "$HERDR_PANE_ID" || -n "$HERDR_ENV" ]]; then
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=''
fi

# zsh-autosuggestions, zsh-syntax-highlighting, and completions
# are now managed by home-manager (programs.zsh.autosuggestion / syntaxHighlighting)

# PATH additions — ディレクトリが存在するものだけ追加する。
# マシンによって入っていないツール (postgresql@14 / Docker / VS Code 等) の
# 死んだ PATH エントリを作らないため。
_path_prepend() { [[ -d "$1" ]] && export PATH="$1:$PATH"; }
_path_append()  { [[ -d "$1" ]] && export PATH="$PATH:$1"; }

_path_append  "$HOME/.cache/lm-studio/bin"
_path_prepend "$HOME/.local/bin"
_path_prepend "/opt/homebrew/opt/postgresql@14/bin"
_path_prepend "/Applications/Docker.app/Contents/Resources/bin"
_path_append  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
_path_append  "$HOME/Library/Python/3.11/bin"
_path_prepend "$HOME/.cargo/bin"

# Local env
[[ -r "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# MCP (Model Context Protocol) Configuration for Claude Code
export MCP_CONFIG_FILE="$HOME/.config/claude-code/mcp.json"

# Bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  _path_prepend "$BUN_INSTALL/bin"
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# Volta — ランタイム管理の役割分担:
#   Volta: Node 本体 + npm/pnpm + グローバル CLI (copilot, playwright-cli 等)
#   mise : ruby / erlang / elixir
# Node を mise へ一本化する場合は docs/runtime-managers.md の手順で移行し、
# このブロックを削除する。
if [[ -d "$HOME/.volta/bin" ]]; then
  export VOLTA_HOME="$HOME/.volta"
  _path_prepend "$VOLTA_HOME/bin"
fi

unfunction _path_prepend _path_append

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

# zoxide は programs.zoxide (common.nix)、ls/ll/la/lt は programs.eza が
# alias を定義するため、ここでの手書き init/alias は廃止した。

# Aliases
alias yolo='claude --dangerously-skip-permissions'
alias cat="bat"

# Terminal title context
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

_terminal_context_host() {
  [[ -z "$SSH_CONNECTION" ]] && return
  hostname -s 2>/dev/null || printf '%s' "${HOST%%.*}"
}

_terminal_context_label() {
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

_terminal_context_title() {
  local host=""
  local label=""

  host=$(_terminal_context_host)
  label=$(_terminal_context_label)

  if [[ -n "$host" ]]; then
    printf '%s:%s' "$host" "$label"
  else
    printf '%s' "$label"
  fi
}

_update_terminal_context_title() {
  [[ -z "$GHOSTTY_RESOURCES_DIR" ]] && return
  # herdr 内では発行しない。GHOSTTY_RESOURCES_DIR は Ghostty から起動した
  # herdr のペインにも継承されるが、タブタイトルは herdr が管理するうえ、
  # 未終端 OSC が herdr の VT パーサに後続出力を食わせてプロンプトが
  # ゴミ文字化する (会社環境で発生した症状)。
  [[ -n "$HERDR_ENV" || -n "$HERDR_PANE_ID" ]] && return

  local title
  title=$(_terminal_context_title)
  # OSC 0 は BEL (\a) で必ず終端する。終端が無いと端末が後続の出力を
  # タイトル文字列として食い続け、プロンプトが崩れる。
  print -Pn "\e]0;${title}\a"
}

chpwd_functions=(${chpwd_functions:#_update_terminal_context_title})
chpwd_functions+=(_update_terminal_context_title)
precmd_functions=(${precmd_functions:#_update_terminal_context_title})
precmd_functions+=(_update_terminal_context_title)

DISABLE_AUTO_TITLE="true"

# mise の activate は programs.mise (common.nix) が行う。

# Load encrypted secrets (sops + age) — 復号は環境ごとに 1 度だけ。
# tmux / herdr のペインや子 shell は親の環境変数を継承しているので、
# NIX_SECRETS_LOADED が立っていれば sops 復号 (数百 ms) をスキップして
# 起動を速くする。secrets を更新した直後は新しいトップレベル shell を
# 開くか、`unset NIX_SECRETS_LOADED && eval "$(load-secrets)"` で再読込。
if [[ -z "$NIX_SECRETS_LOADED" ]] && command -v load-secrets &>/dev/null \
  && [[ -f "${SOPS_SECRETS_FILE:-$HOME/nix-config/secrets/secrets.yaml}" ]]; then
  if _secrets_env=$(load-secrets); then
    eval "$_secrets_env"
    export NIX_SECRETS_LOADED=1
  fi
  unset _secrets_env
fi

# hms: このマシンに対応する Home Manager 構成を switch する。
# flake attr のホスト分岐を覚えなくて済むよう、hostname で自動判定する。
hms() {
  local flake_dir="${NIX_CONFIG_DIR:-$HOME/nix-config}"
  local attr="hiraoku.shinichi"
  case "$(hostname -s)" in
    PC-05481) attr="hiraoku.shinichi@PC-05481" ;;
  esac
  home-manager switch --flake "${flake_dir}#${attr}" "$@"
}

# hmu: nixpkgs を更新して switch し、flake.lock の差分を表示する。
# `nix flake lock --update-input` は Nix 2.19 より前の CLI でも動く
# 後方互換フォーム (`nix flake update <input>` は 2.19+ が必要)。
hmu() {
  local flake_dir="${NIX_CONFIG_DIR:-$HOME/nix-config}"
  nix flake lock --update-input nixpkgs --flake "$flake_dir" && hms && git -C "$flake_dir" diff flake.lock
}

# Vite+ bin (https://viteplus.dev)
[[ -r "$HOME/.vite-plus/env" ]] && . "$HOME/.vite-plus/env"

# Ghostty shell integration — only outside Herdr.
# Inside Herdr, Ghostty's PS1 marker injection (%{…%}) breaks p10k's
# nested parameter expansions, causing literal ":-}}" to appear in the prompt.
if [[ -n "$GHOSTTY_RESOURCES_DIR" && -z "$HERDR_ENV" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

# Home Manager loads fzf's zsh integration before the custom init block, but in
# some terminal/multiplexer startup paths ^R can remain zsh's default redisplay.
# Re-source fzf late. ^R の履歴検索は atuin (programs.atuin) が担うため、
# atuin が無い環境でのみ fzf の history widget にフォールバックする。
# (^T ファイル挿入 / ALT-C cd は引き続き fzf。)
if [[ -o interactive ]] && command -v fzf >/dev/null 2>&1; then
  if ! zle -l | grep -qx 'fzf-history-widget'; then
    source <(fzf --zsh)
  fi
  if ! zle -l | grep -q 'atuin'; then
    bindkey '^R' fzf-history-widget
  fi
fi
