# tmux DB Credentials Split — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a tmux `command-prompt` binding (`C-a G`) that opens a horizontal split pane with postgres credentials pre-loaded from `~/.tmux-db-creds.json`, pane title set to the connection name, and a plain-text banner showing what's loaded plus any conflicting postgres vars inherited from the parent shell.

**Architecture:** A bash script (`tmux-bin/claude-split`) reads `~/.tmux-db-creds.json` with `jq`, passes credentials as `-e KEY=val` flags to `tmux split-window`, writes a rendered banner to a temp file, and sends `cat <file> && rm <file>` to the new pane. Conflict detection scans the calling shell's environment (which the new pane inherits) against a hardcoded list of known postgres env var patterns. The script is symlinked to `~/bin/claude-split` via dotbot and invoked by a `command-prompt` tmux binding.

**Tech Stack:** bash (system default, 3.2-compatible), jq, bats-core (tests), tmux

---

## File Map

| Action | Path | Purpose |
|--------|------|---------|
| Create | `tmux-bin/claude-split` | Main script |
| Create | `tmux-bin/tests/claude-split.bats` | bats test suite |
| Modify | `install.conf.yaml` | Add dotbot symlink for `~/bin/claude-split` |
| Modify | `tmux.conf` | Add `bind-key G command-prompt` binding |

---

### Task 1: Install bats-core and scaffold files

**Files:**
- Create: `tmux-bin/claude-split`
- Create: `tmux-bin/tests/claude-split.bats`

- [ ] **Step 1: Install bats-core**

```bash
brew install bats-core
bats --version
```

Expected: prints `Bats 1.x.x`

- [ ] **Step 2: Create directory structure**

```bash
mkdir -p /Users/paul/git/.dotfiles/tmux-bin/tests
```

- [ ] **Step 3: Create the script skeleton**

Create `tmux-bin/claude-split` with this exact content:

```bash
#!/usr/bin/env bash
set -euo pipefail

CREDS_FILE="${CLAUDE_SPLIT_CREDS_FILE:-$HOME/.tmux-db-creds.json}"
JQ="${JQ:-jq}"

# functions inserted in later tasks

main() {
  echo "not implemented yet" >&2
  exit 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

```bash
chmod +x /Users/paul/git/.dotfiles/tmux-bin/claude-split
```

- [ ] **Step 4: Create the bats test skeleton**

Create `tmux-bin/tests/claude-split.bats`:

```bash
#!/usr/bin/env bats

SCRIPT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/claude-split"

setup() {
  TEST_DIR=$(mktemp -d)
  export CLAUDE_SPLIT_CREDS_FILE="$TEST_DIR/creds.json"
  source "$SCRIPT"
}

teardown() {
  rm -rf "$TEST_DIR"
}
```

- [ ] **Step 5: Verify bats loads the file cleanly**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: `0 tests, 0 failures`

- [ ] **Step 6: Commit**

```bash
git add tmux-bin/claude-split tmux-bin/tests/claude-split.bats
git commit -m "feat: scaffold claude-split script and bats test file"
```

---

### Task 2: Implement and test argument validation, jq check, and creds file check

**Files:**
- Modify: `tmux-bin/claude-split`
- Modify: `tmux-bin/tests/claude-split.bats`

- [ ] **Step 1: Write failing tests**

Add to `tmux-bin/tests/claude-split.bats`:

```bash
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
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: 6 failures mentioning `validate_args`, `check_deps`, `check_creds_file` not found

- [ ] **Step 3: Implement the three validation functions**

In `tmux-bin/claude-split`, replace the `# functions inserted in later tasks` comment with:

```bash
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

# more functions will be appended in later tasks
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: `6 tests, 0 failures`

- [ ] **Step 5: Commit**

```bash
git add tmux-bin/claude-split tmux-bin/tests/claude-split.bats
git commit -m "feat: add argument validation, jq check, and creds file check"
```

---

### Task 3: Implement and test JSON connection lookup

**Files:**
- Modify: `tmux-bin/claude-split`
- Modify: `tmux-bin/tests/claude-split.bats`

- [ ] **Step 1: Write failing tests**

Add to `tmux-bin/tests/claude-split.bats`:

```bash
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
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: 3 new failures mentioning `lookup_connection` not found

