# sysbase-agent

Spring Boot 4.1.1-SNAPSHOT + Java 26 AI agent. DeepSeek LLM + PGVector (384d, HNSW) + ONNX Transformer embeddings + Redis cache/memory + PostgreSQL tools + Spring Shell CLI.

## Quick start

```bash
podman compose -f .container/compose.yml up -d     # PostgreSQL + Redis
./mvnw clean compile                              # build
./mvnw spring-boot:run                            # dev server (DevTools hot reload, Shell + Tomcat)
SPRING_PROFILES_ACTIVE=prod ./mvnw spring-boot:run # producción (solo Shell)
```

## Architecture

- **Main class**: `com.isc.bb.sysbase_agent.SysbaseAgentApplication`
- **Package root**: `com.isc.bb.sysbase_agent` (note underscore — from Maven `artifactId` with dash)
- **Project state**: early but functional — ChatClient agent with RAG + tools + memory
- **Database**: PostgreSQL `localhost:5432/sp_docs` (vars desde `.env`)
- **Vector store**: PGVector, HNSW index, 384d, auto-schema init
- **Cache + memory**: Redis (misma instancia para chat memory + cache `sp_source`, `sp_search`)
- **AI model**: DeepSeek chat (vía `spring-ai-starter-model-openai`) + ONNX Transformer embeddings (`spring-ai-starter-model-transformers`) — default `all-MiniLM-L6-v2` (384d)
- **Model Router** (Fase 1+2): `ModelRouter` clasifica cada prompt en tier `CHEAP` o `EXPENSIVE` vía heurística (intent regex + keywords + longitud + historial ≥10 msgs). Para scores en rango gris (0.35-0.55), invoca `LlmClassifier` (micro-LLM, maxTokens=8, temperature=0, timeout 1.5s) que responde `CHEAP`/`EXPENSIVE`. Cache Redis `router:dec:{sha256}` TTL 1h evita reclasificar prompts repetidos. Tres beans `ChatClient` (`chatClientCheap`/`chatClientExpensive`/`chatClientClassifier`) con modelos distintos. Threshold `app.ai.router.score-threshold: 0.6`. Métricas: `ai_router_decisions_total{tier}`, `ai_chat_duration_seconds{tier}`, `ai_router_classifier_calls_total{outcome}`, `ai_router_cache_total{result}` en actuator.
- **Auditoría + WORM** (F2/F12a): `ai_audit` particionada por mes (PG nativo, partición default + mensuales vía `AuditPartitionJob`); export JSONL append-only con hash chain HMAC-SHA256 (`AuditWormExportService`, clave `app.audit.worm.hmac-secret` validada por `WormHmacSecretValidator` — sin ella, SHA-256 plano permitiría a cualquiera con acceso de escritura al filesystem recalcular la cadena; cron 02:00, `app.audit.worm.*`), CLI `worm-export`/`worm-verify`; purge solo borra eventos exportados (`purgeBefore`), luego dropea particiones vencidas si no quedan sin exportar.
- **HITL** (F14): tools de escritura (`index_procedure`) en contexto HTTP crean solicitud PENDING en `approval_requests` — REST `/v1/admin/approvals` (solo ADMIN, reforzado con `@PreAuthorize("hasRole('ADMIN')")` a nivel de clase además de la regla de path en `SecurityConfig`) GET/approve/reject + CLI `approvals-list/approve/reject`; al aprobar se ejecuta la tool real con args originales y se audita. Shell (rol null) ejecuta directo.
- **JWT**: firma HS256 con `kid` (header), decoder selecciona clave por kid (`JwtDecoders.withKid`, 2 claves activas para rotación sin downtime, algoritmo restringido explícitamente a HS256), propiedades `app.security.jwt.key-id`/`previous-key-id`. `JwtSecretValidator` rechaza el arranque si `SPRING_PROFILES_ACTIVE=prod` y el secreto es el default de dev o <32 bytes; si no hay ningún perfil activo y se usa el default, emite un `WARN` (probable despliegue que olvidó fijar el profile). **Revocación**: cada token lleva claim `jti` único; `JwtRevocationService` mantiene denylist en Redis (`jwt:revoked:{jti}`, TTL = validez restante), chequeada en el decoder vía `OAuth2TokenValidator` compuesto con `JwtValidators.createDefault()`. CLI `token-revoke --token <jwt>` (parsea el JWT sin verificar para extraer `jti`/`exp`, no requiere el secreto).
- **Rate limiting**: `RateLimitFilter` (Redis, ventana fija 60s) solo confía en `X-Forwarded-For` si la request viene de una IP/CIDR en `app.security.trusted-proxies` (env `TRUSTED_PROXIES`); vacío por defecto = siempre usa la IP real de conexión TCP, evitando bypass del límite por header spoofeado.
- **Tools por rol**: `AgentService.toolsForRole()` filtra el array de `ToolCallback` antes de pasarlo a `.tools(...)` — el LLM nunca ve en su schema las tools que el rol no puede invocar. `AuditedToolCallback.guardedCall()` + `ToolAccessGuard.canInvoke()` son el backstop en runtime (defensa en profundidad), no el mecanismo primario.
- **Multi-motor (F1)**: exploración de catálogo multi-BD vía `CatalogDialect` (PostgresDialect completo, MsSqlDialect, OracleDialect, SybaseDialect core). `DatabaseRegistry` resuelve motor por nombre: `app.databases.default-engine` + `app.databases.connections.<nombre>.{engine,url,username,password}` (`postgres` reservado = DataSource primario). Selección por header `X-Engine` o campo `engine` del payload, persistida por conversación en Redis (`chat:engine:{convId}`, `EngineResolver`); default postgres. Tests opt-in `MultiDbDialectE2ETest`: `RUN_MULTIDB_TESTS=true ./mvnw test -Dtest=MultiDbDialectE2ETest` (imágenes ~1.5GB) — corren automáticamente en el job `nightly-extended` de CI (cron diario + `workflow_dispatch`), no en cada PR.
- **OIDC/Keycloak**: decoder con fallback a JWKS de OIDC vía `app.security.oidc.issuer-uri` (env `OIDC_ISSUER_URI`); `jwtAuthenticationConverter` mapea `realm_access.roles` de Keycloak (READONLY/DOC/ADMIN). Dev: `podman compose --profile keycloak up -d keycloak` → `./.container/keycloak/setup.sh` (realm `sysbase`, cliente `sysbase-agent`, user `agent-test`/DOC) → arrancar con `OIDC_ISSUER_URI=http://localhost:8081/realms/sysbase`. Test E2E `KeycloakE2ETest` (Testcontainers).
- **Seguridad contenedor** (F13): `.container/containerfile` non-root + rootfs read-only + tmpfs `/tmp` + volúmenes `/app/config /app/cache(ONNX) /app/data(WORM)`; healthcheck `/api/actuator/health`; Trivy HIGH/CRITICAL gate en CI (`.github/workflows/ci.yml` job `security`); `.dockerignore` excluye `.env`.
- **Alertas**: `.container/prometheus/alert.rules.yml` (9 reglas) + métrica `ai_token_budget_daily_chars` (gauge, alarma 80% vía `TokenBudgetWarning`).
- **Interfaces**: Spring Shell CLI (principal), REST v1 (controller), REST v2 (functional)
- **Container**: `.container/compose.yml` (PostgreSQL + Redis) + `containerfile` (ver F13 — hardening ya implementado)

