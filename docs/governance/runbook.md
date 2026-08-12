# Runbook de Operaciones y DR — sysbase-agent

## Operación diaria
- Inicio: `podman compose -f .container/compose.yml up -d postgres redis` luego `./mvnw spring-boot:run`.
- Consumo API: `token-create` / `apikey-create` (CLI), header `Authorization: Bearer` o `X-API-Key`.
- Auditoría: `audit-tail`, `audit-search` (CLI).

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
5. **Proveedor LLM caído**: el agente responde con error controlado; considerar base-url alternativo en `.env`.

## Pruebas de DR
- Trimestral: restaurar dump en contenedor de pruebas y verificar `audit-tail` + 1 consulta RAG.
- Después de cada cambio de infraestructura: suite completa local.

## TODO(futuro)
- trivy escaneo de imagen containerfile en CI.
- Replicación PG (streaming) para alta disponibilidad.
- Export WORM de ai_audit antes del purge (ver AuditPurgeJob).
