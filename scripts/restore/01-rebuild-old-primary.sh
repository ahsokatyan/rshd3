#!/bin/sh
set -eu

. ./env.sh

ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "rm -rf '$PRIMARY_PGDATA'; mkdir -p '$PRIMARY_PGDATA'; chmod 700 '$PRIMARY_PGDATA'"

set --
for src in $(psql -h "$STANDBY_HOST" -p "$STANDBY_PORT" -U "$STANDBY_DB_SUPERUSER" -d postgres -At -c "select pg_tablespace_location(oid) from pg_tablespace where pg_tablespace_location(oid) <> '';"); do
  dst="$PRIMARY_HOME/$(basename "$src")"
  ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "rm -rf '$dst'"
  set -- "$@" -T "$src=$dst"
done

ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" \
  "PGPASSWORD='$REPL_PASSWORD' pg_basebackup -h '$STANDBY_HOST' -p '$STANDBY_PORT' -U '$REPL_USER' -D '$PRIMARY_PGDATA' $* -R -X stream -P"

ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "pg_ctl -D '$PRIMARY_PGDATA' -o '-p $PRIMARY_PORT' -l '$PRIMARY_PGDATA/server.log' start"

psql -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_DB_SUPERUSER" -d postgres -c "select pg_is_in_recovery();"
