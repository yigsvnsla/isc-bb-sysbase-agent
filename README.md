# sysbase-agent

Agente IA para desarrolladores de BD: Sybase ASE, SQL Server, Oracle, PostgreSQL.

**Stack**: Spring Boot 4.1.1 + Java 26 + Spring AI 2.0.0 | DeepSeek v4 | PGVector HNSW 384d | Redis 7 | ONNX Transformers `all-MiniLM-L6-v2`

→ Ver [AGENTS.md](./AGENTS.md) para quick start, configuración, testing.

---

## Paquetes

```
sysbase_agent/
├── config/          AgentConfig(3 ChatClient beans), WebConfig(CORS), StreamFixConfig(SSE id fix)
├── service/         AgentService: Router→ChatClient→MarkdownFixer→metrics
├── controller/      AgentController(POST /v1/agent/chat), OpenAiCompatController(/models, /chat/completions SSE)
├── handler/         AgentHandler, AgentRoutes(POST /v2/agent/chat)
├── tools/           PostgresTools(19 @Tool), KnowledgeBaseTool(2), SpDocLoader(1)
├── router/          ModelRouter(heuristic+classifier+LlmClassifier), RouterDecision, Tier(CHEAP/EXPENSIVE)
├── loader/          KnowledgeBaseLoader(PDFs+SQLs+TXT+MDs→splitter→VectorStore), SpDocLoader
├── reader/          PdfDocumentReader(PDFBox), SqlFileReader, MarkdownReader
├── cli/             AgentCli(ask/chat), KnowledgeBaseCli(kb-index/kb-status)
├── documentation/   model/, port/DocumentPublisher, adapter/DocusaurusPublisher|ConfluencePublisher(stub),
│                    generator/×9(Table|Procedure|View|Trigger|Sequence|Enum|CompositeType|Migration|Standards),
│                    indexer/SchemaIndexer+AutoIndexRunner(@Scheduled 5min)
├── dto/             OpenAiModelList, OpenAiModel, OpenAiChunk, OpenAiChatRequest
├── memory/          RedisChatMemoryRepository(chat:memory:{convId}, TTL 6h, window 50)
└── util/            MarkdownFixer(headers, mermaid typos, newlines)
```

## Interfaces

| Interfaz | Ruta/Comando |
|---|---|
| REST v1 | `POST /api/v1/agent/chat` |
| REST v2 | `POST /api/v2/agent/chat` |
| OpenAI compat | `GET /api/models`, `POST /api/chat/completions` (SSE) |
| CLI | `ask`, `chat`, `kb-index`, `kb-status`, `doc-generate`, `doc-publish`, `doc-index`, `doc-status` |

## ChatClient beans

| Bean | Modelo | Tools | Memory |
|---|---|---|---|
| `chatClientCheap` | deepseek-v4-flash | PG+KBTool+SpDoc | 50 msgs |
| `chatClientExpensive` | deepseek-v4-pro | PG+KBTool+SpDoc | 50 msgs |
| `chatClientClassifier` | deepseek-v4-flash | — | — |

## Model Router

```
prompt → [cache? router:dec:{sha256} TTL 1h] → heurística:
  INTENT_SIMPLE regex match → CHEAP, score=0
  KEYWORDS_EXPENSIVE hits → +0.4/hit (cap 0.8)
  len>1500→+0.30 | len≥200→+0.15 | history≥10→+0.15
  score≥0.6→EXPENSIVE else CHEAP
  gray[0.35-0.55]? → LlmClassifier(maxTokens=8,timeout1.5s)→"CHEAP"/"EXPENSIVE"
metrics: ai_router_decisions_total{tier}, ai_chat_duration_seconds{tier}
```

## Ingesta (startup automática)

PDFs→PdfDocumentReader | SQLs→SqlFileReader | TXTs→SqlFileReader | MDs→MarkdownReader | doc MDs→MarkdownReader
→ `TokenTextSplitter(chunk=1200, min=350, max=10000)` → PGVector(HNSW,384d)
Búsqueda: `similaritySearch(topK=12,threshold=0.25)` → <5 hits → fallback ILIKE keyword

## 22 Tools (@Tool)

**PostgresTools (19)**: `search_procedures` `get_procedure_source` `list_procedures` `list_schemas` `list_all_schemas` `list_tables` `get_table_info` `list_views` `get_view_definition` `get_view_columns` `list_triggers` `get_trigger_definition` `list_sequences` `list_enums` `get_enum_values` `list_composite_types` `get_composite_type_attrs` `get_dependencies`

**KnowledgeBaseTool (2)**: `search_knowledge_base` `analyze_sql`
**SpDocLoader (1)**: `index_procedure`

---

## Capacidades (resumen)

