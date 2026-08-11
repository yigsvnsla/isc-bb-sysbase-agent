# Plan de Respuesta a Incidentes de IA — sysbase-agent

## Clasificación
| Severidad | Ejemplo | Tiempo de respuesta |
|---|---|---|
| P1 | Exfiltración de datos vía tools; bypass de inyección con impacto; pérdida de auditoría | 30 min |
| P2 | Alucinación dañina repetida; degradación de servicio; costo anómalo | 4 h |
| P3 | Falso positivo de guardrail; incidencias menores | 24 h |

## Procedimiento P1
1. **Contención**: revocar API key(s) implicadas (`apikey-revoke`), desactivar tokens (`JWT_SECRET` rotación), purgar memoria Redis de la conversación (`deleteByConversationId`).
2. **Evidencia**: extraer eventos de `ai_audit` (turno + tool + auth) con trace_id; conservar logs.
3. **Análisis**: revisar si el guardrail falló (inyección, RBAC, rate limit) y si la salida causó daño.
4. **Remediación**: fix de código con test de regresión (batería red-team), deploy en rama, evaluación.
5. **Postmortem**: 5 whys, actualizar risk-register.md y redteam-playbook.md.

## Comunicación
- Notificar a AI Owner y AI Steward según severidad.
- Si hubo datos sensibles involucrados, seguir política de privacidad de la organización.

## Ejercicios
- Red-team trimestral contra entorno de pruebas con el playbook (docs/security/redteam-playbook.md).
