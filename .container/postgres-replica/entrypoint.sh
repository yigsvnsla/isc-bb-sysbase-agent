#!/usr/bin/env bash
# Entrypoint de la réplica: hace pg_basebackup del primario si el volumen
# está vacío, configura streaming replication (standby.signal + primary_conninfo)
# y delega en el entrypoint oficial de la imagen postgres.
set -euo pipefail

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
PRIMARY_HOST="${PRIMARY_HOST:-postgres}"
PRIMARY_PORT="${PRIMARY_PORT:-5432}"
REPLICA_APP_NAME="${REPLICA_APPLICATION_NAME:-sp-docs-replica}"

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "[replica] Volumen vacío — pg_basebackup desde $PRIMARY_HOST:$PRIMARY_PORT..."
    mkdir -p "$PGDATA"
    chown -R postgres:postgres "$PGDATA"
    PGPASSWORD="$POSTGRES_PASSWORD" gosu postgres pg_basebackup \
        -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$POSTGRES_USER" \
        -D "$PGDATA" -Fp -Xs -P -R -w
    echo "primary_conninfo = 'host=$PRIMARY_HOST port=$PRIMARY_PORT user=$POSTGRES_USER password=$POSTGRES_PASSWORD application_name=$REPLICA_APP_NAME'" \
        >> "$PGDATA/postgresql.auto.conf"
    chown postgres:postgres "$PGDATA/postgresql.auto.conf"
    echo "[replica] Basebackup completado, standby.signal listo."
fi

exec docker-entrypoint.sh "$@"