| Categoría | Qué hace |
|---|---|
| **Conocimiento** | Semantic search en PDFs/SQLs/MDs indexados; prioriza RAG sobre conocimiento general; reindexación total |
| **Exploración BD** | Buscar/listar SPs, ver source code, listar schemas/tablas/vistas/triggers/secuencias/enums/tipos; inspeccionar tabla completa (DDL+cols+índices+constraints); dependencias de SP |
| **Análisis SQL** | Detectar dialecto (Sybase/MSSQL/Oracle/PG) con scoring; parsear estructura (SP/trigger/view/DDL/DML); extraer tablas+parámetros+operaciones; validar naming conventions por motor; validar ARQT-EST-001 (pa_, @e_, @s_, @v_, cabeceras, REFs); buscar docs relacionadas |
| **Documentación** | Generar docs de SPs/tablas/vistas/triggers/secuencias/enums/tipos compuestos/migraciones/estándares; publicar a Docusaurus (.md+YAML+sidebars.js); auto-index @Scheduled 5min con detección cambios SHA-256 |
| **Visualización** | Generar diagramas Mermaid (flowchart, ER, secuencia); MarkdownFixer corrige formato automático |
| **Router** | Clasificar prompts CHEAP(flash)/EXPENSIVE(pro); heurística+micro-LLM en zona gris; cache decisiones Redis TTL 1h; métricas Micrometer |
| **Memoria** | Historial por conversationId en Redis (window 50, TTL 6h) |
| **APIs** | REST v1+v2, OpenAI-compat SSE, OpenWebUI compat (`### Task:`), Spring Shell CLI, CORS |
| **Infra** | Cache Redis (sp_source, sp_search, TTL 10min); PGVector HNSW auto-schema; ONNX embeddings on-device; Actuator health/metrics; DevTools hot reload; 3 profiles (default/web/prod) |

## Limitaciones

| Categoría | Limitación |
|---|---|
| **Conectividad** | Solo PostgreSQL local (pg_catalog). Sin drivers Sybase/MSSQL/Oracle reales |
| **Operaciones** | Solo lectura. No ejecuta DDL/DML, no migra datos reales |
| **Seguridad** | Sin auth, single-tenant |
| **Formatos** | Solo texto. Sin imágenes/audio. Sin file upload en chat |
| **Streaming** | Solo OpenAI compat endpoint. V1/V2 son JSON in/out sincrono |
| **Entrenamiento** | Sin fine-tuning. Modelo+embeddings fijos en runtime |
| **Escalabilidad** | Sin balanceo LLM, sin A/B testing, sin auditoría tool usage |
| **Docs** | ConfluencePublisher en stub. Puertos fijos (DB 5432, Redis 6379) |
| **Límites** | maxChunks=10000. Ingesta solo al arranque. Sin queries SQL complejas sobre vector_store. Embedding fijo 384d |

---

## Prompt para presentación

Copia este bloque en un LLM para generar presentación técnica (12 slides, reveal.js/markdown, diagramas Mermaid):

````
Eres arquitecto senior. Genera presentación sobre "sysbase-agent", agente IA Spring Boot 4.1.1+Java 26+Spring AI 2.0.0 experto en Sybase ASE, SQL Server, Oracle, PostgreSQL. Stack: DeepSeek v4, PGVector HNSW 384d, ONNX embeddings on-device, Redis 7, Docusaurus, Podman.

12 SLIDES:
1. Título: "sysbase-agent: Agente IA Experto en BD" + tagline "Análisis, documentación y migración inteligente de SPs"
2. Arquitectura (diagrama Mermaid flowchart): Usuario→[CLI|REST|OpenWebUI]→AgentService→ModelRouter→[chatClientCheap|chatClientExpensive]→DeepSeek API. Tools: PostgresTools(19), KBTool(2). Redis memoria+cache. PGVector ingesta+search. SchemaIndexer→Docusaurus.
3. Model Router (diagrama flujo): prompt→cache→heurística(intent+keywords+length+history)→gray→LlmClassifier→CHEAP/EXPENSIVE. Threshold 0.6, cache SHA-256 TTL 1h.
4. Herramientas (tabla): 22 tools en 3 grupos — exploración BD(19), knowledge base(2), indexación(1).
5. Pipeline ingesta (diagrama): PDFs/SQLs/TXTs/MDs→readers→TokenTextSplitter(1200/350)→PGVector. Búsqueda: similaritySearch→fallback ILIKE.
6. Análisis SQL (diagrama): código→detectar dialecto(scoring)→parsear estructura→extraer tablas+params→validar naming conventions→ARQT-EST-001→docs relacionadas.
7. Documentación automática (diagrama): SchemaIndexer→generators(Table|Procedure|View|Trigger|...)×9→DocusaurusPublisher(.md+YAML+sidebars). AutoIndexRunner @Scheduled 5min.
8. Interfaces: REST v1/v2, OpenAI compat SSE, OpenWebUI, CLI(ask/chat/kb-*/doc-*), CORS.
9. Memoria: RedisChatMemoryRepository(chat:memory:{convId}, TTL 6h, window 50), MessageChatMemoryAdvisor.
10. Capas vs límites (2 columnas): top 10 capacidades vs top 8 limitaciones.
11. Roadmap: Confluence, auth OAuth2/JWT, multi-tenant, drivers Sybase/MSSQL/Oracle, streaming real, auditoría, UI web.
12. Demo: analizar SP Sybase con @@ERROR, LOCK ALLPAGES, RAISERROR → dialecto Sybase ASE (alta), validación ARQT-EST-001, doc generada en Docusaurus, diagrama Mermaid.

FORMATO: Mermaid para todos los diagramas. Paleta oscura #1a1a2e/#16213e/#0f3460/#e94560. Snippets de código real. Ejemplos concretos:
- "hola"→score 0.0→CHEAP(flash,0.2s)
- "analiza dependencias y genera diagrama de migración"→keywords=3(+0.80)+len>200(+0.15)→score 0.95→EXPENSIVE(pro,3.5s)
- Tabla cob_pagos.cc_tran_servicio→12 cols, 3 índices, 2 constraints, DDL+ER Mermaid

TONO: profesional accesible. Cada slide responde "¿qué problema resuelve?". OUTPUT: reveal.js autocontenido o markdown con separadores --- y bloques Mermaid.
````
