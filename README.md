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

## Testing

```bash
./mvnw test                         # all tests
./mvnw test -Dtest=SysbaseAgentApplicationTests  # single test
```

Needs PG running — use `.container/compose.yml` or `@Disabled` if DB unavailable.

## Verification order

1. `./mvnw clean compile` — compiler + annotation processors
2. `./mvnw test` — context load test (needs PG on `localhost:5432`)
3. `./mvnw spring-boot:run` — dev server

---

## Estructura de paquetes y componentes

```
com.isc.bb.sysbase_agent/
│
├── SysbaseAgentApplication          ← @SpringBootApplication + @EnableScheduling
│
├── config/
│   ├── AgentConfig                  ← Crea 3 ChatClient beans + ObjectMapper + RedisChatMemory
│   ├── WebConfiguration             ← CORS /chat/**, /models
│   └── StreamFixConfig              ← WebClient filter: inyecta "id" en SSE chunks sin ID
│
├── service/
│   └── AgentService                 ← Router → ChatClient → MarkdownFixer → métricas
│
├── controller/                      ← REST v1 (Servlet)
│   ├── AgentController              ← POST /api/v1/agent/chat
│   └── OpenAiCompatController       ← GET /models, POST /chat/completions (SSE)
│
├── handler/                         ← REST v2 (Functional)
│   ├── AgentHandler                 ← Delegates to AgentService
│   └── AgentRoutes                  ← POST /api/v2/agent/chat
│
├── tools/                           ← @Tool expuestos al LLM (22 tools total)
│   ├── PostgresTools                ← 19 tools: SPs, tablas, vistas, triggers, secuencias, enums, tipos, dependencias
│   ├── KnowledgeBaseTool            ← 2 tools: search_knowledge_base, analyze_sql
│   └── SpDocLoader                  ← 1 tool: index_procedure
│
├── router/                          ← Model Router (Fase 1+2)
│   ├── ModelRouter                  ← Heurística: intent + keywords + length + history → CHEAP/EXPENSIVE
│   ├── LlmClassifier               ← Micro-LLM (maxTokens=8, temp=0, timeout 1.5s) para zona gris
│   ├── RouterDecision               ← record(tier, score, reason)
│   └── Tier                         ← enum CHEAP, EXPENSIVE
│
├── loader/                          ← Ingesta al vector store (arranque)
│   ├── KnowledgeBaseLoader          ← PDFs + SQLs + TXTs + MDs → TokenTextSplitter → VectorStore
│   └── SpDocLoader                  ← Carga SPs de sp_docs/ al vector store
│
├── reader/                          ← Lectores de documentos
│   ├── PdfDocumentReader            ← PDFBox 3.0.3, extrae texto por página
│   ├── SqlFileReader                ← SQL/TXT con metadata (engine, schema, object_type)
│   └── MarkdownReader               ← .md → Document
│
├── cli/                             ← Spring Shell CLI
│   ├── AgentCli                     ← ask --msg, chat (interactivo)
│   └── KnowledgeBaseCli             ← kb-index --file/--reboot, kb-status
│
├── documentation/                   ← Subsistema documentación (ports & adapters)
│   ├── model/                       ← DocumentContent, DocumentMeta, DocumentType, PublishResult
│   ├── port/DocumentPublisher       ← Interfaz puerto
│   ├── adapter/
│   │   ├── DocusaurusPublisher      ← Escribe .md con YAML frontmatter + genera sidebars.js
│   │   └── ConfluencePublisher      ← Stub: "not yet implemented"
│   ├── generator/                   ← 9 generadores de docs por tipo de objeto
│   │   ├── SchemaDocGenerator, ProcedureDocGenerator, TableDocGenerator,
│   │   ├── ViewDocGenerator, TriggerDocGenerator, SequenceDocGenerator,
│   │   ├── EnumDocGenerator, CompositeTypeDocGenerator,
│   │   ├── MigrationDocGenerator, StandardsDocGenerator
│   ├── indexer/
│   │   ├── SchemaIndexer            ← Itera objetos BD → generators → publisher → sidebar
│   │   └── IndexResult              ← Contador de generated/updated/skipped/errors
│   ├── config/
│   │   ├── DocumentationConfig      ← Bean DocusaurusPublisher
│   │   └── AutoIndexRunner          ← @Scheduled 5min + startup, indexa todos los schemas
│   └── cli/DocumentationCli         ← doc-generate, doc-publish, doc-index, doc-status
│
├── dto/                             ← DTOs para OpenAI compat API
│   ├── OpenAiModelList, OpenAiModel, OpenAiChunk, OpenAiChatRequest
│
├── memory/                          ← Chat memory en Redis
│   └── RedisChatMemoryRepository    ← Keys: chat:memory:{convId}, TTL 6h, WindowSize=50
│
└── util/
    └── MarkdownFixer                ← Corrige headers, mermaid typos, newlines post-mermaid
```

