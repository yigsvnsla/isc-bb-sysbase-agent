# Modelo de Amenazas — sysbase-agent

Referencias: OWASP Top 10 LLM 2025, OWASP Agentic Security Initiative, MITRE ATLAS, NIST AI RMF.

## Mapeo OWASP LLM Top 10 2025 → controles
| Riesgo | Control implementado | Evidencia |
|---|---|---|
| LLM01 Prompt Injection | Tags <retrieved_data> + directiva en system.md; red-team | AuditedToolCallback, redteam-playbook.md |
| LLM02 Sensitive Info Disclosure | RBAC roles; redacción en auditoría; hash+truncado | ToolAccessGuard, AuditRepository |
| LLM03 Supply Chain | Versiones pinneadas; SBOM en CI; AIBOM | aibom.md, pom.xml |
| LLM04 Data Poisoning | Ingesta controlada por ruta; metadata source | KnowledgeBaseLoader |
| LLM05 Improper Output Handling | MarkdownFixer; salida nunca ejecutada; sin HTML render | MarkdownFixer |
| LLM06 Excessive Agency | Solo tools de lectura; deny-by-default; HITL TODO | ToolAccessGuard, AgentConfig |
| LLM07 System Prompt Leakage | Prompt en classpath versionado; red-team | system.md |
| LLM08 Vector Weaknesses | Threshold 0.25; RBAC DB; revisión de fuentes | KnowledgeBaseTool |
| LLM09 Misinformation | RAG prioriza docs; eval harness; verificación humana | EvalHarnessTest |
| LLM10 Unbounded Consumption | Rate limit Redis + presupuestos diarios | RateLimitFilter, TokenBudgetService |

## Amenazas agentic (OWASP Agentic Security)
| Amenaza | Postura |
|---|---|
| Unbounded Agency | Sin tools de escritura registradas; límite de iteraciones pendiente (TODO) |
| Unbounded Consumption | Rate limit + budget (mitigado) |
| Deficient Identity | JWT HMAC + API keys con rol (mitigado) |
| Social Engineering | Red-team de jailbreaks; detección post-hoc TODO |
| Data/Control Flow Confusion | <retrieved_data> (mitigado) |
| Slippery Sandboxing | containerfile pendiente (TODO): distroless, non-root, read-only |

## Superficie de ataque
- REST v1/v2, OpenAI-compat SSE, OpenWebUI (### Task:), CLI local.
- Auth obligatoria en HTTP; CLI = confianza local.
- Dependencias externas: DeepSeek API, PG, Redis, ONNX runtime.
