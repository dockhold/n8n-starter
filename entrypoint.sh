#!/bin/sh
set -e

# Listen on the port Dockhold assigns, on all interfaces.
export N8N_PORT="${PORT:-5678}"
export N8N_LISTEN_ADDRESS="0.0.0.0"

# Writable, ephemeral user folder. Dockhold runs the container as a non-root uid
# that can't write n8n's default home, so point it at /tmp. Real state lives in
# Postgres + the encryption key below, so an ephemeral folder is fine.
export N8N_USER_FOLDER="${N8N_USER_FOLDER:-/tmp/n8n}"
mkdir -p "$N8N_USER_FOLDER"

# Persist to the managed Postgres. App pods are stateless — without this, n8n
# falls back to SQLite on the ephemeral disk and loses every workflow and
# credential on restart. n8n wants individual DB_POSTGRESDB_* vars, so map them
# from Dockhold's injected DATABASE_URL (postgres://user:pass@host:port/db).
if [ -n "$DATABASE_URL" ]; then
  export DB_TYPE=postgresdb
  _u="${DATABASE_URL#*://}"
  _creds="${_u%%@*}"
  _rest="${_u#*@}"
  export DB_POSTGRESDB_USER="${_creds%%:*}"
  export DB_POSTGRESDB_PASSWORD="${_creds#*:}"
  _hostport="${_rest%%/*}"
  export DB_POSTGRESDB_HOST="${_hostport%%:*}"
  export DB_POSTGRESDB_PORT="${_hostport#*:}"
  _db="${_rest#*/}"
  export DB_POSTGRESDB_DATABASE="${_db%%\?*}"
fi

# Behind Dockhold's HTTPS edge: generate https URLs and trust the proxy so the
# editor and login cookies work. Set N8N_HOST and WEBHOOK_URL to your app's
# domain in the dashboard after the first deploy.
export N8N_PROTOCOL="${N8N_PROTOCOL:-https}"
export N8N_PROXY_HOPS="${N8N_PROXY_HOPS:-1}"

if [ -z "$N8N_ENCRYPTION_KEY" ]; then
  echo "WARNING: N8N_ENCRYPTION_KEY is not set. Set it to a stable secret (Vault)," >&2
  echo "         or saved credentials become UNRECOVERABLE after a restart." >&2
fi

exec n8n start
