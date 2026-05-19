#!/bin/sh
set -eu

export PGPOOL_HOST="${PGPOOL_HOST:-127.0.0.1}"

. ./env.sh

docker exec -i "$PGPOOL_DOCKER_NAME" psql \
  -h 127.0.0.1 \
  -p 9999 \
  -U "$PRIMARY_DB_SUPERUSER" \
  -d "$TARGET_DB" <<SQL
BEGIN;
INSERT INTO clients(name) VALUES ('client_after_restore');
INSERT INTO orders(client_id, amount)
VALUES ((SELECT max(id) FROM clients), 500);
COMMIT;

SELECT inet_server_addr() AS server, * FROM clients ORDER BY id;
SELECT inet_server_addr() AS server, * FROM orders ORDER BY id;
SQL

docker exec -i "$PGPOOL_DOCKER_NAME" psql \
  -h 127.0.0.1 \
  -p 9999 \
  -U "$PRIMARY_DB_SUPERUSER" \
  -d postgres \
  -c "show pool_nodes;"
