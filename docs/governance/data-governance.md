# Gobernanza de Datos — sysbase-agent

## Clasificación
| Dato | Clasificación | Tratamiento |
|---|---|---|
| Fuente de stored procedures / esquemas | Sensible (interno) | Solo lectura, RBAC por rol, auditoría de args completos |
| Prompts de usuario | Sensible (PII posible) | En auditoría: hash SHA-256 + truncado 500 chars; nunca completo |
| Respuestas del LLM | Interno | En auditoría: solo hash |
| Args de tools | Sensible | Completos en ai_audit (forense) — retención limitada |
| API keys | Secreto | Hash SHA-256 en BD; key plana se muestra una sola vez |

## Retención
| Almacén | TTL / política |
|---|---|
| Memoria Redis (chat:memory:) | 6 horas, window 50 mensajes |
| Cache router (router:dec:) | 1 hora |
| Cache sp_source/sp_search | 10 minutos |
| ai_audit | Hot 90 días; export anual inmutable (TODO) |
| api_keys | Hasta revocación o expiración |

## Derechos
- Borrado de conversación: `deleteByConversationId` (exponer como endpoint = TODO).
- Exportación de auditoría por usuario para solicitudes internas (TODO).

## PII
- No se solicitan datos personales en prompts; si aparecen, se minimiza su retención (truncado + hash).
- No loguear headers de autorización ni claves.

TODO(futuro): escaneo PII en ingesta del vector store; anonimización de exports; política formal de privacidad.
