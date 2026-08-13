# Registro de Riesgos — sysbase-agent

Formato: ID | Riesgo | Likelihood | Impacto | Mitigación | Estado

| ID | Riesgo | L | I | Mitigación | Estado |
|---|---|---|---|---|---|
| R01 | Prompt injection (directa/indirecta) | M | A | Tags <retrieved_data> + directiva en system prompt; batería red-team | Mitigado (Fase 3), validación continua |
| R02 | Exfiltración de datos vía tools | M | A | RBAC por rol (READONLY/DOC/ADMIN), deny-by-default, auditoría de args completos | Mitigado (Fases 1-2) |
| R03 | Agencia excesiva (escrituras no autorizadas) | B | A | Única tool de escritura (`index_procedure`) protegida por RBAC: solo DOC/ADMIN vía ToolAccessGuard; READONLY denegado; args auditados; HITL implementado (F14): escrituras HTTP → cola `approval_requests` PENDING, REST `/v1/admin/approvals` + CLI `approvals-*`, ejecución post-aprobación auditada | Mitigado (Fases 8+14) |
| R04 | Consumo ilimitado (costo/DoS) | M | M | Rate limit Redis (60/min user, 20/min IP) + presupuestos diarios | Mitigado (Fase 3) |
| R05 | Proveedor externo (DeepSeek): disponibilidad, privacidad de prompts | M | A | Base-url configurable; política de datos; opción local (vLLM) en TODO | Aceptado + monitoreo |
| R06 | Alucinación / misinformation (LLM09) | A | M | Eval harness con rúbrica; RAG prioriza docs; verificación humana en outputs críticos | Parcial |
| R07 | Envenenamiento del vector store (LLM04/08) | B | M | Ingesta controlada por ruta; revisión de fuentes; metadata source | Vigilancia |
| R08 | Pérdida de auditoría | B | A | ai_audit en PG; métrica ai_audit_write_failures_total; alerta; WORM (F12a): export JSONL append-only con hash chain SHA-256 + purge solo de exportados | Mitigado (Fases 2+12) |
| R09 | System prompt leakage (LLM07) | B | M | Prompt confidencial; red-team; sin echo | Vigilancia |
| R10 | Fallo de infraestructura (PG/Redis) | M | M | Compose con healthchecks; contenedores reinician; réplica streaming PG (F12b, perfil replica, puerto 5433) | Aceptado |

TODO(futuro): revisiones trimestrales; dueños asignados por riesgo; mitigación R06 con eval en CI.