## Configuración y perfiles

| Archivo | Rol |
|---|---|
| `application.yml` | Main: DB, AI (DeepSeek), ONNX embeddings, PGVector, Redis cache, Router, Docs, metrics |
| `application-web.yml` | `spring.shell.interactive.enabled=false` — solo Tomcat |
| `application-prod.yml` | `spring.main.web-application-type=none` — solo Shell CLI |
| `.env` | Secretos: `IA_API_KEY`, `POSTGRES_*`, `IA_API_MODEL_CHEAP/EXPENSIVE` |

### Modelos de ChatClient

| Bean | Modelo | Herramientas | Memoria | Uso |
|---|---|---|---|---|
| `chatClientCheap` | deepseek-v4-flash | PostgresTools + KBTool + SpDocLoader | 50 msgs | Preguntas simples |
| `chatClientExpensive` | deepseek-v4-pro | PostgresTools + KBTool + SpDocLoader | 50 msgs | Análisis complejo |
| `chatClientClassifier` | deepseek-v4-flash | — | — | Clasificar CHEAP/EXPENSIVE |

## Interfaces disponibles

| Interfaz | Endpoint/Comando | Tipo |
|---|---|---|
| REST v1 | `POST /api/v1/agent/chat` | JSON in/out |
| REST v2 | `POST /api/v2/agent/chat` | Functional, mismo contrato |
| OpenAI Compat | `GET /api/models` | Lista modelos |
| OpenAI Compat | `POST /api/chat/completions` | SSE stream |
| CLI | `ask --msg "..."` | Shell interactivo |
| CLI | `chat` | Conversación interactiva |
| CLI | `kb-index --file/--reboot` | Indexar PDFs |
| CLI | `kb-status` | Contar chunks vector_store |
| CLI | `doc-generate --type --schema` | Generar documentación |
| CLI | `doc-publish --rebuild` | Reconstruir sidebars |
| CLI | `doc-index --schema/--all` | Indexar objetos BD |
| CLI | `doc-status` | Estado docs por categoría |

## Pipeline de ingesta (arranque automático)

```
Inicio
  ├── PDFs: classpath:static/documents/**/*.pdf
  │     → PdfDocumentReader (PDFBox por página)
  │     → TokenTextSplitter (chunk=1200, min=350)
  │     → VectorStore.add()
  ├── SQLs: static/documents/ejemplos/**/*.sql
  │     → SqlFileReader (detecta engine/schema/object_type)
  │     → TokenTextSplitter → VectorStore
  ├── TXTs: static/documents/ejemplos/**/*.txt
  │     → SqlFileReader.readText() → splitter → VectorStore
  ├── MDs: static/documents/**/*.md
  │     → MarkdownReader → splitter → VectorStore
  └── Docs MDs: .container/docs/**/*.md (no intro.md ni index.md)
        → MarkdownReader → splitter → VectorStore
```

**Búsqueda semántica**: `VectorStore.similaritySearch(topK=12, threshold=0.25)` → si <5 resultados → fallback ILIKE keyword en `vector_store` (LIMIT 5).

## Flujo del Model Router

```
AgentService.chat(convId, msg)
  │
  ├── historySize = chatMemory.get(convId).size()
  │
  ├── ModelRouter.route(msg, historySize)
  │   │
  │   ├── ¿Vacío? → fallback tier (CHEAP)
  │   ├── Cache Redis ("router:dec:{sha256}") → HIT? → retorna cached
  │   │
  │   ├── Heurística:
  │   │   ├── INTENT_SIMPLE regex match? → score 0.0, CHEAP
  │   │   ├── KEYWORDS_EXPENSIVE hits? → +0.4/hit (cap 0.8)
  │   │   ├── len > 1500? → +0.30
  │   │   ├── len ≥ 200? → +0.15
  │   │   ├── historySize ≥ 10? → +0.15
  │   │   └── score ≥ threshold(0.6)? → EXPENSIVE : CHEAP
  │   │
  │   ├── Zona gris (score 0.35-0.55)?
  │   │   └── LlmClassifier.classify(msg)
  │   │       ├── Responde "CHEAP"/"EXPENSIVE" → usa ese
  │   │       └── Falla/null → fallback tier
  │   │
  │   └── Cache tier en Redis (TTL 60min)
  │
  ├── ChatClient.call() + MarkdownFixer.fix()
  │
  └── Métricas: ai_router_decisions_total{tier}, ai_chat_duration_seconds{tier}
```

