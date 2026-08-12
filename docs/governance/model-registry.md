# Registro de Modelos — sysbase-agent

## Modelos en uso
| Bean | Modelo | Uso | Temperatura | maxTokens |
|---|---|---|---|---|
| chatClientCheap | deepseek-v4-flash | Chat general, tier CHEAP | configurable (env IA_API_TEMPERATURE) | configurable (env IA_API_MAX_TOKEN) |
| chatClientExpensive | deepseek-v4-pro | Chat complejo, tier EXPENSIVE | idem | idem |
| chatClientClassifier | deepseek-v4-flash | Clasificador router (zona gris) | 0.0 | 8 |
| Embeddings | all-MiniLM-L6-v2 (ONNX) | RAG, 384d | — | — |

## Prompts
| Artefacto | Ubicación | Estado |
|---|---|---|
| System prompt agente | src/main/resources/prompts/system.md | Versionado en git (prompt = código) |
| Prompt clasificador | AgentConfig.java (chatClientClassifier) | Versionado en git |
| Directiva <retrieved_data> | system.md (sección hardening) | Versionado en git |

## Historial de cambios
| Fecha | Cambio | Hash/ref | Aprobado por |
|---|---|---|---|
| 2026-08 | Extracción del system prompt a system.md | commit 4fbf3f4 | AI Steward |

TODO(futuro): registrar hash SHA-256 del prompt activo en cada release; eval delta antes/después de cada cambio de modelo o prompt.
Rotación de JWT: soporte de 2 secretos (`JWT_SECRET` actual + `JWT_PREVIOUS_SECRET` en transición) — ver runbook.md.

## Proveedor
- DeepSeek API (vía spring-ai-starter-model-openai con base-url configurable). Riesgo de proveedor externo documentado en risk-register.md.
