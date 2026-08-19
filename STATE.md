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
- Ninguno en este momento.

---

## Decisiones Tomadas
1. **Branch de Trabajo**: `feature/cobol-to-angular-migration`.
2. **Arquitectura Destino**: Angular 19+ con Standalone Components, Signals para estado de pantalla reactivo, ReactiveForms para captura y validación estricta de formularios, servicios HTTP con tipado TypeScript exhaustivo.
3. **Manejo de PF-Keys**: Interceptor de teclado global / HostListener en componente base para mapear PF1 a PF12 + Enter + Clear, con barra de botones de acción visible y clicable en pantalla.
