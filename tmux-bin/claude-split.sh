#!/usr/bin/env bash
set -euo pipefail

CREDS_FILE="${CLAUDE_SPLIT_CREDS_FILE:-$HOME/.tmux-db-creds.json}"
JQ="${JQ:-jq}"
AGE="${AGE:-age}"
AGE_KEY="${DB_CREDS_AGE_KEY:-$HOME/.ssh/id_ed25519}"

# Decrypt an "age:<base64>" sentinel value using the SSH/age key.
# Plaintext values (no age: prefix) are echoed unchanged.
decrypt_value() {
  local val="$1" conn="${2:-}"
  if [[ "$val" != age:* ]]; then
    printf '%s' "$val"
    return 0
  fi
  if ! command -v "$AGE" &>/dev/null; then
    echo "Error: age is required to decrypt '$conn' (brew install age)" >&2
    return 1
  fi
  if [[ ! -f "$AGE_KEY" ]]; then
    echo "Error: age key not found: $AGE_KEY (needed to decrypt '$conn')" >&2
    return 1
  fi
  if ! printf '%s' "${val#age:}" | openssl base64 -d -A | "$AGE" -d -i "$AGE_KEY" 2>/dev/null; then
    echo "Error: age decrypt failed for '$conn' -- is $AGE_KEY the right key?" >&2
    return 1
  fi
}

validate_args() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: claude-split <connection-name>" >&2
    return 1
  fi
}

check_deps() {
  if ! command -v "$JQ" &>/dev/null; then
    echo "Error: jq is required. Install with: brew install jq" >&2
    return 1
  fi
}

check_creds_file() {
  if [[ ! -f "$1" ]]; then
    echo "Error: credentials file not found: $1" >&2
    return 1
  fi
}

lookup_connection() {
  local file="$1" conn="$2"
  if ! "$JQ" -e --arg k "$conn" '.[$k] | type == "object"' "$file" > /dev/null 2>&1; then
    local available
    available=$("$JQ" -r '[keys[]] | join(", ")' "$file")
    echo "Error: connection '$conn' not found" >&2
    echo "Available: $available" >&2
    return 1
  fi
}

extract_pg_vars() {
  local file="$1" conn="$2"
  PGHOST=$("$JQ" -r --arg k "$conn" '.[$k].host // empty' "$file")
  PGPORT=$("$JQ" -r --arg k "$conn" '.[$k].port // empty' "$file")
  PGUSER=$("$JQ" -r --arg k "$conn" '.[$k].user // empty' "$file")
  PGPASSWORD=$(decrypt_value "$("$JQ" -r --arg k "$conn" '.[$k].password // empty' "$file")" "$conn")
  PGDATABASE=$("$JQ" -r --arg k "$conn" '.[$k].database // empty' "$file")
  DATABASE_URL=$("$JQ" -r --arg k "$conn" '.[$k].url // empty' "$file")
}

build_env_flags() {
  ENV_FLAGS=()
  VARS_SET=()
  [[ -n "${PGHOST:-}" ]]       && { ENV_FLAGS+=(-e "PGHOST=$PGHOST");             VARS_SET+=(PGHOST); }
  [[ -n "${PGPORT:-}" ]]       && { ENV_FLAGS+=(-e "PGPORT=$PGPORT");             VARS_SET+=(PGPORT); }
  [[ -n "${PGUSER:-}" ]]       && { ENV_FLAGS+=(-e "PGUSER=$PGUSER");             VARS_SET+=(PGUSER); }
  [[ -n "${PGPASSWORD:-}" ]]   && { ENV_FLAGS+=(-e "PGPASSWORD=$PGPASSWORD");     VARS_SET+=(PGPASSWORD); }
  [[ -n "${PGDATABASE:-}" ]]   && { ENV_FLAGS+=(-e "PGDATABASE=$PGDATABASE");     VARS_SET+=(PGDATABASE); }
  [[ -n "${DATABASE_URL:-}" ]] && { ENV_FLAGS+=(-e "DATABASE_URL=$DATABASE_URL"); VARS_SET+=(DATABASE_URL); }
  true
}

_is_in_vars_set() {
  local v="$1" i
  for (( i=0; i<${#VARS_SET[@]}; i++ )); do
    [[ "${VARS_SET[$i]}" == "$v" ]] && return 0
  done
  return 1
}

detect_conflicts() {
  local -a PG_PATTERNS=(
    PGHOST PGHOSTADDR PGPORT PGDATABASE PGUSER PGPASSWORD PGPASSFILE
    PGSERVICE PGSERVICEFILE PGOPTIONS PGSSLMODE PGSSLCERT PGSSLKEY
    PGSSLROOTCERT PGCONNECT_TIMEOUT PGCLIENTENCODING PGAPPNAME
    DATABASE_URL POSTGRES_URL PG_URL DB_URL
    POSTGRES_HOST POSTGRES_PORT POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB
    DB_HOST DB_PORT DB_USER DB_PASSWORD DB_NAME DB_DATABASE
  )
  CONFLICTS=()
  local VAR
  for VAR in "${PG_PATTERNS[@]}"; do
    _is_in_vars_set "$VAR" && continue
    [[ -n "${!VAR:-}" ]] && CONFLICTS+=("$VAR")
  done
  true
}

print_banner() {
  local conn="$1"
  echo "DB CREDS LOADED: $conn"
  [[ -n "${PGHOST:-}" ]]       && echo "  PGHOST       = $PGHOST"
  [[ -n "${PGPORT:-}" ]]       && echo "  PGPORT       = $PGPORT"
  [[ -n "${PGUSER:-}" ]]       && echo "  PGUSER       = $PGUSER"
  [[ -n "${PGDATABASE:-}" ]]   && echo "  PGDATABASE   = $PGDATABASE"
  [[ -n "${PGPASSWORD:-}" ]]   && echo "  PGPASSWORD   = [set]"
  [[ -n "${DATABASE_URL:-}" ]] && echo "  DATABASE_URL = [set]"
  echo ""
  if [[ "${#CONFLICTS[@]}" -gt 0 ]]; then
    echo "WARNING - inherited vars detected (may conflict):"
    local V
    for (( V=0; V<${#CONFLICTS[@]}; V++ )); do
      echo "  ${CONFLICTS[$V]}  -> unset ${CONFLICTS[$V]}"
    done
  else
    echo "OK - no conflicting PG vars inherited"
  fi
}

open_pane() {
  local conn="$1"
  local BANNER_FILE
  BANNER_FILE=$(mktemp /tmp/claude-split-banner.XXXXXX)
  print_banner "$conn" > "$BANNER_FILE"
  local banner_cmd="cat '$BANNER_FILE' && rm '$BANNER_FILE' && exec '$SHELL' -i"
  local PANE_ID
  if [[ ${#ENV_FLAGS[@]} -gt 0 ]]; then
    PANE_ID=$(tmux split-window -h -P -F "#{pane_id}" "${ENV_FLAGS[@]}" "$banner_cmd")
  else
    PANE_ID=$(tmux split-window -h -P -F "#{pane_id}" "$banner_cmd")
  fi
  tmux select-pane -t "$PANE_ID" -T "[$conn]"
}

main() {
  local conn="${1:-}"
  validate_args "$conn" || exit 1
  check_deps || exit 1
  check_creds_file "$CREDS_FILE" || exit 1
  lookup_connection "$CREDS_FILE" "$conn" || exit 1
  extract_pg_vars "$CREDS_FILE" "$conn"
  build_env_flags
  detect_conflicts
  open_pane "$conn"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
