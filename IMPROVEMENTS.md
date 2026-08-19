# Recomendaciones de Modernización y Mejoras de Arquitectura (IMPROVEMENTS.md)

Este documento recopila las oportunidades de optimización, mejoras de experiencia de usuario (UX), fortalecimiento de seguridad y patrones de ingeniería para la migración del sistema bancario COBOL a Angular 19+.

---

## 1. Modernización de UX/UI: De Terminal 80x24 a Sistema de Diseño Híbrido

### 1.1. Modo Híbrido: "Terminal Retro" vs "Modern Banking Dashboard"
* **Problema en COBOL**: Los cajeros y operadores bancarios tienen memoria muscular altamente desarrollada para operar con teclado numérico y teclas PF (`PF1`..`PF12`), logrando velocidades de captura que a menudo se degradan si se les obliga a usar el ratón.
* **Propuesta de Mejora**:
  - Implementar un selector de vista con dos modos:
    1. **Modo Cajero Experto (High-Speed Terminal Mode)**: Emula el flujo rápido basado exclusivamente en teclado, atajos de teclas de función, auto-tabulación inmediata y navegación sin ratón.
    2. **Modo Banca Moderna (Responsive Design System)**: Orientado a ejecutivos de cuenta, supervisores y ejecutivos móviles con componentes responsivos (Material 3 / Tailwind CSS), gráficos interactivos y tablas ordenables.

### 1.2. Mejora del Flujo de Búsqueda y Subfiles
* **Problema en COBOL**: En `CUSSRH00` o `LONINQ00`, el usuario debe escribir el valor, presionar ENTER, esperar la lectura secuencial indexada (`READ NEXT`) y paginar manualmente con `PF7`/`PF8` en bloques de 20 registros.
* **Propuesta de Mejora**:
  - Búsqueda en tiempo real con autocompletado y `debounceTime(250)`.
  - Virtual Scrolling (`@angular/cdk/scrolling`) para listas de transacciones (`TRANLOG`) de miles de registros sin degradar el DOM.
  - Filtros multifacéticos (por rango de fechas, sucursal, estatus y tipo de producto).

---

## 2. Validaciones Avanzadas y Automatización de Negocio

### 2.1. Validadores Asíncronos para Unicidad
* **En COBOL**: La duplicidad de RFC (`CUS-RFC`) o Cuenta (`ACT-NBR`) se detecta únicamente al ejecutar el `WRITE` o `READ` en el archivo indexado, arrojando `FILE STATUS 22` o `23`.
* **Propuesta de Mejora**:
  - Implementar validadores asíncronos en Angular (`AsyncValidatorFn`) que consulten el backend en segundo plano mientras el usuario captura el formulario:
  ```typescript
  export function uniqueRfcValidator(customerService: CustomerService): AsyncValidatorFn {
    return (control: AbstractControl): Observable<ValidationErrors | null> => {
      if (!control.value) return of(null);
      return timer(300).pipe(
        switchMap(() => customerService.checkRfcExists(control.value)),
        map(exists => (exists ? { rfcAlreadyExists: true } : null)),
        catchError(() => of(null))
      );
    };
  }
  ```

### 2.2. Cálculo Predictivo de Scoring y CURP en Cliente
* **En COBOL**: `LONAPL00` y `CUSMNT00` requieren que el operador ingrese todos los datos y confirme para que el programa calcule el score o valide la CURP.
* **Propuesta de Mejora**:
  - Generación automática de CURP sugerida a partir del Nombre, Apellidos, Fecha de Nacimiento y Estado.
  - Visualización en tiempo real del scoring crediticio (Gauge / Termómetro de riesgo) mientras el solicitante ingresa sus ingresos y egresos.

---

## 3. Seguridad y Gestión de Identidad Moderna

### 3.1. Eliminación de Contraseñas Planas en Archivos (`USERPROF.DAT`)
* **Problema en COBOL**: `USERPROF.DAT` almacena contraseñas en texto plano (`USR-PASSWORD PIC X(20)`), con límites de reintentos básicos.
* **Propuesta de Mejora**:
  - Migrar a **OAuth 2.1 con PKCE y OpenID Connect** (Keycloak / AWS Cognito / Microsoft Entra ID).
  - Uso de tokens JWT con claims de roles (`USR-ROLE`: `ADM`, `GER`, `CAJ`, `OFI`) y caducidad automática de 15 minutos con silent refresh.
  - Almacenar tokens en memoria (evitando `localStorage` para mitigar ataques XSS).

### 3.2. Autorización Fina de Operaciones y Doble Factor (2FA)
* **En COBOL**: Operaciones de ventanilla de alto valor (`TLRDEP00` > $100,000 MXN) requieren autorización visual de supervisor.
* **Propuesta de Mejora**:
  - Flujo de autorización remota en tiempo real mediante WebSockets / Server-Sent Events (SSE). El supervisor aprueba la transacción desde su propia pantalla sin necesidad de desplazarse físicamente a la ventanilla del cajero.

---

## 4. Arquitectura de Estado Frontend y Modularización

### 4.1. Adopción de NgRx SignalStore
* **Propuesta**:
  - Implementar `SignalStore` modular para el contexto de caja del cajero (`TellerSessionStore`):
  ```typescript
  export const TellerSessionStore = signalStore(
    { providedIn: 'root' },
    withState({
      tellerId: '',
      branchId: '',
      initialCash: 0,
      currentCash: 0,
      status: 'CLOSED' as 'OPEN' | 'CLOSED',
      transactionCount: 0,
    }),
    withMethods((store, tellerService = inject(TellerService)) => ({
      async performDeposit(amount: number) {
        patchState(store, {
          currentCash: store.currentCash() + amount,
          transactionCount: store.transactionCount() + 1
        });
      }
    }))
  );
  ```

### 4.2. Partición en Micro-Frontends (Module Federation)
Para escalar el desarrollo entre diferentes equipos bancarios, se recomienda estructurar el repositorio en librerías y aplicaciones federadas:
- `@bank/auth-mfe`: Módulo de autenticación y seguridad (`BNK0001`, `SECPWD00`).
- `@bank/customers-mfe`: Administración y búsqueda de clientes (`CUS*`).
- `@bank/accounts-mfe`: Cuentas, balances y estados de cuenta (`ACT*`).
- `@bank/teller-mfe`: Operaciones de ventanilla y arqueo de caja (`TLR*`).
- `@bank/loans-mfe`: Solicitudes, scoring y amortizaciones (`LON*`).
- `@bank/shared-ui`: Componentes terminal 80x24, Action bar de PF-keys, validadores y pipes.

---

## 5. Estrategia de Testing y Calidad de Software

| Nivel de Prueba | Herramienta | Objetivo |
|---|---|---|
| **Unit Testing** | Vitest / Jest + Angular Testing Library | Validar validadores de formato (RFC, CURP, Teléfono) y pipes de montos con cobertura > 90%. |
| **Component Harnesses** | Angular CDK Component Harnesses | Probar la interacción de formularios reactivos y directivas de auto-tabulación (`[appAutoTab]`). |
| **End-to-End (E2E)** | Playwright | Automatizar pruebas completas de flujos de cajero ejecutando únicamente secuencias de teclado (`F1`, `Tab`, valores, `Enter`, `F12`). |
| **Accesibilidad (a11y)** | Axe-core / Pa11y | Garantizar cumplimiento WCAG 2.1 Nivel AA en contrastes de pantalla y lectores de pantalla. |
