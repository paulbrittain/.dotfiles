#!/usr/bin/env bats

SCRIPT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/claude-split.sh"

setup() {
  TEST_DIR=$(mktemp -d)
  export CLAUDE_SPLIT_CREDS_FILE="$TEST_DIR/creds.json"
  source "$SCRIPT"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "validate_args: returns 1 and prints usage when no argument given" {
  run validate_args ""
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage: claude-split"* ]]
}

@test "validate_args: returns 0 when argument provided" {
  run validate_args "dev-ro"
  [ "$status" -eq 0 ]
}

@test "check_deps: returns 1 when jq binary not found" {
  run env JQ=nonexistent_jq_xyz bash -c "source '$SCRIPT'; check_deps"
  [ "$status" -eq 1 ]
  [[ "$output" == *"jq is required"* ]]
}

@test "check_deps: returns 0 when jq is available" {
  run check_deps
  [ "$status" -eq 0 ]
}

@test "check_creds_file: returns 1 when file does not exist" {
  run check_creds_file "/tmp/does-not-exist-$(date +%s)"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "check_creds_file: returns 0 when file exists" {
  echo '{}' > "$TEST_DIR/creds.json"
  run check_creds_file "$TEST_DIR/creds.json"
  [ "$status" -eq 0 ]
}

@test "lookup_connection: returns 1 when key not found and shows error" {
  cat > "$TEST_DIR/creds.json" <<'EOF'
{"dev-ro": {"host": "localhost"}, "prod-ro": {"host": "prod.db"}}
EOF
  run lookup_connection "$TEST_DIR/creds.json" "nonexistent"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "lookup_connection: lists available keys on error" {
  cat > "$TEST_DIR/creds.json" <<'EOF'
{"dev-ro": {"host": "localhost"}, "prod-ro": {"host": "prod.db"}}
EOF
  run lookup_connection "$TEST_DIR/creds.json" "staging"
  [[ "$output" == *"dev-ro"* ]]
  [[ "$output" == *"prod-ro"* ]]
}

@test "lookup_connection: returns 0 when key exists" {
  cat > "$TEST_DIR/creds.json" <<'EOF'
{"dev-ro": {"host": "localhost"}}
EOF
  run lookup_connection "$TEST_DIR/creds.json" "dev-ro"
  [ "$status" -eq 0 ]
}

@test "extract_pg_vars: sets PG vars from all JSON fields" {
  cat > "$TEST_DIR/creds.json" <<'EOF'
{"dev-ro": {"host": "localhost", "port": 5432, "user": "ro", "password": "secret", "database": "mydb"}}
EOF
  extract_pg_vars "$TEST_DIR/creds.json" "dev-ro"
  [ "$PGHOST" = "localhost" ]
  [ "$PGPORT" = "5432" ]
  [ "$PGUSER" = "ro" ]
  [ "$PGPASSWORD" = "secret" ]
  [ "$PGDATABASE" = "mydb" ]
  [ -z "${DATABASE_URL:-}" ]
}

@test "decrypt_value: returns plaintext unchanged when no age: prefix" {
  run decrypt_value "plainsecret" "dev-ro"
  [ "$status" -eq 0 ]
  [ "$output" = "plainsecret" ]
}

@test "decrypt_value: fails clearly when age key missing for encrypted value" {
  run env DB_CREDS_AGE_KEY="/tmp/no-such-key-$$" bash -c \
    "source '$SCRIPT'; decrypt_value 'age:Zm9v' 'dev-ro'"
  [ "$status" -eq 1 ]
  [[ "$output" == *"age key not found"* ]]
}

@test "decrypt_value: round-trips an age-encrypted value with the SSH key" {
  command -v age >/dev/null || skip "age not installed"
  [ -f "$HOME/.ssh/id_ed25519.pub" ] || skip "no ssh key"
  local enc
  enc="age:$(printf 'topsecret' | age -R "$HOME/.ssh/id_ed25519.pub" | openssl base64 -A)"
  run env DB_CREDS_AGE_KEY="$HOME/.ssh/id_ed25519" bash -c \
    "source '$SCRIPT'; decrypt_value '$enc' 'dev-ro'"
  [ "$status" -eq 0 ]
  [ "$output" = "topsecret" ]
}

@test "extract_pg_vars: decrypts an age-encrypted password field" {
  command -v age >/dev/null || skip "age not installed"
  [ -f "$HOME/.ssh/id_ed25519.pub" ] || skip "no ssh key"
  local enc
  enc="age:$(printf 'secret' | age -R "$HOME/.ssh/id_ed25519.pub" | openssl base64 -A)"
  cat > "$TEST_DIR/creds.json" <<EOF
{"dev-ro": {"host": "localhost", "port": 5432, "user": "ro", "password": "$enc", "database": "mydb"}}
EOF
  export DB_CREDS_AGE_KEY="$HOME/.ssh/id_ed25519"
  extract_pg_vars "$TEST_DIR/creds.json" "dev-ro"
  [ "$PGPASSWORD" = "secret" ]
}

@test "extract_pg_vars: sets DATABASE_URL when url field present" {
  cat > "$TEST_DIR/creds.json" <<'EOF'
{"dev-ro": {"host": "localhost", "url": "postgres://ro:secret@localhost/mydb"}}
EOF
  extract_pg_vars "$TEST_DIR/creds.json" "dev-ro"
  [ "$DATABASE_URL" = "postgres://ro:secret@localhost/mydb" ]
}

@test "extract_pg_vars: leaves vars empty when JSON fields absent" {
  cat > "$TEST_DIR/creds.json" <<'EOF'
{"dev-ro": {"host": "localhost"}}
EOF
  extract_pg_vars "$TEST_DIR/creds.json" "dev-ro"
  [ "$PGHOST" = "localhost" ]
  [ -z "${PGPORT:-}" ]
  [ -z "${PGUSER:-}" ]
  [ -z "${PGPASSWORD:-}" ]
  [ -z "${PGDATABASE:-}" ]
}

@test "build_env_flags: includes -e flags only for non-empty vars" {
  PGHOST="localhost" PGPORT="5432" PGUSER="ro" PGPASSWORD="secret"
  PGDATABASE="mydb" DATABASE_URL=""
  build_env_flags
  [[ "${ENV_FLAGS[*]}" == *"PGHOST=localhost"* ]]
  [[ "${ENV_FLAGS[*]}" == *"PGUSER=ro"* ]]
  [[ "${ENV_FLAGS[*]}" != *"DATABASE_URL"* ]]
}

@test "build_env_flags: populates VARS_SET with names of set vars only" {
  PGHOST="localhost" PGPORT="" PGUSER="ro" PGPASSWORD=""
  PGDATABASE="mydb" DATABASE_URL=""
  build_env_flags
  [[ " ${VARS_SET[*]} " == *" PGHOST "* ]]
  [[ " ${VARS_SET[*]} " == *" PGUSER "* ]]
  [[ " ${VARS_SET[*]} " != *" PGPORT "* ]]
  [[ " ${VARS_SET[*]} " != *" DATABASE_URL "* ]]
}

@test "detect_conflicts: empty result when no postgres vars in env" {
  unset PGHOST PGPORT PGUSER PGPASSWORD PGDATABASE DATABASE_URL \
        POSTGRES_URL PG_URL DB_URL POSTGRES_HOST POSTGRES_PORT \
        POSTGRES_USER POSTGRES_PASSWORD POSTGRES_DB \
        DB_HOST DB_PORT DB_USER DB_PASSWORD DB_NAME DB_DATABASE 2>/dev/null || true
  VARS_SET=()
  detect_conflicts
  [ "${#CONFLICTS[@]}" -eq 0 ]
}

@test "detect_conflicts: does not flag vars that were just set by the script" {
  export PGHOST=localhost
  VARS_SET=(PGHOST)
  detect_conflicts
  [ "${#CONFLICTS[@]}" -eq 0 ]
}

@test "detect_conflicts: flags inherited vars not set by script" {
  export DATABASE_URL="postgres://other:other@other/other"
  export DB_PASSWORD="hunter2"
  VARS_SET=(PGHOST PGUSER PGDATABASE)
  detect_conflicts
  [[ " ${CONFLICTS[*]} " == *" DATABASE_URL "* ]]
  [[ " ${CONFLICTS[*]} " == *" DB_PASSWORD "* ]]
}

@test "detect_conflicts: flags inherited PGPASSWORD when not set by script" {
  export PGPASSWORD=oldpassword
  VARS_SET=(PGHOST PGUSER)
  detect_conflicts
  [[ " ${CONFLICTS[*]} " == *" PGPASSWORD "* ]]
}

@test "print_banner: shows connection name and loaded var values" {
  PGHOST=localhost PGPORT=5432 PGUSER=ro PGDATABASE=mydb
  PGPASSWORD=secret DATABASE_URL=""
  CONFLICTS=()
  run print_banner "dev-ro"
  [[ "$output" == *"DB CREDS LOADED: dev-ro"* ]]
  [[ "$output" == *"PGHOST"*"localhost"* ]]
  [[ "$output" == *"PGPORT"*"5432"* ]]
  [[ "$output" == *"PGUSER"*"ro"* ]]
  [[ "$output" == *"PGDATABASE"*"mydb"* ]]
}

@test "print_banner: shows PGPASSWORD as [set] never the value" {
  PGHOST=localhost PGPORT="" PGUSER=ro PGDATABASE=mydb
  PGPASSWORD=supersecret DATABASE_URL=""
  CONFLICTS=()
  run print_banner "dev-ro"
  [[ "$output" == *"PGPASSWORD"*"[set]"* ]]
  [[ "$output" != *"supersecret"* ]]
}

@test "print_banner: shows DATABASE_URL as [set] never the value" {
  PGHOST=localhost PGPORT="" PGUSER="" PGDATABASE="" PGPASSWORD=""
  DATABASE_URL="postgres://ro:secret@localhost/mydb"
  CONFLICTS=()
  run print_banner "dev-ro"
  [[ "$output" == *"DATABASE_URL = [set]"* ]]
  [[ "$output" != *"postgres://ro:secret"* ]]
}

@test "print_banner: shows OK line when no conflicts" {
  PGHOST=localhost PGPORT="" PGUSER=ro PGDATABASE=mydb
  PGPASSWORD=secret DATABASE_URL=""
  CONFLICTS=()
  run print_banner "dev-ro"
  [[ "$output" == *"OK - no conflicting PG vars inherited"* ]]
  [[ "$output" != *"WARNING"* ]]
}

@test "print_banner: shows WARNING block instead of OK when conflicts exist" {
  PGHOST=localhost PGPORT="" PGUSER=ro PGDATABASE=mydb
  PGPASSWORD=secret DATABASE_URL=""
  CONFLICTS=(DATABASE_URL DB_PASSWORD)
  run print_banner "dev-ro"
  [[ "$output" == *"WARNING - inherited vars detected"* ]]
  [[ "$output" == *"DATABASE_URL"* ]]
  [[ "$output" == *"DB_PASSWORD"* ]]
  [[ "$output" != *"OK - no conflicting"* ]]
}

@test "print_banner: omits lines for vars not set in JSON" {
  PGHOST=localhost PGPORT="" PGUSER="" PGDATABASE="" PGPASSWORD="" DATABASE_URL=""
  CONFLICTS=()
  run print_banner "dev-ro"
  [[ "$output" != *"PGPORT"* ]]
  [[ "$output" != *"PGUSER"* ]]
}

@test "open_pane: calls tmux split-window with banner cmd and select-pane, no send-keys" {
  PGHOST=localhost PGUSER=ro PGDATABASE=mydb PGPASSWORD=secret
  PGPORT="" DATABASE_URL=""
  ENV_FLAGS=(-e "PGHOST=localhost" -e "PGUSER=ro" -e "PGDATABASE=mydb" -e "PGPASSWORD=secret")
  VARS_SET=(PGHOST PGUSER PGDATABASE PGPASSWORD)
  CONFLICTS=()

  TMUX_LOG="$TEST_DIR/tmux.log"
  BANNER_PATH="$TEST_DIR/test-banner"

  # Shadow tmux and mktemp so no real tmux session is needed
  tmux() {
    echo "tmux $*" >> "$TMUX_LOG"
    [[ "$1" == "split-window" ]] && echo "%42"
    return 0
  }
  mktemp() { echo "$BANNER_PATH"; }

  open_pane "dev-ro"

  grep -q "split-window" "$TMUX_LOG"
  grep -qF "select-pane" "$TMUX_LOG"
  grep -qF "[dev-ro]" "$TMUX_LOG"
  # banner is passed as split-window arg, not via send-keys
  grep -qF "cat '$BANNER_PATH'" "$TMUX_LOG"
  grep -qF "exec" "$TMUX_LOG"
  ! grep -q "send-keys" "$TMUX_LOG"
}
