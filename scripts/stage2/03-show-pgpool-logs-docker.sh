#!/bin/sh
set -eu

export PGPOOL_HOST="${PGPOOL_HOST:-127.0.0.1}"

. ./env.sh
. ./scripts/lib/pgpool.sh

echo "pgpool log:"
show_pgpool_logs