---

## Capacidades del agente

### Base de conocimiento

| N° | Capacidad | Tool |
|---|---|---|
| C1 | Buscar documentación técnica en PDFs indexados | `search_knowledge_base` |
| C2 | Responder en español como experto en BD relacionales | System prompt |
| C3 | Priorizar info de knowledge base sobre conocimiento general | System prompt |
| C4 | Indexar PDFs, SQLs, TXTs y MDs al vector store automáticamente | `KnowledgeBaseLoader` (startup) |
| C5 | Reindexar toda la base de conocimiento | `KnowledgeBaseCli.kb-index --reboot` |

### Exploración de base de datos (PostgreSQL catalog)

| N° | Capacidad | Tool |
|---|---|---|
| C6 | Buscar SPs/funciones por nombre (ILIKE) | `search_procedures` |
| C7 | Listar todos los SPs/funciones de un schema | `list_procedures` |
| C8 | Ver código fuente completo de un SP/función | `get_procedure_source` |
| C9 | Listar schemas con SPs | `list_schemas` |
| C10 | Listar todos los schemas de usuario | `list_all_schemas` |
| C11 | Listar tablas en un schema | `list_tables` |
| C12 | Inspeccionar tabla: DDL, columnas, índices, constraints, triggers | `get_table_info` |
| C13 | Listar vistas en un schema | `list_views` |
| C14 | Ver definición SQL de una vista | `get_view_definition` |
| C15 | Ver columnas de una vista | `get_view_columns` |
| C16 | Listar triggers en un schema | `list_triggers` |
| C17 | Ver definición SQL de un trigger | `get_trigger_definition` |
| C18 | Listar secuencias en un schema | `list_sequences` |
| C19 | Listar tipos ENUM en un schema | `list_enums` |
| C20 | Ver valores de un tipo ENUM | `get_enum_values` |
| C21 | Listar tipos compuestos en un schema | `list_composite_types` |
| C22 | Ver atributos de un tipo compuesto | `get_composite_type_attrs` |
| C23 | Analizar dependencias (tablas referenciadas) de un SP | `get_dependencies` |

### Análisis de código SQL

| N° | Capacidad |
|---|---|
| C24 | Detectar dialecto SQL: Sybase ASE, MSSQL, Oracle, PostgreSQL |
| C25 | Identificar estructura: SP, función, trigger, vista, DDL, DML, query |
| C26 | Extraer tablas referenciadas en SQL |
| C27 | Extraer parámetros (@param Sybase/MSSQL, p_param Oracle) |
| C28 | Detectar operaciones: SELECT, INSERT, UPDATE, DELETE, MERGE |
| C29 | Validar naming conventions por motor (Sybase/MSSQL/Oracle/PostgreSQL) |
| C30 | Validar contra estándar ARQT-EST-001 (prefijos pa_, @e_, @s_, @v_, cabeceras, REFs) |
| C31 | Buscar documentación relacionada automáticamente (tablas → vector search) |

### Documentación

| N° | Capacidad |
|---|---|
| C32 | Generar documentación de stored procedures (ficha técnica + source + dependencias) |
| C33 | Generar documentación de tablas (columnas + constraints + índices + DDL + diagrama ER Mermaid) |
| C34 | Generar documentación de vistas, triggers, secuencias, enums, tipos compuestos |
| C35 | Generar catálogo de schema con tabla resumen de SPs |
| C36 | Generar documentación de estándares (ARQT-EST-001 por motor) |
| C37 | Generar documentación de migraciones (análisis fuente → equivalencias) |
| C38 | Publicar documentación a Docusaurus (Markdown + sidebars.js) |
| C39 | Indexar automáticamente schemas completos con detección de cambios (SHA-256 hash) |
| C40 | Auto-index programado cada 5 minutos |