- [ ] **Step 3: Implement lookup_connection**

Add after `check_creds_file` in `tmux-bin/claude-split` (before the `# more functions` comment):

```bash
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
```

- [ ] **Step 4: Run tests to confirm they all pass**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: `9 tests, 0 failures`

- [ ] **Step 5: Commit**

```bash
git add tmux-bin/claude-split tmux-bin/tests/claude-split.bats
git commit -m "feat: add JSON connection lookup with available-keys error message"
```

---

### Task 4: Implement and test env var extraction and flag building

**Files:**
- Modify: `tmux-bin/claude-split`
- Modify: `tmux-bin/tests/claude-split.bats`

- [ ] **Step 1: Write failing tests**

Add to `tmux-bin/tests/claude-split.bats`:

```bash
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
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: 5 new failures

- [ ] **Step 3: Implement extract_pg_vars and build_env_flags**

Add after `lookup_connection` in `tmux-bin/claude-split`:

```bash
extract_pg_vars() {
  local file="$1" conn="$2"
  PGHOST=$("$JQ" -r --arg k "$conn" '.[$k].host // empty' "$file")
  PGPORT=$("$JQ" -r --arg k "$conn" '.[$k].port // empty' "$file")
  PGUSER=$("$JQ" -r --arg k "$conn" '.[$k].user // empty' "$file")
  PGPASSWORD=$("$JQ" -r --arg k "$conn" '.[$k].password // empty' "$file")
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
}
```

- [ ] **Step 4: Run tests to confirm they all pass**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: `14 tests, 0 failures`

- [ ] **Step 5: Commit**

```bash
git add tmux-bin/claude-split tmux-bin/tests/claude-split.bats
git commit -m "feat: add env var extraction and tmux -e flag building"
```

---

### Task 5: Implement and test conflict detection

**Files:**
- Modify: `tmux-bin/claude-split`
- Modify: `tmux-bin/tests/claude-split.bats`

- [ ] **Step 1: Write failing tests**

Add to `tmux-bin/tests/claude-split.bats`:

```bash
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
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: 4 new failures

- [ ] **Step 3: Implement _is_in_vars_set and detect_conflicts**

Add after `build_env_flags` in `tmux-bin/claude-split`:

```bash
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
}
```

- [ ] **Step 4: Run tests to confirm they all pass**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: `18 tests, 0 failures`

- [ ] **Step 5: Commit**

```bash
git add tmux-bin/claude-split tmux-bin/tests/claude-split.bats
git commit -m "feat: add inherited postgres var conflict detection"
```

---

### Task 6: Implement and test banner generation

**Files:**
- Modify: `tmux-bin/claude-split`
- Modify: `tmux-bin/tests/claude-split.bats`

- [ ] **Step 1: Write failing tests**

Add to `tmux-bin/tests/claude-split.bats`:

