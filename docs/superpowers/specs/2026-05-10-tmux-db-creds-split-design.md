# Design: tmux DB Credentials Split

## Overview

A tmux `command-prompt` binding that opens a new horizontal split pane with postgres credentials pre-loaded as environment variables. The pane title is set to the connection name and a plain-text banner is printed on open showing what is loaded and flagging any conflicting vars inherited from the parent shell.

## Components

### 1. `~/.tmux-db-creds.json` (local, never committed)

A JSON file mapping connection names to connection objects. Lives at `~/.tmux-db-creds.json` on each machine. Not part of dotfiles — contains secrets.

Schema:
```json
{
  "<connection-name>": {
    "host": "string (optional, maps to PGHOST)",
    "port": 5432,
    "user": "string (optional, maps to PGUSER)",
    "password": "string (optional, maps to PGPASSWORD)",
    "database": "string (optional, maps to PGDATABASE)",
    "url": "string (optional, maps to DATABASE_URL)"
  }
}
```

Example:
```json
{
  "dev-ro": {
    "host": "localhost",
    "port": 5432,
    "user": "readonly",
    "password": "secret",
    "database": "myapp_dev",
    "url": "postgres://readonly:secret@localhost:5432/myapp_dev"
  },
  "prod-ro": {
    "host": "db.prod.example.com",
    "port": 5432,
    "user": "readonly",
    "password": "secret",
    "database": "myapp"
  }
}
```

### 2. `.dotfiles/tmux-bin/claude-split`

Executable shell script. Symlinked to `~/bin/claude-split` via dotbot. Takes one argument: the connection name.

**Flow:**
1. Validate argument is provided — print usage and exit if not
2. Check `~/.tmux-db-creds.json` exists — exit with error if not
3. Use `jq` to look up the connection name — exit with error listing available keys if not found
4. Extract fields from the JSON object
5. Call `tmux split-window -h` with `-e KEY=value` for each PG var present in the JSON
6. Set the pane title to the connection name via `tmux select-pane -T`
7. Send a banner command to the new pane via `tmux send-keys`

**JSON field → env var mapping:**
| JSON field | Env var       |
|------------|---------------|
| `host`     | `PGHOST`      |
| `port`     | `PGPORT`      |
| `user`     | `PGUSER`      |
| `password` | `PGPASSWORD`  |
| `database` | `PGDATABASE`  |
| `url`      | `DATABASE_URL`|

Only fields present in the JSON object are exported. Missing fields are not set.

**Banner format (plain text, no decoration):**

Clean case:
```
DB CREDS LOADED: dev-ro
  PGHOST     = localhost
  PGPORT     = 5432
  PGUSER     = readonly
  PGDATABASE = myapp_dev
  PGPASSWORD = [set]

OK - no conflicting PG vars inherited
```

Conflict case (WARNING replaces OK line):
```
DB CREDS LOADED: dev-ro
  PGHOST     = localhost
  PGPORT     = 5432
  PGUSER     = readonly
  PGDATABASE = myapp_dev
  PGPASSWORD = [set]

WARNING - inherited vars detected (may conflict):
  DATABASE_URL  -> unset DATABASE_URL
```

- Password is never printed — shown as `[set]` or `[not set]`
- Either the OK line or the WARNING block appears, never both
- Banner is sent as an inline shell command via `tmux send-keys` + Enter after the split opens

**Inherited var scan — patterns checked:**

The script inspects its own calling environment (which the new pane will inherit) for any vars matching these patterns that were **not** set by this script from the JSON:

- `PG*` — all libpq standard vars (`PGHOST`, `PGPASSWORD`, `PGSERVICE`, `PGSSLMODE`, etc.)
- `DATABASE_URL`, `POSTGRES_URL`, `PG_URL`, `DB_URL`
- `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
- `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_DATABASE`

Any matched var not in the "just set by this script" list is flagged as a potential conflict.

### 3. `install.conf.yaml` (dotbot symlink)

Add to the `link` section:
```yaml
~/bin/claude-split:
  path: tmux-bin/claude-split
  create: true
```

This creates `~/bin/` if needed and symlinks `claude-split` into it. `~/bin` is already on `PATH` in `zshrc`.

### 4. `tmux.conf` binding

Add one binding (key `G` for "guarded" — change if conflicts):
```
bind-key G command-prompt -p "db creds:" "run-shell 'claude-split %%'"
```

`C-a G` opens a status-bar prompt. User types the connection name (e.g. `dev-ro`) and presses enter.

## Error Cases

| Condition | Behaviour |
|-----------|-----------|
| No argument given | Print usage, exit 1 |
| `~/.tmux-db-creds.json` missing | Print error with path, exit 1 |
| `jq` not installed | Print install hint (`brew install jq`), exit 1 |
| Connection name not found in JSON | Print error listing available keys, exit 1 |
| tmux not running | `tmux split-window` will fail naturally |

## Out of Scope

- Automatic unsetting of inherited vars (user does this manually based on banner)
- Launching `claude` or any process automatically in the new pane
- Encryption of `~/.tmux-db-creds.json`
- Support for non-postgres credential types (deferred to future extension)