### Visualización

| N° | Capacidad |
|---|---|
| C41 | Generar diagramas Mermaid: flowchart, ER, secuencia |
| C42 | Corregir formato Markdown automáticamente (headers, mermaid typos, newlines) |

### Enrutamiento inteligente

| N° | Capacidad |
|---|---|
| C43 | Clasificar prompts en tier CHEAP (flash) o EXPENSIVE (pro) |
| C44 | Usar heurística: intención simple, keywords complejas, longitud, historial |
| C45 | Invocar micro-LLM clasificador en zona gris |
| C46 | Cachear decisiones de ruteo en Redis (TTL 1h, SHA-256) |
| C47 | Emitir métricas Micrometer: router_decisions, chat_duration, classifier_calls, cache_hits |

### Memoria y conversación

| N° | Capacidad |
|---|---|
| C48 | Mantener historial de conversación por conversationId |
| C49 | Ventana deslizante de 50 mensajes |
| C50 | TTL de 6 horas en Redis |

### APIs e integración

| N° | Capacidad |
|---|---|
| C51 | Endpoint REST v1 JSON in/out: `POST /api/v1/agent/chat` |
| C52 | Endpoint REST v2 (functional): `POST /api/v2/agent/chat` |
| C53 | API OpenAI-compatible (models + chat/completions SSE): `GET /models`, `POST /chat/completions` |
| C54 | Compatibilidad con OpenWebUI (detección `### Task:`) |
| C55 | CLI Spring Shell interactiva: `ask`, `chat`, `kb-*`, `doc-*` |
| C56 | CORS habilitado para `/chat/**` y `/models` |

### Infraestructura

| N° | Capacidad |
|---|---|
| C57 | Cache Redis para SP source y search results (TTL 10min) |
| C58 | PGVector HNSW index, 384d, auto-schema init |
| C59 | ONNX embeddings on-device (sin llamada API) |
| C60 | Health checks y métricas vía Actuator |
| C61 | Hot reload en desarrollo (DevTools) |
| C62 | 3 perfiles: default (Shell+Web), web (solo Web), prod (solo Shell) |

---

## Limitaciones del agente

| N° | Limitación | Razón |
|---|---|---|
| L1 | Ejecutar SQL en bases de datos Sybase/MSSQL/Oracle reales | Solo conecta a PostgreSQL local (catálogo) |
| L2 | Conectarse a instancias remotas de Sybase ASE | No hay driver JDBC Sybase |
| L3 | Modificar datos/objetos (INSERT, UPDATE, DELETE, DROP, ALTER) | Solo lectura de pg_catalog |
| L4 | Ejecutar migraciones reales de datos | Solo análisis y documentación |
| L5 | Autenticar usuarios | Sin auth implementado |
| L6 | Gestionar múltiples tenants/usuarios | Diseñado para single-tenant |
| L7 | Monitoreo de performance en tiempo real | Sin conexión a BD target |
| L8 | Generar scripts de migración ejecutables completos | Solo análisis de equivalencias |
| L9 | Publicar a Confluence | ConfluencePublisher es stub |
| L10 | Procesar imágenes, audio u otros formatos no-texto | Sin soporte multimodal |
| L11 | Recibir archivos vía chat API | Chat endpoint solo acepta texto |
| L12 | Streaming real vía endpoint simple | Solo OpenAI compat endpoint hace SSE |
| L13 | Fine-tuning del modelo | Usa modelos remotos vía API |
| L14 | Cambiar modelo de embedding en runtime | Configuración estática en application.yml |
| L15 | Balanceo de carga entre múltiples proveedores LLM | Solo un endpoint configurado |
| L16 | A/B testing de prompts | Sin infraestructura para experimentación |
| L17 | Registrar auditoría de uso de herramientas | Sin tabla de auditoría ni logs estructurados |
| L18 | Recuperación granular de errores por herramienta | Error handling genérico en catch del chat |
| L19 | Trabajar con archivos locales grandes (>10000 chunks) | TokenTextSplitter limita maxChunks=10000 |
| L20 | Procesar múltiples archivos PDF simultáneos en chat | Ingesta es solo al arranque |
| L21 | Consultas SQL complejas sobre el vector store | Solo búsqueda semántica + keyword ILIKE |
| L22 | Gestionar índices HNSW manualmente | Auto-gestionado por Spring AI |
| L23 | Funcionar sin PostgreSQL | Requiere PG para vector store + tools |
| L24 | Usar embedding model diferente a 384d sin migración | Dimensiones fijas en schema |

