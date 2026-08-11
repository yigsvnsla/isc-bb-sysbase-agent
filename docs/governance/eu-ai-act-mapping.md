# Mapeo EU AI Act 2024/1689 — sysbase-agent

Clasificación asumida: **riesgo mínimo / sistema de propósito general con límites** (herramienta interna de asistencia técnica, solo lectura de BD). Si se añaden capacidades de escritura o decisión automatizada, reclasificar (obligaciones de los arts. 12 y 14 pasan de buenas prácticas a deberes).

| Artículo | Obligación | Estado en sysbase-agent |
|---|---|---|
| Art. 5 | Prácticas prohibidas | No aplica (documentado): no manipulación, no scoring social, no vigilancia masiva |
| Art. 12 | Registro automático (logging) de sistemas de alto riesgo | Implementado como buena práctica: ai_audit (TURN/TOOL/AUTH), trace_id por turno, métricas |
| Art. 13 | Transparencia e información | Parcial: respuesta indica ser de IA; documentar capacidades/limitaciones |
| Art. 14 | Supervisión humana | Tools solo lectura; HITL pendiente para futuras escrituras (TODO) |
| Art. 50 | Transparencia con usuarios | En curso: etiquetado de respuestas como generadas por IA |

## Decisiones registradas
- El agente NO toma decisiones autónomas sobre datos; es asistencia técnica.
- Datos enviados al proveedor (DeepSeek): prompts + fuentes consultadas — riesgo vendor documentado en risk-register.md (R05).

TODO(futuro): revisión legal de la clasificación; contrato DPA con proveedor; registro de sistema si aplica.
