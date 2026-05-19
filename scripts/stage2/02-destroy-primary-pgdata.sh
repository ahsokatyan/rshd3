#!/bin/sh
set -eu

. ./env.sh

echo "This script removes PGDATA on the initial primary node:"
echo "$PRIMARY_SSH_USER@$PRIMARY_HOST:$PRIMARY_PGDATA"
echo "Press Enter to continue, or Ctrl+C to stop."
read _

ssh "$PRIMARY_SSH_USER@$PRIMARY_HOST" "pg_ctl -D '$PRIMARY_PGDATA' stop -m immediate >/dev/null 2>&1 || true; rm -rf '$PRIMARY_PGDATA'"

