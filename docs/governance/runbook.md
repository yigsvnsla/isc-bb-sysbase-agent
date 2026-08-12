# Runbook de Operaciones y DR — sysbase-agent

## Operación diaria
- Inicio: `podman compose -f .container/compose.yml up -d postgres redis` luego `./mvnw spring-boot:run`.
- Consumo API: `token-create` / `apikey-create` (CLI), header `Authorization: Bearer` o `X-API-Key`.
- Auditoría: `audit-tail`, `audit-search` (CLI).
- Observabilidad (profile otel): `podman compose -f .container/compose.yml --profile otel up -d` — Tempo :4318, Grafana :3002, Prometheus :9090, Alertmanager :9093.

## Alertas (P1/P2/P3)
- Reglas: `.container/prometheus/alert.rules.yml` (severity critical/warning/info → rutas Alertmanager).
- UI: Alertmanager `http://localhost:9093`, reglas `http://localhost:9090/api/v1/rules`.
- Receivers: webhook placeholder en `.container/alertmanager/alertmanager.yml` (URL por entorno, p.ej. Slack Opsgenie) — ver `docs/audit/alert-rules.md` para el runbook de cada alerta.
- Nota de diseño: alertas sobre counters acumulados deben usar `increase(…[5m])`/`rate(…)`, nunca el counter crudo `> 0` (nunca se resuelven).

## Backup y restauración
| Componente | Método | Frecuencia |
|---|---|---|
| PostgreSQL (vector_store, ai_audit, api_keys) | `pg_dump` (usuario app) | Diario + antes de migraciones |
| Redis (memoria chat 6h, caches) | Volátil — no se respalda | — |
| Config | `.env` + `application.yml` en git (`.env` gitignored: respaldo manual) | Cada cambio |

Restaurar PG: `podman exec -i sp-docs-pg psql -U $POSTGRES_USER -d $POSTGRES_DB < dump.sql`.

## Recuperación ante desastre (DR)
1. **Caída de PG**: compose reinicia solo (restart: unless-stopped); si el volumen se corrompe → restaurar dump; los vectores se reindexan con `kb-index --force`.
2. **Caída de Redis**: el agente funciona sin memoria/cache (degradado); las conversaciones se pierden por diseño (TTL 6h).
3. **Caída de la app**: reiniciar; sin estado local (todo en PG/Redis).
4. **API key comprometida**: `apikey-revoke`, rotar JWT_SECRET (cambia firma → todos los JWT emisores deben actualizar).
5. **Rotación de JWT_SECRET sin downtime**: (a) setear `JWT_PREVIOUS_SECRET` con el secreto actual y reiniciar — los tokens emitidos con el secreto viejo siguen válidos; (b) cambiar `JWT_SECRET` al nuevo valor y reiniciar; (c) una vez todos los tokens viejos expiren (TTL), limpiar `JWT_PREVIOUS_SECRET`. Nunca rotar ambos al mismo tiempo.
6. **Proveedor LLM caído**: el agente responde con error controlado; considerar base-url alternativo en `.env`.

## Pruebas de DR
- Trimestral: restaurar dump en contenedor de pruebas y verificar `audit-tail` + 1 consulta RAG.
- Después de cada cambio de infraestructura: suite completa local.

## TODO(futuro)
- trivy escaneo de imagen containerfile en CI.
- Replicación PG (streaming) para alta disponibilidad.
- Export WORM de ai_audit antes del purge (ver AuditPurgeJob).
