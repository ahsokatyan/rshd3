#!/bin/sh
set -eu

. ./env.sh

ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "
set -eu

if [ ! -f '$PRIMARY_PGDATA/PG_VERSION' ]; then
  rm -rf '$PRIMARY_PGDATA'
  mkdir -p '$PRIMARY_PGDATA'
  chmod 700 '$PRIMARY_PGDATA'
  initdb -D '$PRIMARY_PGDATA'
fi

pg_ctl -D '$PRIMARY_PGDATA' stop -m fast >/dev/null 2>&1 || true

if ! grep -q '^host all all 0.0.0.0/0 trust' '$PRIMARY_PGDATA/pg_hba.conf'; then
  tmp_hba='$PRIMARY_PGDATA/pg_hba.conf.rshd3'
  {
    printf '%s\n' 'host all all 0.0.0.0/0 trust'
    cat '$PRIMARY_PGDATA/pg_hba.conf'
  } > \"\$tmp_hba\"
  mv \"\$tmp_hba\" '$PRIMARY_PGDATA/pg_hba.conf'
fi

pg_ctl -D '$PRIMARY_PGDATA' \
  -o \"-p $PRIMARY_PORT -c listen_addresses='*'\" \
  -l '$PRIMARY_PGDATA/server.log' \
  start
"

psql -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$PRIMARY_DB_SUPERUSER" -d postgres -c "select version();"
