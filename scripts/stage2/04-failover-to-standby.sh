#!/bin/sh
set -eu

. ./env.sh

pg_ctl -D "$STANDBY_PGDATA" promote
sleep 3

psql -h "$STANDBY_HOST" -p "$STANDBY_PORT" -U "$STANDBY_DB_SUPERUSER" -d postgres -c "select pg_is_in_recovery();"
