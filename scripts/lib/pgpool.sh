#!/bin/sh

write_pgpool_conf() {
  mkdir -p "$PGPOOL_WORK_DIR"

  cat > "$PGPOOL_CONF" <<EOF
listen_addresses = '*'
port = 9999
socket_dir = '/tmp'
pcp_socket_dir = '/tmp'
pid_file_name = '/tmp/pgpool.pid'
logdir = '/tmp'

backend_clustering_mode = 'streaming_replication'
load_balance_mode = on
replication_mode = off

backend_hostname0 = '$PRIMARY_HOST'
backend_port0 = $PRIMARY_PORT
backend_weight0 = 1
backend_data_directory0 = '$PRIMARY_PGDATA'
backend_flag0 = 'ALLOW_TO_FAILOVER'

backend_hostname1 = '$STANDBY_HOST'
backend_port1 = $STANDBY_PORT
backend_weight1 = 1
backend_data_directory1 = '$STANDBY_PGDATA'
backend_flag1 = 'ALLOW_TO_FAILOVER'

sr_check_period = 10
sr_check_user = '$PRIMARY_DB_SUPERUSER'
health_check_period = 10
health_check_user = '$PRIMARY_DB_SUPERUSER'

enable_pool_hba = off
EOF

  : > "$PGPOOL_HBA"
}

start_pgpool() {
  write_pgpool_conf

  echo "pgpool backend0: $PRIMARY_HOST:$PRIMARY_PORT"
  echo "pgpool backend1: $STANDBY_HOST:$STANDBY_PORT"
  echo "pgpool listen:   $PGPOOL_HOST:$PGPOOL_PORT"

  docker build -t "$PGPOOL_DOCKER_IMAGE" "$PGPOOL_DOCKER_BUILD_CONTEXT"
  docker rm -f "$PGPOOL_DOCKER_NAME" >/dev/null 2>&1 || true
  docker run -d \
    --name "$PGPOOL_DOCKER_NAME" \
    --add-host host.docker.internal:host-gateway \
    -p "$PGPOOL_PORT:9999" \
    -v "$PGPOOL_CONF:/etc/pgpool2/pgpool.conf:ro" \
    -v "$PGPOOL_HBA:/etc/pgpool2/pool_hba.conf:ro" \
    "$PGPOOL_DOCKER_IMAGE"
}

show_pgpool_logs() {
  docker logs --tail 80 "$PGPOOL_DOCKER_NAME" || true
}

check_pgpool() {
  if ! docker exec "$PGPOOL_DOCKER_NAME" psql -h 127.0.0.1 -p 9999 -U "$PRIMARY_DB_SUPERUSER" -d postgres -c "show pool_nodes;"; then
    echo "pgpool failed to accept connections; last log lines:"
    show_pgpool_logs
    exit 1
  fi
}
