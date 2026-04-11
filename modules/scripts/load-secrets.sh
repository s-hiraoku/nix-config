#!/usr/bin/env bash
# Decrypt sops secrets and export as environment variables
# Usage: eval "$(load-secrets)"

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
SECRETS_FILE="${SOPS_SECRETS_FILE:-$HOME/nix-config/secrets/secrets.yaml}"

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "echo '[load-secrets] WARNING: secrets file not found: $SECRETS_FILE'" >&2
  exit 1
fi

if ! command -v sops &>/dev/null; then
  echo "echo '[load-secrets] WARNING: sops not found. Run: home-manager switch --flake .'" >&2
  exit 1
fi

if [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; then
  echo "echo '[load-secrets] WARNING: age key not found: $SOPS_AGE_KEY_FILE'" >&2
  echo "echo '[load-secrets] Run: mkdir -p ~/.config/sops/age && age-keygen -o ~/.config/sops/age/keys.txt'" >&2
  exit 1
fi

DECRYPTED=$(sops decrypt --output-type dotenv "$SECRETS_FILE" 2>&1)
if [[ $? -ne 0 ]]; then
  echo "echo '[load-secrets] WARNING: failed to decrypt secrets'" >&2
  echo "echo '[load-secrets] $DECRYPTED'" >&2
  exit 1
fi

echo "$DECRYPTED" | while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  echo "export ${key}=${value}"
done
