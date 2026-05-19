#!/bin/sh
set -eu

export PRIMARY_HOST="${PRIMARY_HOST:-host.docker.internal}"
export PRIMARY_PORT="${PRIMARY_PORT:-9909}"
export STANDBY_HOST="${STANDBY_HOST:-host.docker.internal}"
export STANDBY_PORT="${STANDBY_PORT:-9910}"
export PGPOOL_HOST="${PGPOOL_HOST:-127.0.0.1}"

. ./env.sh
. ./scripts/lib/pgpool.sh

start_pgpool
sleep 3
check_pgpool
