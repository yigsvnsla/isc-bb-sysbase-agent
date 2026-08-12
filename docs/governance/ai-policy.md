# Política de IA — sysbase-agent

## 1. Propósito y alcance
sysbase-agent es un asistente interno de IA para desarrolladores de bases de datos (Sybase ASE, SQL Server, Oracle, PostgreSQL). Alcanza a: análisis de stored procedures, exploración de esquemas, documentación técnica, migraciones y consulta de la base de conocimientos.

## 2. Roles y responsabilidades
| Rol | Responsabilidad |
|---|---|
| AI Owner | Responsable final del sistema, aprobación de cambios de modelo/prompt |
| AI Steward | Operación diaria, monitoreo, evaluación continua, gestión de incidentes |
| Usuario | Uso conforme a esta política; reportar salidas incorrectas o sospechosas |

## 3. Principios
- **Transparencia**: las respuestas del agente son generadas por IA; el sistema lo indica (Art. 50 EU AI Act).
- **Supervisión humana**: el agente es solo-lectura sobre BD; las operaciones de escritura requieren flujo de aprobación (HITL) — hoy ninguna tool de escritura está registrada.
- **Rendición de cuentas**: cada turno, tool call y evento de autenticación se audita en `ai_audit` (ver data-governance.md).
- **No discriminación / sesgo**: la evaluación continua (eval harness) monitorea calidad por categoría de consulta.

## 4. Usos prohibidos
- Decisiones con efecto legal, crediticio, médico o de RRHH basadas únicamente en salida del agente.
- Ejecución autónoma de DDL/DML sobre bases de producción (el agente no tiene tools de escritura; mantener).
- Uso de datos personales en prompts fuera de lo necesario para la tarea.

## 5. Cambios
- Prompt y modelos se versionan (model-registry.md); todo cambio requiere revisión y registro.
- Los cambios de configuración de seguridad siguen el flujo normal de revisión de código.

## 6. Referencias normativas
- NIST AI RMF 1.0 + NIST AI 600-1 (perfil GenAI)
- ISO/IEC 42001:2023 (sistema de gestión de IA), ISO/IEC 23894 (riesgo)
- EU AI Act 2024/1689 (ver eu-ai-act-mapping.md)

## 7. Revisión
Esta política se revisa semestralmente o ante cambios mayores del sistema.
