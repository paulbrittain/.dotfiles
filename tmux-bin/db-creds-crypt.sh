#!/usr/bin/env bash
set -euo pipefail

# Encrypt / decrypt DB-cred passwords using an SSH (age) key.
#
# Encrypted passwords are stored in the creds JSON as a single-line sentinel:
#     "password": "age:<base64 of binary age ciphertext>"
#
# Usage:
#   db-creds-crypt encrypt            # encrypt all plaintext passwords in place (idempotent)
#   db-creds-crypt decrypt <profile>  # print the decrypted password for one profile
#   db-creds-crypt enc [value]        # encrypt one value (arg or stdin); prints the
#                                     # age:<...> string to paste into the creds file

CREDS_FILE="${CLAUDE_SPLIT_CREDS_FILE:-$HOME/.tmux-db-creds.json}"
AGE_PUBKEY="${DB_CREDS_AGE_PUBKEY:-$HOME/.ssh/id_ed25519.pub}"
AGE_KEY="${DB_CREDS_AGE_KEY:-$HOME/.ssh/id_ed25519}"
JQ="${JQ:-jq}"
AGE="${AGE:-age}"

die() { echo "Error: $*" >&2; exit 1; }

check_deps() {
  command -v "$JQ"  &>/dev/null || die "jq is required (brew install jq)"
  command -v "$AGE" &>/dev/null || die "age is required (brew install age)"
  command -v openssl &>/dev/null || die "openssl is required"
}

# Decrypt a stored value. Plaintext (no age: prefix) is returned unchanged.
decrypt_value() {
  local val="$1"
  if [[ "$val" == age:* ]]; then
    [[ -f "$AGE_KEY" ]] || die "age key not found: $AGE_KEY"
    printf '%s' "${val#age:}" | openssl base64 -d -A | "$AGE" -d -i "$AGE_KEY"
  else
    printf '%s' "$val"
  fi
}

# Encrypt a plaintext value into the age:<base64> sentinel form.
encrypt_value() {
  local plain="$1"
  printf '%s' "$plain" | "$AGE" -R "$AGE_PUBKEY" | openssl base64 -A | sed 's/^/age:/'
}

cmd_decrypt() {
  local conn="${1:-}"
  [[ -n "$conn" ]] || die "Usage: db-creds-crypt decrypt <profile>"
  [[ -f "$CREDS_FILE" ]] || die "credentials file not found: $CREDS_FILE"
  "$JQ" -e --arg k "$conn" '.[$k] | type == "object"' "$CREDS_FILE" >/dev/null 2>&1 \
    || die "profile '$conn' not found in $CREDS_FILE"
  local val
  val=$("$JQ" -r --arg k "$conn" '.[$k].password // empty' "$CREDS_FILE")
  decrypt_value "$val"
}

# Encrypt a single value and print the age:<base64> sentinel (for hand-editing
# a password in the creds file). Reads the value from $1, or stdin if omitted.
cmd_enc() {
  [[ -f "$AGE_PUBKEY" ]] || die "age public key not found: $AGE_PUBKEY"
  local plain
  if [[ $# -ge 1 ]]; then
    plain="$1"
  else
    IFS= read -r plain || true   # single line from stdin, no trailing newline
  fi
  [[ -n "$plain" ]] || die "no value to encrypt (pass an arg or pipe via stdin)"
  encrypt_value "$plain"   # already prints a single trailing newline
}

cmd_encrypt() {
  [[ -f "$CREDS_FILE" ]] || die "credentials file not found: $CREDS_FILE"
  [[ -f "$AGE_PUBKEY" ]] || die "age public key not found: $AGE_PUBKEY"

  cp -p "$CREDS_FILE" "$CREDS_FILE.bak"

  # Build a {profile: newpassword} map, skipping already-encrypted values.
  local map tmp k pw enc
  map=$(mktemp /tmp/db-creds-map.XXXXXX)
  echo '{}' > "$map"
  while IFS= read -r k; do
    pw=$("$JQ" -r --arg k "$k" '.[$k].password // empty' "$CREDS_FILE")
    [[ -z "$pw" ]] && continue
    if [[ "$pw" == age:* ]]; then
      enc="$pw"   # already encrypted; leave as-is (idempotent)
    else
      enc=$(encrypt_value "$pw")
    fi
    "$JQ" --arg k "$k" --arg v "$enc" '.[$k]=$v' "$map" > "$map.n" && mv "$map.n" "$map"
  done < <("$JQ" -r 'keys[]' "$CREDS_FILE")

  # Apply the map atomically (temp file + rename).
  tmp=$(mktemp "$(dirname "$CREDS_FILE")/.creds.XXXXXX")
  "$JQ" --slurpfile m "$map" \
    'reduce ($m[0] | keys[]) as $k (.; .[$k].password = $m[0][$k])' \
    "$CREDS_FILE" > "$tmp"
  chmod --reference="$CREDS_FILE" "$tmp" 2>/dev/null || chmod 600 "$tmp"
  mv "$tmp" "$CREDS_FILE"
  rm -f "$map"
  echo "Encrypted passwords in $CREDS_FILE (backup: $CREDS_FILE.bak)"
}

main() {
  check_deps
  local sub="${1:-}"
  shift || true
  case "$sub" in
    encrypt) cmd_encrypt "$@" ;;
    decrypt) cmd_decrypt "$@" ;;
    enc)     cmd_enc "$@" ;;
    *) die "Usage: db-creds-crypt {encrypt | decrypt <profile> | enc [value]}" ;;
  esac
}

main "$@"
