#!/bin/sh
set -eu

export PGPOOL_HOST="${PGPOOL_HOST:-127.0.0.1}"

. ./env.sh

docker exec -i "$PGPOOL_DOCKER_NAME" psql \
  -h 127.0.0.1 \
  -p 9999 \
  -U "$PRIMARY_DB_SUPERUSER" \
  -d postgres <<SQL
DROP DATABASE IF EXISTS $TARGET_DB;
CREATE DATABASE $TARGET_DB;
SQL

docker exec -i "$PGPOOL_DOCKER_NAME" psql \
  -h 127.0.0.1 \
  -p 9999 \
  -U "$PRIMARY_DB_SUPERUSER" \
  -d "$TARGET_DB" <<SQL
CREATE TABLE clients (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE orders (
  id serial PRIMARY KEY,
  client_id integer NOT NULL REFERENCES clients(id),
  amount integer NOT NULL
);

BEGIN;
INSERT INTO clients(name) VALUES ('alice'), ('bob');
INSERT INTO orders(client_id, amount) VALUES (1, 100), (2, 200);
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
