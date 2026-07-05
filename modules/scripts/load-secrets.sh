#!/usr/bin/env bash
# Decrypt sops secrets and export as environment variables
# Usage: eval "$(load-secrets)"
#
# stdout には eval 可能な `export KEY=value` だけを出力する。
# 警告・エラーは stderr に出す (eval の対象にならない)。

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
SECRETS_FILE="${SOPS_SECRETS_FILE:-$HOME/nix-config/secrets/secrets.yaml}"

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "[load-secrets] WARNING: secrets file not found: $SECRETS_FILE" >&2
  exit 1
fi

if ! command -v sops &>/dev/null; then
  echo "[load-secrets] WARNING: sops not found. Run: home-manager switch --flake ." >&2
  exit 1
fi

if [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; then
  echo "[load-secrets] WARNING: age key not found: $SOPS_AGE_KEY_FILE" >&2
  echo "[load-secrets] Run: mkdir -p ~/.config/sops/age && age-keygen -o ~/.config/sops/age/keys.txt" >&2
  exit 1
fi

if ! DECRYPTED=$(sops decrypt --output-type dotenv "$SECRETS_FILE" 2>&1); then
  echo "[load-secrets] WARNING: failed to decrypt secrets" >&2
  echo "[load-secrets] $DECRYPTED" >&2
  exit 1
fi

# %q でシェル安全にクォートする。値に空白・$・; などのメタ文字が
# 含まれていても eval で壊れたり実行されたりしない。
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  printf 'export %s=%q\n' "$key" "$value"
done <<<"$DECRYPTED"