## Config & secrets

- **`src/main/resources/application.yml`** — main config (DB, AI, vector store)
- **`.env`** — `DEEPSEEK_API_KEY` + `POSTGRES_DB`/`POSTGRES_USER`/`POSTGRES_PASSWORD`; loaded by Spring via `spring.config.import: optional:file:.env[.properties]` and by Docker Compose via `env_file: ../.env`
- `.env` is gitignored — **never commit it**
- `.vscode/` also gitignored (launch config uses `envFile: .env`)

## Dependencies

- `spring-boot-starter-webmvc` (Spring Boot 4 uses `webmvc`, not `web`)
- `spring-boot-starter-actuator`
- `spring-boot-devtools` (runtime, optional)
- `spring-boot-starter-jdbc`
- `spring-boot-starter-data-redis` + `spring-boot-starter-cache` + `commons-pool2`
- `spring-shell-starter` (CLI)
- `spring-ai-starter-model-deepseek` (chat)
- `spring-ai-starter-model-transformers` (ONNX embeddings — `all-MiniLM-L6-v2`, 384d)
- `spring-ai-starter-vector-store-pgvector` (Spring AI BOM 2.0.0)
- `postgresql` (runtime)

## Toolchain quirks

- **Maven wrapper 3.9.16** — use `./mvnw`, not system `mvn`
- **Java 26** — verify JDK 26 is installed; boot plugin es `4.1.1-SNAPSHOT` (pre-release, pulls from `repo.spring.io/snapshot`). Riesgo de cadena de suministro aceptado deliberadamente para esta prueba de concepto (requiere Java 26 preview + Spring Boot 4 API nuevas); no downgradear sin planear una migración completa de dependencias.
- **Sin Lombok** — se retiró la dependencia (declarada en `pom.xml` pero 0% adoptada en el código; todos los constructores son manuales).
- **Tests con Testcontainers** necesitan el socket de podman: `export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock` (daemon rootless con `--time=0` vía `~/.config/systemd/user/podman.service.d/idle.conf`)

## Testing

```bash
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
./mvnw test                         # suite normal (Testcontainers PG+Redis); excluye @Tag("load") por defecto
./mvnw test -Dtest=SysbaseAgentApplicationTests  # single test
./mvnw test -Dtest=LoadE2ETest -DexcludedGroups= # correr explícitamente el test de carga
RUN_MULTIDB_TESTS=true ./mvnw test -Dtest=MultiDbDialectE2ETest -DexcludedGroups=  # MSSQL/Oracle/Sybase
```

Los tests integran con Testcontainers (PG/Redis reales vía podman). El eval harness (`EvalHarnessTest`, incl. LLM-judge) se omite sin `IA_API_KEY` exportada como env real. `LoadE2ETest` (`@Tag("load")`) y `MultiDbDialectE2ETest` quedan fuera de `mvn test`/`verify` por defecto (`<excludedGroups>load</excludedGroups>` + gate de env var) y corren en el job `nightly-extended` de CI.

## Verification order

1. `./mvnw clean compile` — compiler + annotation processors
2. `./mvnw test` — context load test (needs PG on `localhost:5432`)
3. `./mvnw spring-boot:run` — dev server
