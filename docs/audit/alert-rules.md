# Reglas de Alerta — sysbase-agent

Métricas expuestas por Micrometer (actuator/prometheus). Referencia para Prometheus + Alertmanager.

## Alertas críticas (P1)
| Regla | Expresión PromQL | Condición |
|---|---|---|
| Pérdida de auditoría | `ai_audit_write_failures_total > 0` sostenido 5m | El INSERT de ai_audit falla — evidencia forense incompleta |
| Posible exfiltración | `sum(increase(ai_tool_calls_total{tool="get_procedure_source"}[5m])) > 100` | Ráfaga anómala de lectura de fuentes |
| Fallos auth anómalos | `sum(rate(ai_auth_events_total{result="failure"}[5m])) > 50` | Fuerza bruta / credenciales inválidas masivas |

## Alertas de operación (P2)
| Regla | Expresión PromQL | Condición |
|---|---|---|
| Latencia alta | `histogram_quantile(0.95, sum(rate(ai_chat_duration_seconds_bucket[10m])) by (le, tier)) > 15` | p95 del chat supera 15s |
| Errores tool | `sum(rate(ai_tool_calls_total{ok="false"}[10m])) > 10` | Tools fallando repetidamente |
| Cache router degradado | `sum(rate(ai_router_cache_total{result="hit"}[10m])) / sum(rate(ai_router_cache_total[10m])) < 0.5` | Cache hit rate bajo lo normal |

## Alertas de costo (P3)
| Regla | Expresión PromQL | Condición |
|---|---|---|
| Consumo alto | `sum(increase(ai_chat_duration_seconds_count[1h])) > 500` | Más de 500 llamadas/hora (proxy de costo) |
| Presupuesto | `sum(ai_router_decisions_total) por usuario > umbral` | Monitoreo de uso por usuario |

## Runbook de alerta
1. P1 auditoría: revisar `audit-tail --limit 50` y logs del repositorio; si la BD audit falla, el agente sigue operando (by design) pero alertar a AI Steward.
2. P1 exfiltración: revocar API keys sospechosas (`apikey-revoke --id N`) y seguir incident-response.md.
3. P2/P3: revisar dashboards y presupuestos (`audit-search --type TURN`).
