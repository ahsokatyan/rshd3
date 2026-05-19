#!/bin/sh

# Node1: initial primary
export PRIMARY_HOST="${PRIMARY_HOST:-pg136}"
export PRIMARY_SSH_USER="${PRIMARY_SSH_USER:-postgres2}"
export PRIMARY_DB_SUPERUSER="${PRIMARY_DB_SUPERUSER:-postgres2}"
export PRIMARY_HOME="${PRIMARY_HOME:-/var/db/$PRIMARY_SSH_USER}"
export PRIMARY_PGDATA="${PRIMARY_PGDATA:-$PRIMARY_HOME/mtx89}"
export PRIMARY_PORT="${PRIMARY_PORT:-9909}"

# Node2: initial standby
export STANDBY_HOST="${STANDBY_HOST:-pg135}"
export STANDBY_SSH_USER="${STANDBY_SSH_USER:-postgres3}"
export STANDBY_DB_SUPERUSER="${STANDBY_DB_SUPERUSER:-postgres2}"
export STANDBY_HOME="${STANDBY_HOME:-/var/db/$STANDBY_SSH_USER}"
export STANDBY_PGDATA="${STANDBY_PGDATA:-$STANDBY_HOME/mtx89_standby}"
export STANDBY_PORT="${STANDBY_PORT:-9909}"

# pgpool-II runs locally in Docker and forwards PGPOOL_PORT to the container.
export PGPOOL_HOST="${PGPOOL_HOST:-127.0.0.1}"
export PGPOOL_SSH_USER="${PGPOOL_SSH_USER:-$STANDBY_SSH_USER}"
export PGPOOL_PORT="${PGPOOL_PORT:-9999}"
export PGPOOL_WORK_DIR="${PGPOOL_WORK_DIR:-$PWD/.pgpool_rshd3}"
export PGPOOL_CONF="${PGPOOL_CONF:-$PGPOOL_WORK_DIR/pgpool.conf}"
export PGPOOL_HBA="${PGPOOL_HBA:-$PGPOOL_WORK_DIR/pool_hba.conf}"
export PGPOOL_LOG="${PGPOOL_LOG:-$PGPOOL_WORK_DIR/pgpool.log}"
export PGPOOL_PID="${PGPOOL_PID:-$PGPOOL_WORK_DIR/pgpool.pid}"
export PGPOOL_DOCKER_NAME="${PGPOOL_DOCKER_NAME:-rshd3-pgpool}"
export PGPOOL_DOCKER_IMAGE="${PGPOOL_DOCKER_IMAGE:-rshd3-pgpool:local}"
export PGPOOL_DOCKER_BUILD_CONTEXT="${PGPOOL_DOCKER_BUILD_CONTEXT:-docker/pgpool}"

# Lab database and replication user
export TARGET_DB="${TARGET_DB:-rshd3}"
export REPL_USER="${REPL_USER:-rshd_repl}"
export REPL_PASSWORD="${REPL_PASSWORD:-rshd_repl_pass}"
