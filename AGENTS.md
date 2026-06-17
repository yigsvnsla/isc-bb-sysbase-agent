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
- **AI model**: DeepSeek chat (`spring-ai-starter-model-deepseek`) + ONNX Transformer embeddings (`spring-ai-starter-model-transformers`) — default `all-MiniLM-L6-v2` (384d)
- **Interfaces**: Spring Shell CLI (principal), REST v1 (controller), REST v2 (functional)
- **Container**: `.container/compose.yml` (PostgreSQL + Redis); `containerfile` still empty

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
- `lombok` (annotation processor, excluded from boot jar)

## Toolchain quirks

- **Maven wrapper 3.9.16** — use `./mvnw`, not system `mvn`
- **Java 26** — verify JDK 26 is installed; boot plugin is `4.1.1-SNAPSHOT` (pre-release, pulls from `repo.spring.io/snapshot`)
- **Lombok** requires annotation processor config in `pom.xml` (already done)
- **No git commits yet** — repo is fresh; first commit should exclude `.env` and `target/`

## Testing

```bash
./mvnw test                         # all tests
./mvnw test -Dtest=SysbaseAgentApplicationTests  # single test
```

Only one test exists (`@SpringBootTest` context load). Needs PG running — use `.container/compose.yml` or `@Disabled` if DB unavailable.

## Verification order

1. `./mvnw clean compile` — compiler + annotation processors
2. `./mvnw test` — context load test (needs PG on `localhost:5432`)
3. `./mvnw spring-boot:run` — dev server
