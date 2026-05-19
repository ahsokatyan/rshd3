#!/bin/sh
set -eu

. ./env.sh

ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "pg_ctl -D '$PRIMARY_PGDATA' promote || true"
sleep 3

pg_ctl -D "$STANDBY_PGDATA" stop -m fast >/dev/null 2>&1 || true
rm -rf "$STANDBY_PGDATA"
mkdir -p "$STANDBY_PGDATA"
chmod 700 "$STANDBY_PGDATA"

set --
for src in $(psql -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_DB_SUPERUSER" -d postgres -At -c "select pg_tablespace_location(oid) from pg_tablespace where pg_tablespace_location(oid) <> '';"); do
  dst="$STANDBY_HOME/$(basename "$src")"
  rm -rf "$dst"
  set -- "$@" -T "$src=$dst"
done

PGPASSWORD="$REPL_PASSWORD" pg_basebackup \
  -h "$PRIMARY_HOST" \
  -p "$PRIMARY_PORT" \
  -U "$REPL_USER" \
  -D "$STANDBY_PGDATA" \
  "$@" \
  -R -X stream -P
pg_ctl -D "$STANDBY_PGDATA" -o "-p $STANDBY_PORT" -l "$STANDBY_PGDATA/server.log" start

sleep 3

psql -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_DB_SUPERUSER" -d postgres -c "select pg_is_in_recovery();"
psql -h "$STANDBY_HOST" -p "$STANDBY_PORT" -U "$STANDBY_DB_SUPERUSER" -d postgres -c "select pg_is_in_recovery();"