---

## Prompt para presentación del proyecto

> Usa este prompt con un LLM para generar una presentación técnica completa del proyecto.

```
Eres un arquitecto de software senior especializado en crear presentaciones
técnicas de alto impacto. Necesito que generes una presentación completa
(markdown, reveal.js o PowerPoint) sobre el proyecto "sysbase-agent".

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DATOS DEL PROYECTO:

sysbase-agent es un agente de IA (Spring Boot 4.1.1 + Java 26 + Spring AI 2.0.0)
diseñado como asistente experto en bases de datos relacionales: Sybase ASE,
SQL Server, Oracle y PostgreSQL. Su audiencia son desarrolladores que necesitan
analizar, documentar, estandarizar y migrar stored procedures entre motores.

Stack tecnológico:
- LLM: DeepSeek v4 (flash/pro) vía OpenAI-compatible API
- Embeddings: ONNX Transformer all-MiniLM-L6-v2 (384d, on-device)
- Vector store: PGVector HNSW en PostgreSQL 16
- Cache/Memoria: Redis 7 (Lettuce)
- Interfaces: REST v1, REST v2 functional, OpenAI-compatible API (SSE), Spring Shell CLI
- Documentación: Docusaurus (puerto 3001)
- Containerización: Podman (PostgreSQL + Redis + OpenWebUI + Docusaurus)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REQUISITOS DE LA PRESENTACIÓN:

1. ESTRUCTURA (8-12 slides):

   Slide 1 — Título y propósito
     - "sysbase-agent: Agente IA Experto en Bases de Datos"
     - Tagline: "Análisis, documentación y migración inteligente de SPs"

   Slide 2 — Arquitectura general (diagrama)
     - Diagrama de componentes: Usuario → [CLI / REST / OpenWebUI] → AgentService
       → ModelRouter → [chatClientCheap | chatClientExpensive] → DeepSeek API
     - Tools: PostgresTools (19), KnowledgeBaseTool (2)
     - Memoria: Redis (conversaciones 50 msgs, TTL 6h)
     - Cache: Redis (SP source, búsquedas semánticas, decisiones router)
     - Ingesta: PDFs/SQLs/MDs → TokenTextSplitter → PGVector (384d, HNSW)
     - Documentación: SchemaIndexer → Generators → Docusaurus

   Slide 3 — Model Router (diagrama de flujo)
     - Flujo: prompt → [Cache Redis?] → [Heurística: intent+keywords+length+history]
       → [Zona gris? → LlmClassifier] → CHEAP (flash) / EXPENSIVE (pro)
     - Heurística: INTENT_SIMPLE regex, KEYWORDS_EXPENSIVE regex (+0.4/hit, cap 0.8),
       length >1500 (+0.3), history ≥10 (+0.15), threshold 0.6
     - Métricas: ai_router_decisions_total, ai_chat_duration_seconds,
       ai_router_classifier_calls_total, ai_router_cache_total

   Slide 4 — Herramientas del agente (tabla)
     - Tabla con 22 tools agrupadas en 3 categorías:
       A) Exploración BD (PostgresTools: 19 tools)
       B) Base de conocimiento (KnowledgeBaseTool: search_knowledge_base, analyze_sql)
       C) Indexación (SpDocLoader: index_procedure)

   Slide 5 — Pipeline de ingesta (diagrama)
     - PDFs → PdfDocumentReader (PDFBox página x página)
     - SQLs → SqlFileReader (detecta engine, schema, object_type)
     - TXTs → SqlFileReader.readText()
     - MDs → MarkdownReader
     - Todo → TokenTextSplitter (chunk=1200, min=350, max=10000)
     - → PGVector (HNSW, 384d)
     - Búsqueda: similaridad (topK=12, threshold=0.25) → fallback keyword ILIKE (<5 resultados)

   Slide 6 — Análisis de SQL (diagrama)
     - analyze_sql pipeline:
       Código SQL → [Detectar dialecto: scoring Sybase/MSSQL/Oracle/PG]
       → [Parsear estructura: SP/function/trigger/view/DDL/DML]
       → [Extraer tablas, parámetros, operaciones]
       → [Validar naming conventions por motor]
       → [Validar ARQT-EST-001: prefijos pa_, @e_, @s_, @v_, cabeceras, REFs]
       → [Búsqueda docs relacionadas vía vector search]
     - Ejemplo con código Sybase real

   Slide 7 — Documentación automática (diagrama)
     - SchemaIndexer → [TableDocGenerator → Mermaid ER] →
       [ProcedureDocGenerator → ficha + source + dependencias] →
       [ViewDocGenerator], [TriggerDocGenerator], etc.
     - DocusaurusPublisher: .md con YAML frontmatter + sidebars.js
     - AutoIndexRunner: @Scheduled 5min + startup, detección cambios SHA-256
     - CLI: doc-generate, doc-publish, doc-index, doc-status

   Slide 8 — Interfaces y APIs
     - REST v1: POST /api/v1/agent/chat (JSON in/out)
     - REST v2: POST /api/v2/agent/chat (functional)
     - OpenAI Compat: GET /api/models, POST /api/chat/completions (SSE)
     - OpenWebUI integration: detección "### Task:", respuesta JSON estructurada
     - CLI: ask, chat, kb-index, kb-status, doc-*
     - CORS habilitado

   Slide 9 — Memoria y conversación
     - RedisChatMemoryRepository: keys "chat:memory:{convId}" (list), TTL 6h
     - MessageWindowChatMemory: ventana 50 mensajes
     - Cada ChatClient bean configurado con MessageChatMemoryAdvisor
     - conversationId: UUID manual o derivado de mensajes OpenWebUI

   Slide 10 — Capacidades y limitaciones (tabla comparativa)
     - Columna izquierda: 62 capacidades agrupadas (mostrar top 15 más impactantes)
     - Columna derecha: 24 limitaciones (top 10 más relevantes)

   Slide 11 — Roadmap / próximos pasos
     - Implementar ConfluencePublisher
     - Agregar autenticación (OAuth2/JWT)
     - Soporte multi-tenant
     - Conexión directa a Sybase/MSSQL/Oracle (JDBC drivers)
     - Streaming real en endpoint simple
     - Auditoría de tool usage
     - UI web propia

   Slide 12 — Demo / Q&A
     - Código de ejemplo: usar el agente para analizar un SP Sybase
     - Resultado: dialecto detectado, tablas encontradas, validación ARQT-EST-001,
       documentación generada en Docusaurus
     - Diagrama Mermaid generado automáticamente

2. FORMATO:

   - Usa Mermaid para TODOS los diagramas (flowchart, graph, sequence, erDiagram)
   - Cada diagrama debe ser autocontenido y renderizable
   - Colores: paleta profesional oscura (#1a1a2e fondo, #16213e secundario,
     #0f3460 terciario, #e94560 acento)
   - Tipografía: monoespaciada para código, sans-serif para texto
   - Incluye snippets de código real en las slides de herramientas y APIs

3. EJEMPLOS CONCRETOS A INCLUIR:

   Ejemplo 1 — Sistema detectando dialecto:
   Entrada: SP Sybase con "@@ERROR", "LOCK ALLPAGES", "RAISERROR 50001"
   Salida: "Sybase ASE (certeza: alta)" + validación ARQT-EST-001

   Ejemplo 2 — Flujo de chat con router:
   Usuario: "hola" → INTENT_SIMPLE → score 0.0 → CHEAP (flash, 0.2s)
   Usuario: "analiza las dependencias y genera diagrama de migración" →
     keywords=3 (+0.80) + len>200 (+0.15) → score 0.95 → EXPENSIVE (pro, 3.5s)

   Ejemplo 3 — Documentación generada:
   Tabla "cob_pagos.cc_tran_servicio" → TableDocGenerator →
     columnas (12), índices (3), constraints (2), DDL completo, diagrama ER Mermaid

4. TONO:

   - Profesional pero accesible
   - Enfatiza el valor de negocio: reducir tiempo de análisis de SPs legacy,
     estandarizar migraciones, documentar automáticamente
   - Cada slide debe responder "¿qué problema resuelve esto?"

5. OUTPUT:

   Entrega la presentación en formato reveal.js (HTML autocontenido)
   o en su defecto, Markdown estructurado con separadores de slide (---)
   y bloques Mermaid para cada diagrama.
```
