# STATE.md — Memoria Persistente de la Migración COBOL -> Angular

## Estado General
- **Proyecto**: Migración de Pantallas COBOL (Micro Focus) a Angular Frontend
- **Ubicación Origen**: `samples/cobol/projects/isc-cobol-test` (32,297 LOC, 96 programas, 26 copybooks) + `samples/cobol/synthetic` (2 programas)
- **Destino**: Angular Frontend (Standalone Components, Signals, ReactiveForms, TypeScript 5+, HTML/SCSS con emulación 80x24 y layout moderno)
- **Fase Actual**: FASE 0 — Preparación
- **Fecha de Inicio**: 2026-08-19

---

## Métricas del Codebase Origen (0.1)
- **Total Archivos COBOL**: 124 (.cbl, .cpy)
- **Total Líneas de Código**: 32,297
- **Desglose por Subsistema**:
  - `admin`: 8 archivos, 1,291 líneas
  - `audit`: 1 archivo, 112 líneas
  - `batch`: 7 archivos, 2,734 líneas
  - `cards`: 8 archivos, 1,729 líneas
  - `common`: 10 archivos, 1,945 líneas
  - `copybooks`: 26 archivos, 1,517 líneas
  - `custmod`: 8 archivos, 3,091 líneas
  - `deposits`: 7 archivos, 2,692 líneas
  - `loans`: 8 archivos, 2,712 líneas
  - `reports`: 7 archivos, 1,792 líneas
  - `security`: 5 archivos, 2,284 líneas
  - `teller`: 9 archivos, 3,808 líneas
  - `timedep`: 5 archivos, 1,756 líneas
  - `transfer`: 5 archivos, 1,851 líneas
  - `synthetic`: 2 archivos, 109 líneas

---

## Registro de Actividades y Subagentes

### FASE 0 — Preparación
- [x] **0.1 Inventario del Codebase**: Extraído grafo de dependencias, llamadas (CALL), copybooks compartidos y accesos a archivos (.DAT).
- [x] **0.1b Audit y hardening del preview Angular (2026-08-21/22)**: revisión de `src/app/*` (infra escrita a mano) y `packages/core`. Corregido: `screen-viewer.component.ts` ya no deja pantalla en blanco ante un navTarget sin registrar (muestra "no disponible en este preview" — cubre el bug de `COMSCRN`/`COMDATE`/`COMVALF`/`BCHMNU00`/`AUDTRL00` documentado abajo); `provideZonelessChangeDetection()` explícito en `app.config.ts` (la app ya corría así de facto, sin declararlo); `resetTestingModule()` en `test-setup.ts` (Vitest no resetea el TestBed entre tests como sí lo hace Jasmine/Karma). 2 tests de regresión nuevos en `navigation-flow.spec.ts`. Build (`ng build`) y suite (`vitest`, 6/6) verificados en verde. Los gaps que dependen del generador externo ("el ensamblador") quedaron documentados en Escalaciones y Bloqueos, no se tocó `src/screens/**` (auto-generado).
- [ ] **0.2 Especificaciones de Portabilidad**: Subagente `analyst` despachado (Conv ID: `6827abaa-6dd9-4c50-a0de-207ef113335e`) para generar `PORTING.md`, `LIFETIMES.tsv`, `BOUNDARIES.md`, `IMPROVEMENTS.md`.
- [ ] **0.3 Partición y Módulos Angular**: Definición de la arquitectura destino y eliminación de ciclos de dependencias.
- [ ] **0.4 Port Piloto (4 pantallas representativas)**:
  - Piloto 1: `BNK0001` (Security / Login)
  - Piloto 2: `BNK0010` / `COMMENU` (Menú Principal / Navegación PF-keys)
  - Piloto 3: `CUSMNT00` (Mantenimiento de Clientes / Validaciones complejas)
  - Piloto 4: `TLRDEP00` (Depósito en Efectivo / Transacciones y Boundary Backend)
- [ ] **CHECKPOINT HUMANO**: Presentación de artefactos de Fase 0 y pilotos para aprobación explícita antes de Fase 1.

---

## Escalaciones y Bloqueos
- **Audit `apps/preview-angular-spa` (2026-08-21)** — hallazgos que requieren al generador ("el ensamblador", pipeline ADG → `ui-spec.ts` → angular-gen, no presente en este repo) y por lo tanto no se pudieron corregir desde acá sin violar el contrato "Auto-generado — no editar":
  - **Gap de generación real**: `BCHMNU00` y `AUDTRL00` deberían existir como pantallas (`BOUNDARIES.md` los lista en `BatchService`/`AuditService`) pero no están en `meta.json`/`registry.ts` — faltan por generar. `BCHMNU00.cbl` sí tiene `SCREEN SECTION` (es un menú interactivo real).
  - **Correctamente excluidos pero rotos en navegación**: `COMSCRN`, `COMDATE`, `COMVALF` son subrutinas COBOL no interactivas (sin `SCREEN SECTION`) que correctamente NO deben ser pantallas — pero `navigation.ts` (auto-generado) igual los referencia como `routerLink` clickeables, generando dead-links. El generador debería dejar de emitir nav targets para `CALL`s a subrutinas no interactivas. Mitigado en el código escrito a mano (`screen-viewer.component.ts` ahora muestra "no disponible" en vez de pantalla en blanco), pero el link roto en el menú lateral sigue ahí hasta que se corrija la generación de `navigation.ts`.
  - **Bug sistémico en las 82 pantallas generadas**: cada `.vm.ts` setea `vm.message()` en éxito/error de `submit()`, pero ningún `.component.html` lo renderiza — el usuario nunca ve feedback del formulario. Import de `MessageModule` presente pero sin uso real en el template. Requiere corregir la plantilla del ensamblador (no archivo por archivo).
  - **Otros del generador** (menor prioridad, documentar como deuda conocida): KPIs de pantallas `menu` muestran `"0"` hardcodeado sin bind a ningún signal; 0/82 pantallas usan Reactive Forms pese a recomendarlo `IMPROVEMENTS.md` §2.1 (solo `ngModel` + validación "requerido", sin `pattern`/regex real aunque el comentario generado dice "PIC-derived"); sin atributos `aria-live`/`role="alert"` en mensajes de error (gap WCAG 2.1 AA vs `IMPROVEMENTS.md` §5); el campo `rendering: "ssr"/"spa"` de `ui-spec.ts`/`meta.json` no tiene ninguna infraestructura SSR real detrás (sin `@angular/ssr`, sin `server.ts`) — es vestigial hoy.

---

## Decisiones Tomadas
1. **Branch de Trabajo**: `feature/cobol-to-angular-migration`.
2. **Arquitectura Destino**: Angular 19+ con Standalone Components, Signals para estado de pantalla reactivo, ReactiveForms para captura y validación estricta de formularios, servicios HTTP con tipado TypeScript exhaustivo.
3. **Manejo de PF-Keys**: Interceptor de teclado global / HostListener en componente base para mapear PF1 a PF12 + Enter + Clear, con barra de botones de acción visible y clicable en pantalla.
