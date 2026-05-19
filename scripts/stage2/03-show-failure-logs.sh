#!/bin/sh
set -eu

. ./env.sh

echo "standby postgres log:"
tail -n 80 "$STANDBY_PGDATA/server.log" || true
