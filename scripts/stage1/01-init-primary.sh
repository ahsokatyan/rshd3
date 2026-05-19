#!/bin/sh
set -eu

. ./env.sh

psql -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_DB_SUPERUSER" -d postgres <<SQL
ALTER SYSTEM SET listen_addresses = '*';
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = 10;
ALTER SYSTEM SET max_replication_slots = 10;
ALTER SYSTEM SET hot_standby = on;
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$REPL_USER') THEN
    CREATE ROLE $REPL_USER WITH REPLICATION LOGIN PASSWORD '$REPL_PASSWORD';
  END IF;
END \$\$;
SQL

ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "grep -q '^host replication $REPL_USER ' '$PRIMARY_PGDATA/pg_hba.conf' || printf '%s\n' 'host replication $REPL_USER 0.0.0.0/0 md5' >> '$PRIMARY_PGDATA/pg_hba.conf'"
ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "grep -q '^host all all 0.0.0.0/0 trust' '$PRIMARY_PGDATA/pg_hba.conf' || printf '%s\n' 'host all all 0.0.0.0/0 trust' >> '$PRIMARY_PGDATA/pg_hba.conf'"
ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" \
  "pg_ctl -D '$PRIMARY_PGDATA' \
    -o \"-p $PRIMARY_PORT -c listen_addresses='*'\" \
    -l '$PRIMARY_PGDATA/server.log' \
    restart"

psql -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_DB_SUPERUSER" -d postgres -c "select pg_is_in_recovery();"
psql -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_DB_SUPERUSER" -d postgres -c "show wal_level;"