```bash
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
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: 6 new failures

- [ ] **Step 3: Implement print_banner**

Add after `detect_conflicts` in `tmux-bin/claude-split`:

```bash
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
```

- [ ] **Step 4: Run tests to confirm they all pass**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: `24 tests, 0 failures`

- [ ] **Step 5: Commit**

```bash
git add tmux-bin/claude-split tmux-bin/tests/claude-split.bats
git commit -m "feat: add banner generation with conflict warnings"
```

---

### Task 7: Implement open_pane and wire up main

**Files:**
- Modify: `tmux-bin/claude-split`
- Modify: `tmux-bin/tests/claude-split.bats`

- [ ] **Step 1: Write failing test for open_pane**

Add to `tmux-bin/tests/claude-split.bats`:

```bash
@test "open_pane: calls tmux split-window, select-pane, and send-keys" {
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
  }
  mktemp() { echo "$BANNER_PATH"; }

  open_pane "dev-ro"

  grep -q "split-window" "$TMUX_LOG"
  grep -qF "select-pane" "$TMUX_LOG"
  grep -qF "[dev-ro]" "$TMUX_LOG"
  grep -q "send-keys" "$TMUX_LOG"
}
```

- [ ] **Step 2: Run test to confirm it fails**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: 1 new failure for `open_pane`

- [ ] **Step 3: Implement open_pane**

Add after `print_banner` in `tmux-bin/claude-split`:

```bash
open_pane() {
  local conn="$1"
  local PANE_ID
  if [[ ${#ENV_FLAGS[@]} -gt 0 ]]; then
    PANE_ID=$(tmux split-window -h -P -F "#{pane_id}" "${ENV_FLAGS[@]}")
  else
    PANE_ID=$(tmux split-window -h -P -F "#{pane_id}")
  fi
  tmux select-pane -t "$PANE_ID" -T "[$conn]"
  local BANNER_FILE
  BANNER_FILE=$(mktemp /tmp/claude-split-banner.XXXXXX)
  print_banner "$conn" > "$BANNER_FILE"
  tmux send-keys -t "$PANE_ID" "cat '$BANNER_FILE' && rm '$BANNER_FILE'" Enter
}
```

- [ ] **Step 4: Replace the main stub**

Replace the `main()` function in `tmux-bin/claude-split` with:

```bash
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
```

- [ ] **Step 5: Run all tests to confirm they pass**

```bash
cd /Users/paul/git/.dotfiles && bats tmux-bin/tests/claude-split.bats
```

Expected: `25 tests, 0 failures`

- [ ] **Step 6: Smoke test the error paths (no live tmux needed)**

```bash
cd /Users/paul/git/.dotfiles
./tmux-bin/claude-split
```

Expected: prints `Usage: claude-split`, exits 1

```bash
./tmux-bin/claude-split nonexistent-conn
```

Expected: prints `credentials file not found`, exits 1

- [ ] **Step 7: Commit**

```bash
git add tmux-bin/claude-split tmux-bin/tests/claude-split.bats
git commit -m "feat: add open_pane and wire up main"
```

---

### Task 8: Add dotbot symlink and tmux.conf binding

**Files:**
- Modify: `install.conf.yaml`
- Modify: `tmux.conf`

- [ ] **Step 1: Add dotbot symlink entry to install.conf.yaml**

In `install.conf.yaml`, add to the end of the `link` section:

```yaml
    ~/bin/claude-split:
      path: tmux-bin/claude-split
      create: true
```

The full `link` block should now be:

```yaml
- link:
    ~/.tmux.conf: tmux.conf
    ~/.zprofile: zprofile
    ~/.zshrc: zshrc
    ~/.config/nvim: nvim
    ~/.config/fish/config.fish:
      path: config.fish
      create: true
    ~/.aerospace.toml:
      if: '[ `uname` = Darwin ]'
      path: .aerospace.toml
    ~/bin/claude-split:
      path: tmux-bin/claude-split
      create: true
```

- [ ] **Step 2: Add tmux binding to tmux.conf**

In `tmux.conf`, add after the `bind-key x kill-pane` line:

```
bind-key G command-prompt -p "db creds:" "run-shell 'claude-split %%'"
```

- [ ] **Step 3: Run dotbot to create the symlink**

```bash
cd /Users/paul/git/.dotfiles && ./install
```

Expected: dotbot output shows `~/bin/claude-split` linked

Verify:
```bash
ls -la ~/bin/claude-split
```

Expected: symlink pointing into your dotfiles `tmux-bin/` dir

- [ ] **Step 4: Create a sample `~/.tmux-db-creds.json` for end-to-end testing**

```bash
cat > ~/.tmux-db-creds.json <<'EOF'
{
  "dev-ro": {
    "host": "localhost",
    "port": 5432,
    "user": "readonly",
    "password": "changeme",
    "database": "myapp_dev"
  }
}
EOF
chmod 600 ~/.tmux-db-creds.json
```

- [ ] **Step 5: Reload tmux config**

Inside a tmux session, press `C-a r`.
Expected: status bar shows "Config reloaded."

- [ ] **Step 6: Manual end-to-end test**

Press `C-a G`, type `dev-ro`, press Enter.

Expected:
- A new horizontal split opens to the right
- The pane title shows `[dev-ro]`
- The banner prints with `PGHOST`, `PGUSER`, `PGDATABASE`, `PGPASSWORD = [set]`
- Either the OK line appears, or a WARNING listing any conflicting inherited vars

- [ ] **Step 7: Commit**

```bash
git add install.conf.yaml tmux.conf
git commit -m "feat: add dotbot symlink and tmux keybinding for claude-split"
```
