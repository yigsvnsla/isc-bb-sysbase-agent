# Changelog — sysbase-agent

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/). Este changelog cubre el backend (`sysbase-agent`, el agente de IA que documenta bases de datos). La migración COBOL→Angular vive en la rama `feature/cobol-to-angular-migration` y tiene su propio historial (`STATE.md`).

## [Unreleased] — 2026-08-21/22

Audit completo de seguridad, tests, CI y roadmap/TODOs, con foco en cerrar hallazgos de bajo riesgo y alto valor para una prueba de concepto.

### Added
- `WormHmacSecretValidator` + HMAC-SHA256 en la cadena hash de `AuditWormExportService` (antes SHA-256 plano, recalculable por cualquiera con acceso de escritura al filesystem).
- `JwtRevocationService`: denylist de JWT en Redis por claim `jti` (nuevo en cada token emitido). CLI `token-revoke --token <jwt>` para revocar antes de la expiración natural.
- `app.security.trusted-proxies`: `RateLimitFilter` ya no confía ciegamente en `X-Forwarded-For` — solo si la request viene de una IP/CIDR confiable. Antes, cualquier cliente directo podía spoofear el header y saltarse el rate limit por IP.
- Auditoría explícita de intentos de autenticación con API key inválida/expirada en `ApiKeyAuthFilter` (`method="api-key"`), antes indistinguibles de un fallo genérico.
- `@PreAuthorize("hasRole('ADMIN')")` a nivel de clase en `ApprovalController` (defensa en profundidad además de la regla de path en `SecurityConfig`) + `@EnableMethodSecurity`.
- Restricción explícita de algoritmo JWS a HS256 en `JwtDecoders` (defensa en profundidad).
- `WARN` en `JwtSecretValidator` cuando se usa el secreto default de desarrollo sin ningún perfil Spring activo (posible despliegue mal configurado sin `SPRING_PROFILES_ACTIVE=prod`).
- Job `nightly-extended` en CI (cron diario + `workflow_dispatch`): corre `MultiDbDialectE2ETest` (MSSQL/Oracle/Sybase) y `LoadE2ETest`, que ya no bloquean cada PR.
- Tests: `ApprovalServiceTest`, `ApprovalRepositoryTest`, `TableDocGeneratorTest`, `JwtRevocationTest`, `RateLimitFilterTest`, `ApiKeyAuthFilterTest` — 22 tests nuevos cubriendo rutas previamente sin cobertura (tool de escritura no registrada, tool que lanza excepción, orden de `listPending`, generador de docs más grande del proyecto, revocación JWT, trusted-proxies, auditoría de API key fallida).

### Changed
- `LoadE2ETest` (`@Tag("load")`) excluido de `mvn test`/`verify` por defecto vía `<excludedGroups>load</excludedGroups>` en `pom.xml`.

### Removed
- Dependencia de Lombok (declarada en `pom.xml`, 0% adoptada en el código — todos los constructores eran manuales).
- 2 comentarios `TODO(futuro)` obsoletos en `ToolAccessGuard`/`AuditedToolCallback` ("filtrar tools del schema LLM por rol") — ya implementado en `AgentService.toolsForRole()`.

### Fixed
- `AGENTS.md`: 2 afirmaciones desactualizadas corregidas (conteo de reglas de alertas 8→9; `containerfile` ya no figuraba como "vacío" pese a tener el hardening de F13 implementado).

### Docs
- `docs/governance/risk-register.md`: R04 y R08 actualizados para reflejar las mitigaciones de trusted-proxies y HMAC-SHA256.
- `AGENTS.md`: arquitectura de revocación JWT, trusted-proxies y filtrado de tools por rol documentada.

### Notas de riesgo aceptado (no se tocan)
- `spring-boot-starter-parent` en `4.1.1-SNAPSHOT` (pre-release): riesgo de cadena de suministro aceptado deliberadamente para esta PoC (requiere Java 26 preview + APIs nuevas de Spring Boot 4); downgradear rompería la elección tecnológica del proyecto sin necesidad real hoy.
- `AuthAuditFilter`: TODO sobre saltar auditoría en 429/actuator no se toca — el propio comentario advierte que un intento anterior rompió la autenticación.
- `EvalHarnessTest` (LLM-judge): se omite en CI sin `IA_API_KEY` — requiere provisionar un secret real, decisión de infraestructura fuera de alcance de un fix de código.
