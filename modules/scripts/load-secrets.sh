#!/usr/bin/env bash
# Decrypt sops secrets and export as environment variables
# Usage: eval "$(load-secrets)"

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
SECRETS_FILE="${SOPS_SECRETS_FILE:-$HOME/nix-config/secrets/secrets.yaml}"

if [[ ! -f "$SECRETS_FILE" ]]; then
  return 0 2>/dev/null || exit 0
fi

if ! command -v sops &>/dev/null; then
  return 0 2>/dev/null || exit 0
fi

sops decrypt --output-type dotenv "$SECRETS_FILE" 2>/dev/null | while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  echo "export ${key}=${value}"
done
