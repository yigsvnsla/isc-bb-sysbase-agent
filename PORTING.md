# Reglas de Conversión Idiomáticas: Micro Focus COBOL → Angular 19+ / TypeScript

Este documento define la especificación técnica formal y las reglas deterministas para migrar el sistema bancario COBOL Micro Focus (`samples/cobol/projects/isc-cobol-test`) hacia una arquitectura frontend moderna basada en **Angular 19+ (Standalone Components, Signals, Typed Reactive Forms, TypeScript 5.5+ estricto)**.

---

## 1. Tabla Resumen de Mapeo de Idioms

| # | Idiom COBOL (Micro Focus) | Constructo Angular 19+ / TypeScript | Estrategia de Conversión & Semántica |
|---|---|---|---|
| 1 | `SCREEN SECTION` / `DISPLAY ... AT LINE COL` / `ACCEPT` | Angular Standalone Component Template + CSS Grid 80x24 / Flexbox | Plantillas HTML semánticas con layout responsivo que preserva orden tabular o emula terminal con CSS Grid. |
| 2 | `AUTO` | Directiva personalizada `[appAutoTab]` | Salto automático de foco al siguiente control cuando se alcanza el `maxlength`. |
| 3 | `REQUIRED` | `Validators.required` en Reactive Form Controls | Validación síncrona en TypeScript + atributo HTML `required` / `aria-required="true"`. |
| 4 | `SECURE` | `<input type="password">` + Signal de visibilidad | Entrada enmascarada con botón de alternancia mostrar/ocultar contraseña. |
| 5 | `PROMPT '___'` | Atributo `placeholder="___"` / Input Mask | Indicador visual de longitud y formato de captura. |
| 6 | `HIGHLIGHT` / `REVERSE-VIDEO` | Clases CSS (`.highlight`, `.reverse-video`) / Angular Signals | Variables CSS y clases dinámicas (`[class.highlight]="isFocused()"`) para énfasis visual. |
| 7 | `BLINK` | Notificación UI Banner / Toast / Animación CSS `@keyframes` | Mensajes críticos con banner flotante, alerta de formulario accesible (`role="alert"`) o animación controlada. |
| 8 | `PIC X(n)` | `string` con `Validators.maxLength(n)` | Control de texto tipado en `FormControl<string>` con límite estricto de caracteres. |
| 9 | `PIC 9(n)` | `string` con máscara numérica o `number` | `FormControl<string>` con validador regex `/^[0-9]{n}$/` para IDs/claves que conservan ceros a la izquierda. |
| 10 | `PIC 9(n)V99` / `S9(n)V99 COMP-3` | `number` / `Decimal` (decimal.js) + Currency Pipe | Manejo de montos con precisión de punto fijo de 2 decimales y formateador `currency:'MXN':'symbol':'1.2-2'`. |
| 11 | `PIC Z(12)9.99` / `PIC Z(09)9` | Custom Currency Pipe / Mask Directive | Formato de edición COBOL (supresión de ceros no significativos a la izquierda) en presentación visual. |
| 12 | Nivel `88` (Condition Names) | `enum` TypeScript o `const` Union Types + Type Guards | Tipos de unión literales (`type CusStatus = 'A' | 'I' | 'B' | 'F'`) y funciones guard `isCusActive()`. |
| 13 | `WORKING-STORAGE SECTION` | Component State Signals (`signal()`, `computed()`) & `FormGroup` | Estado reactivo del componente, stores locales y formularios reactivos tipados. |
| 14 | `LOCAL-STORAGE SECTION` | Variables locales de método (`let`, `const`) | Variables temporales efímeras de ejecución síncrona. |
| 15 | `LINKAGE SECTION` | Component `input()` signals / Router State / Route Params | Parámetros de navegación vía `ActivatedRoute` o inputs del componente standalone. |
| 16 | `PERFORM ... THRU` | Métodos TypeScript (`async guardarCliente(): Promise<void>`) | Funciones estructuradas con manejo asíncrono y control de excepciones (`try/catch`). |
| 17 | `EVALUATE TRUE / WHEN ...` | `switch(true)` o Mapeos Declarativos (`Map<T, () => void>`) | Estructuras de selección deterministas sin side-effects descontrolados. |
| 18 | `CALL 'PROG' USING ...` | `Router.navigate()` o Llamada a Backend Service API | Transición de ruta con paso de parámetros o invocación a servicio HTTP tipado. |
| 19 | Teclas PF (`PF1`..`PF12`, `ENTER`, `CLEAR`) | `@HostListener('window:keydown')` + Action Bar Component | Manejador centralizado de atajos de teclado y barra inferior de acciones clicables. |
| 20 | `OCCURS n TIMES` | Angular Signals Arrays (`signal<T[]>([])`) + `@for` | Listas dinámicas renderizadas con la directiva `@for (item of items(); track item.id)`. |
| 21 | Mensajes en Línea 24 (`WS-MENSAJE-ERROR`) | Signal UI Toast / Banner / `<mat-error>` | Componente de alertas reactivo enlazado a signals `errorMessage()` y `infoMessage()`. |
| 22 | `COMVALF` (RFC, CURP, Teléfono, Fechas) | Reactive Form Custom Sync Validators | Validadores puros reutilizables integrados en el pipeline de formularios reactivos. |

---

## 2. Especificación Detallada de Conversión con Ejemplos Reales

### 2.1. SCREEN SECTION y Posicionamiento 80x24 → Templates Angular

En COBOL Micro Focus, la interfaz de usuario se define mediante coordenadas absolutas `LINE` y `COL` dentro de una matriz de 80 columnas por 24 filas.

#### Ejemplo COBOL Original (`BNK0001.cbl` / `CUSMNT00.cbl`):
```cobol
       SCREEN SECTION.
       01  SCR-LOGIN.
           05  SCR-LOGIN-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
               10  LINE 01  COL 65  PIC X(06) FROM WS-VERSION.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' MODULO DE ACCESO AL SISTEMA'.
           05  SCR-LOGIN-CUERPO.
               10  LINE 05  COL 20  PIC X(40)
                   VALUE 'BIENVENIDO AL SISTEMA BANCARIO'.
               10  LINE 07  COL 20  PIC X(20) VALUE 'USUARIO:'.
               10  LINE 07  COL 32  PIC X(08)
                   USING WS-USUARIO AUTO PROMPT '________'.
               10  LINE 09  COL 20  PIC X(20) VALUE 'CONTRASENA:'.
               10  LINE 09  COL 32  PIC X(20)
                   USING WS-CONTRASENA AUTO PROMPT '____________________'
                   SECURE.
           05  SCR-LOGIN-MENSAJE.
               10  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
           05  SCR-LOGIN-PIE.
               10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 24  COL 02  PIC X(35)
                   VALUE 'PF1=AYUDA  PF12=SALIR  ENTER=ACEPTAR'.
```

#### Equivalente en Angular 19+ (Standalone Template):
```html
<div class="terminal-screen-container" [class.cobol-theme]="isClassicTheme()">
  <!-- Cabecera Estándar (Líneas 1-2) -->
  <header class="screen-header">
    <div class="header-line-1">
      <span class="system-title">BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO</span>
      <span class="system-version">{{ version() }}</span>
    </div>
    <div class="header-line-2">
      <h1 class="screen-title">MODULO DE ACCESO AL SISTEMA</h1>
    </div>
  </header>

  <!-- Cuerpo Principal (Líneas 3-22) -->
  <main class="screen-body">
    <section class="welcome-box">
      <h2>BIENVENIDO AL SISTEMA BANCARIO</h2>
    </section>

    <form [formGroup]="loginForm" (ngSubmit)="onLogin()" class="form-grid-80x24" novalidate>
      <!-- Campo Usuario (Línea 7, Col 20-40) -->
      <div class="form-row grid-line-7">
        <label for="wsUsuario" class="form-label col-20">USUARIO:</label>
        <input
          id="wsUsuario"
          type="text"
          formControlName="wsUsuario"
          appAutoTab
          maxlength="8"
          placeholder="________"
          autocomplete="username"
          class="form-input col-32"
          [attr.aria-invalid]="loginForm.controls.wsUsuario.invalid && loginForm.controls.wsUsuario.touched"
        />
      </div>

      <!-- Campo Contraseña (Línea 9, Col 20-52) -->
      <div class="form-row grid-line-9">
        <label for="wsContrasena" class="form-label col-20">CONTRASENA:</label>
        <div class="password-wrapper col-32">
          <input
            id="wsContrasena"
            [type]="showPassword() ? 'text' : 'password'"
            formControlName="wsContrasena"
            appAutoTab
            maxlength="20"
            placeholder="____________________"
            autocomplete="current-password"
            class="form-input"
          />
          <button
            type="button"
            class="pwd-toggle-btn"
            (click)="togglePasswordVisibility()"
            [attr.aria-label]="showPassword() ? 'Ocultar contraseña' : 'Ver contraseña'"
          >
            <span class="icon">{{ showPassword() ? '👁️' : '🔒' }}</span>
          </button>
        </div>
      </div>

      <!-- Mensajes Informativos y de Error (Línea 14) -->
      <div class="message-area grid-line-14" role="status" aria-live="polite">
        @if (errorMessage()) {
          <div class="msg-error blink-notification" role="alert">
            <span class="error-badge">ERROR:</span> {{ errorMessage() }}
          </div>
        } @else if (infoMessage()) {
          <div class="msg-info">
            {{ infoMessage() }}
          </div>
        }
      </div>
    </form>
  </main>

  <!-- Separador y Barra de Acciones PF-Keys (Líneas 23-24) -->
  <footer class="screen-footer">
    <div class="separator-line" aria-hidden="true"></div>
    <app-pf-action-bar
      [actions]="pfActions"
      (actionTriggered)="onPfAction($event)"
    />
  </footer>
</div>
```

---

### 2.2. Directivas de Pantalla COBOL → Implementación Angular

#### A. `AUTO` (Salto automático de foco al llenar el campo)
Directiva Angular reutilizable:
```typescript
import { Directive, ElementRef, HostListener, inject } from '@angular/core';

@Directive({
  selector: '[appAutoTab]',
  standalone: true
})
export class AutoTabDirective {
  private readonly el = inject(ElementRef<HTMLInputElement>);

  @HostListener('input', ['$event'])
  onInput(): void {
    const input = this.el.nativeElement;
    const maxLength = input.maxLength;
    if (maxLength > 0 && input.value.length >= maxLength) {
      const form = input.form;
      if (!form) return;
      
      const elements = Array.from(
        form.querySelectorAll<HTMLInputElement | HTMLButtonElement | HTMLSelectElement>(
          'input:not([disabled]):not([type="hidden"]), select:not([disabled]), button:not([disabled])'
        )
      );
      const currentIndex = elements.indexOf(input);
      if (currentIndex > -1 && currentIndex + 1 < elements.length) {
        elements[currentIndex + 1].focus();
      }
    }
  }
}
```

#### B. `REQUIRED` y `PROMPT`
En el TypeScript del componente:
```typescript
this.form = this.fb.group({
  cusIdType: ['', [Validators.required, Validators.pattern(/^(PF|PM|GO)$/)]],
  cusName: ['', [Validators.required, Validators.maxLength(60)]],
  cusRfc: ['', [Validators.required, satRfcValidator()]]
});
```

#### C. `BLINK`, `HIGHLIGHT`, `REVERSE-VIDEO`
En el archivo CSS (`styles.css` / SCSS del tema terminal):
```css
/* BLINK moderno (animación no invasiva o estilo banner) */
@keyframes cobol-blink {
  0%, 49% { opacity: 1; }
  50%, 100% { opacity: 0.2; }
}

.blink-notification {
  animation: cobol-blink 1.2s infinite ease-in-out;
  color: #ff3333;
  font-weight: bold;
  background-color: rgba(255, 0, 0, 0.1);
  padding: 4px 8px;
  border-radius: 4px;
}

/* HIGHLIGHT */
.highlight {
  font-weight: 700;
  color: #00ff66; /* Verde fósforo terminal o acento primario */
  text-shadow: 0 0 4px rgba(0, 255, 102, 0.6);
}

/* REVERSE-VIDEO */
.reverse-video {
  background-color: #33ff33;
  color: #000000;
  padding: 2px 6px;
}
```

---

### 2.3. Mapeo de Tipos de Datos COBOL → TypeScript / Angular

| Tipo COBOL | Ejemplo Real en Copybook | Representación TypeScript | Formato de Presentación / Pipe |
|---|---|---|---|
| `PIC X(n)` | `CUS-NAME PIC X(60)` | `string` | `<input maxlength="60">` |
| `PIC 9(n)` (Clave/Identificador) | `CUS-ID PIC X(10)`, `TRN-SEQ PIC 9(10)` | `string` (para preservar padding '000123') | `padLeft(10, '0')` |
| `PIC 9(n)` (Contador/Entero) | `ACT-TXN-COUNT-TODAY PIC 9(06)` | `number` | `number:'1.0-0'` |
| `PIC 9(n)V99 COMP-3` | `CUS-INGRESO-MENSUAL PIC 9(09)V99` | `number` (2 decimales fijos) | `currency:'MXN':'symbol':'1.2-2'` |
| `PIC S9(13)V99 COMP-3` | `ACT-BALANCE PIC S9(13)V99` | `number` (con signo +/-) | `currency:'MXN':'symbol':'1.2-2'` |
| `PIC 9(03)V9(04) COMP-3` | `ACT-INTEREST-RATE PIC 9(03)V9(04)` | `number` (hasta 4 decimales) | `percent:'1.2-4'` |
| `PIC 9(08)` (Fecha AAAAMMDD) | `CUS-FECHA-NACIMIENTO PIC 9(08)` | `string` ('YYYYMMDD') o `Date` | Pipe custom `cobolDate` -> `DD/MM/YYYY` |
| `PIC 9(06)` (Hora HHMMSS) | `TRN-TIME PIC 9(06)` | `string` ('HHMMSS') | Pipe custom `cobolTime` -> `HH:MM:SS` |
| `PIC Z(12)9.99` (Edición) | `WS-MONTO-DISPLAY PIC Z(12)9.99` | `number` formateado | Angular `CurrencyPipe` / `DecimalPipe` |

---

### 2.4. Mapeo de Niveles 88 (Condition Names) → TypeScript Enums y Tipos Seguros

#### Ejemplo COBOL (`fd-customer.cpy` y `fd-account.cpy`):
```cobol
       05  CUS-ID-TYPE                 PIC X(02).
           88  CUS-TYPE-PHYSICAL       VALUE 'PF'.
           88  CUS-TYPE-MORAL          VALUE 'PM'.
           88  CUS-TYPE-GUBERNAMENTAL  VALUE 'GO'.
       05  CUS-STATUS                  PIC X(01).
           88  CUS-STATUS-ACTIVO       VALUE 'A'.
           88  CUS-STATUS-INACTIVO     VALUE 'I'.
           88  CUS-STATUS-BLOQUEADO    VALUE 'B'.
           88  CUS-STATUS-FALLECIDO    VALUE 'F'.
       05  ACT-TYPE                    PIC X(02).
           88  ACT-TYPE-CHEQUES        VALUE 'CH'.
           88  ACT-TYPE-AHORRO         VALUE 'AH'.
           88  ACT-TYPE-NOMINA         VALUE 'NO'.
           88  ACT-TYPE-INVERSION      VALUE 'IN'.
       05  ACT-STATUS                  PIC X(01).
           88  ACT-STATUS-ACTIVE       VALUE 'A'.
           88  ACT-STATUS-INACTIVE     VALUE 'I'.
           88  ACT-STATUS-CLOSED       VALUE 'C'.
           88  ACT-STATUS-FROZEN       VALUE 'F'.
           88  ACT-STATUS-DORMANT      VALUE 'D'.
```

#### Equivalente TypeScript:
```typescript
// Tipos literales y Enums
export const CusIdType = {
  PHYSICAL: 'PF',
  MORAL: 'PM',
  GUBERNAMENTAL: 'GO',
} as const;
export type CusIdType = typeof CusIdType[keyof typeof CusIdType];

export const CusStatus = {
  ACTIVO: 'A',
  INACTIVO: 'I',
  BLOQUEADO: 'B',
  FALLECIDO: 'F',
} as const;
export type CusStatus = typeof CusStatus[keyof typeof CusStatus];

export const ActType = {
  CHEQUES: 'CH',
  AHORRO: 'AH',
  NOMINA: 'NO',
  INVERSION: 'IN',
} as const;
export type ActType = typeof ActType[keyof typeof ActType];

export const ActStatus = {
  ACTIVE: 'A',
  INACTIVE: 'I',
  CLOSED: 'C',
  FROZEN: 'F',
  DORMANT: 'D',
} as const;
export type ActStatus = typeof ActStatus[keyof typeof ActStatus];

// Type Guards y funciones de utilidad
export function isCusActive(status: CusStatus | string): boolean {
  return status === CusStatus.ACTIVO;
}

export function isAccountOperable(status: ActStatus | string): boolean {
  return status === ActStatus.ACTIVE;
}

export const CUS_ID_TYPE_LABELS: Record<CusIdType, string> = {
  [CusIdType.PHYSICAL]: 'Persona Física (PF)',
  [CusIdType.MORAL]: 'Persona Moral (PM)',
  [CusIdType.GUBERNAMENTAL]: 'Gubernamental (GO)',
};
```

---

### 2.5. Ciclo de Vida y Variables de Estado

```
┌─────────────────────────────────────────────────────────────┐
│ COBOL SECTION              │ ANGULAR 19+ STATE TARGET       │
├────────────────────────────┼────────────────────────────────┤
│ WORKING-STORAGE SECTION    │ Component State (Signals) /    │
│                            │ FormGroup / Injected Services  │
├────────────────────────────┼────────────────────────────────┤
│ LOCAL-STORAGE SECTION      │ Method Local Variables         │
│                            │ (const / let in functions)     │
├────────────────────────────┼────────────────────────────────┤
│ LINKAGE SECTION            │ Component input() signals /    │
│                            │ ActivatedRoute paramMap / state│
└────────────────────────────┴────────────────────────────────┘
```

#### Ejemplo COBOL (`CUSMNT00.cbl`):
```cobol
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.

       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
```

#### Equivalente Angular 19+:
```typescript
import { Component, input, signal, computed, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';

@Component({
  selector: 'app-cusmnt00-alta-cliente',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './cusmnt00-alta-cliente.component.html'
})
export class Cusmnt00AltaClienteComponent {
  private readonly fb = inject(FormBuilder);
  private readonly router = inject(Router);

  // Equivalente a LINKAGE SECTION: Signal Inputs
  readonly usuarioId = input<string>(''); // Vía router input binding o @Input()
  
  // Equivalente a WORKING-STORAGE: Component State Signals
  readonly errorMessage = signal<string>('');
  readonly infoMessage = signal<string>('INGRESE DATOS DEL CLIENTE, PF3=GUARDAR');
  readonly isSubmitting = signal<boolean>(false);

  // Formulario reactivo tipado
  readonly clientForm = this.fb.group({
    cusIdType: ['', [Validators.required, Validators.pattern(/^(PF|PM|GO)$/)]],
    cusName: ['', [Validators.required, Validators.maxLength(60)]],
    cusFirstLastname: ['', [Validators.maxLength(30)]],
    cusSecondLastname: ['', [Validators.maxLength(30)]],
    cusRfc: ['', [Validators.required, satRfcValidator()]],
    cusCurp: ['', [curpValidator()]],
    cusStret: ['', [Validators.maxLength(40)]],
    cusNumExt: ['', [Validators.maxLength(10)]],
    cusNumInt: ['', [Validators.maxLength(10)]],
    cusColonia: ['', [Validators.maxLength(30)]],
    cusCp: ['', [Validators.pattern(/^[0-9]{5}$/)]],
    cusCiudad: ['', [Validators.maxLength(30)]],
    cusEstado: ['', [Validators.maxLength(20)]],
    cusPais: ['MEX', [Validators.maxLength(20)]],
    cusTelefono1: ['', [Validators.pattern(/^[0-9]{10,15}$/)]],
    cusTelefono2: ['', [Validators.pattern(/^[0-9]{10,15}$/)]],
    cusCelular: ['', [Validators.pattern(/^[0-9]{10,15}$/)]],
    cusEmail: ['', [Validators.email, Validators.maxLength(50)]],
    cusEmpresa: ['', [Validators.maxLength(40)]],
    cusPuesto: ['', [Validators.maxLength(30)]],
    cusIngresoMensual: [0, [Validators.min(0)]],
  });
}
```

---

### 2.6. Control de Flujo: `PERFORM`, `EVALUATE` y `CALL`

#### Ejemplo COBOL (`CUSMNT00.cbl`):
```cobol
       EVALUATE TRUE
           WHEN WS-CRT-PF3
               PERFORM 4000-GUARDAR-CLIENTE
               GO TO ALTA-LOOP
           WHEN WS-CRT-PF11
               CALL 'COMHELP' USING 'CUSMNT00'
               GO TO ALTA-LOOP
           WHEN WS-CRT-PF12
               PERFORM 5000-CONFIRMAR-CANCELAR
               IF WS-CONFIRMED
                   GO TO ALTA-EXIT
               ELSE
                   GO TO ALTA-LOOP
               END-IF
           WHEN WS-CRT-CLEAR
               PERFORM 2000-LIMPIAR-CAMPOS
               MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
               GO TO ALTA-LOOP
       END-EVALUATE.
```

#### Equivalente Angular 19+ (TypeScript):
```typescript
async onPfAction(action: PfActionCode): Promise<void> {
  switch (action) {
    case 'PF3':
      await this.guardarCliente();
      break;
    case 'PF11':
      this.abrirAyuda('CUSMNT00');
      break;
    case 'PF12':
      await this.confirmarYSalir();
      break;
    case 'CLEAR':
      this.limpiarFormulario();
      break;
    default:
      this.errorMessage.set('TECLA NO ASIGNADA: USE PF3=GUARDAR PF12=CANCELAR');
      break;
  }
}

private async guardarCliente(): Promise<void> {
  this.errorMessage.set('');
  if (this.clientForm.invalid) {
    this.clientForm.markAllAsTouched();
    this.errorMessage.set('VERIFIQUE LOS CAMPOS REQUERIDOS O CON ERROR');
    return;
  }

  this.isSubmitting.set(true);
  try {
    const payload = this.clientForm.getRawValue();
    const response = await firstValueFrom(this.customerService.createCustomer(payload));
    this.infoMessage.set(`CLIENTE REGISTRADO CON EXITO. ID: ${response.cusId}`);
    this.router.navigate(['/customers/menu'], {
      state: { feedbackMessage: `ALTA EXITOSA ID: ${response.cusId}` }
    });
  } catch (err: unknown) {
    const errorMsg = this.errorHandler.formatError(err);
    this.errorMessage.set(errorMsg);
  } finally {
    this.isSubmitting.set(false);
  }
}
```

---

### 2.7. Manejo Centralizado de Teclas de Función (PF-Keys)

#### Componente Reutilizable `PfActionBarComponent`:
```typescript
import { Component, EventEmitter, HostListener, Input, Output } from '@angular/core';

export type PfActionCode =
  | 'PF1' | 'PF2' | 'PF3' | 'PF4' | 'PF5' | 'PF6'
  | 'PF7' | 'PF8' | 'PF9' | 'PF10' | 'PF11' | 'PF12'
  | 'ENTER' | 'CLEAR';

export interface PfButtonConfig {
  code: PfActionCode;
  label: string;
  enabled?: boolean;
  danger?: boolean;
}

@Component({
  selector: 'app-pf-action-bar',
  standalone: true,
  template: `
    <nav class="pf-bar" role="toolbar" aria-label="Teclas de acción">
      @for (btn of actions; track btn.code) {
        <button
          type="button"
          class="pf-btn"
          [class.pf-danger]="btn.danger"
          [disabled]="btn.enabled === false"
          (click)="trigger(btn.code)"
        >
          <span class="pf-shortcut">[{{ btn.code }}]</span>
          <span class="pf-text">{{ btn.label }}</span>
        </button>
      }
    </nav>
  `,
  styles: [`
    .pf-bar {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      padding: 6px 12px;
      background: #111827;
      border-top: 2px solid #374151;
    }
    .pf-btn {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 4px 10px;
      background: #1f2937;
      color: #f9fafb;
      border: 1px solid #4b5563;
      border-radius: 4px;
      cursor: pointer;
      font-family: monospace;
      font-size: 13px;
    }
    .pf-btn:hover:not(:disabled) {
      background: #374151;
      border-color: #60a5fa;
    }
    .pf-shortcut {
      color: #93c5fd;
      font-weight: bold;
    }
  `]
})
export class PfActionBarComponent {
  @Input({ required: true }) actions: PfButtonConfig[] = [];
  @Output() actionTriggered = new EventEmitter<PfActionCode>();

  @HostListener('window:keydown', ['$event'])
  handleKeyboardEvent(event: KeyboardEvent): void {
    const keyMap: Record<string, PfActionCode> = {
      'F1': 'PF1', 'F2': 'PF2', 'F3': 'PF3', 'F4': 'PF4',
      'F5': 'PF5', 'F6': 'PF6', 'F7': 'PF7', 'F8': 'PF8',
      'F9': 'PF9', 'F10': 'PF10', 'F11': 'PF11', 'F12': 'PF12',
      'Escape': 'CLEAR',
    };

    if (event.key in keyMap) {
      event.preventDefault();
      const code = keyMap[event.key];
      const found = this.actions.find(a => a.code === code && a.enabled !== false);
      if (found) {
        this.actionTriggered.emit(code);
      }
    }
  }

  trigger(code: PfActionCode): void {
    this.actionTriggered.emit(code);
  }
}
```

---

### 2.8. Grids, Subfiles y OCCURS → Signals y `@for` con Paginación

#### Ejemplo COBOL (`CUSSRH00.cbl` / `cpy-screen.cpy`):
```cobol
       01  SC-SEARCH-KEY.
           05  SC-SEARCH-TYPE             PIC X(02).
           05  SC-SEARCH-VALUE            PIC X(30).
           05  SC-SEARCH-RESULT-COUNT     PIC 9(04).
           05  SC-SEARCH-RESULT-TABLE     OCCURS 20.
               10  SC-SEARCH-RESULT-ID    PIC 9(10).
               10  SC-SEARCH-RESULT-NAME  PIC X(40).
               10  SC-SEARCH-RESULT-TYPE  PIC X(02).
```

#### Equivalente Angular 19+:
```html
<div class="search-results-container">
  <table class="cobol-subfile-table" role="grid">
    <thead>
      <tr>
        <th scope="col">#</th>
        <th scope="col">ID CLIENTE</th>
        <th scope="col">NOMBRE O RAZÓN SOCIAL</th>
        <th scope="col">TIPO</th>
        <th scope="col">ACCIONES</th>
      </tr>
    </thead>
    <tbody>
      @for (item of pagedResults(); track item.id; let i = $index) {
        <tr
          class="subfile-row"
          [class.selected]="selectedRowId() === item.id"
          (click)="selectRow(item.id)"
          tabindex="0"
          (keydown.enter)="selectRow(item.id)"
        >
          <td>{{ (currentPage() - 1) * pageSize + (i + 1) }}</td>
          <td class="font-mono">{{ item.id }}</td>
          <td>{{ item.name }}</td>
          <td><span class="badge">{{ item.type }}</span></td>
          <td>
            <button type="button" class="btn-table-action" (click)="consultarCliente(item.id)">
              [PF2=INQ]
            </button>
          </td>
        </tr>
      } @empty {
        <tr>
          <td colspan="5" class="no-records-msg">
            NO SE ENCONTRARON REGISTROS (CODIGO 01)
          </td>
        </tr>
      }
    </tbody>
  </table>

  <!-- Controles de Paginación PF7 / PF8 -->
  <div class="subfile-pagination">
    <span>PAGINA {{ currentPage() }} DE {{ totalPages() }} (TOTAL: {{ totalCount() }})</span>
    <div class="pagination-buttons">
      <button
        type="button"
        [disabled]="currentPage() <= 1"
        (click)="prevPage()"
        class="pf-btn"
      >
        [PF7=PAG-ANT]
      </button>
      <button
        type="button"
        [disabled]="currentPage() >= totalPages()"
        (click)="nextPage()"
        class="pf-btn"
      >
        [PF8=PAG-SIG]
      </button>
    </div>
  </div>
</div>
```

---

### 2.9. Validadores Síncronos para Negocio Bancario (`COMVALF`)

```typescript
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

/**
 * Validador oficial de RFC mexicano (SAT).
 * Físicas: 4 letras + 6 dígitos + 3 caracteres homoclave = 13
 * Morales: 3 letras + 6 dígitos + 3 caracteres homoclave = 12
 */
export function satRfcValidator(): ValidatorFn {
  const rfcPattern = /^([A-ZÑ&]{3,4})(\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01]))([A-Z\d]{2}[A\d])$/;
  return (control: AbstractControl): ValidationErrors | null => {
    const val = (control.value || '').trim().toUpperCase();
    if (!val) return null; // Campo no requerido por este validador
    if (!rfcPattern.test(val)) {
      return { invalidRfcFormat: { value: control.value } };
    }
    return null;
  };
}

/**
 * Validador oficial de CURP mexicana (18 caracteres).
 */
export function curpValidator(): ValidatorFn {
  const curpPattern = /^[A-Z]{4}\d{6}[HM][A-Z]{2}[B-DF-HJ-NP-TV-Z]{3}[A-Z\d]\d$/;
  return (control: AbstractControl): ValidationErrors | null => {
    const val = (control.value || '').trim().toUpperCase();
    if (!val) return null;
    if (!curpPattern.test(val)) {
      return { invalidCurpFormat: { value: control.value } };
    }
    return null;
  };
}

/**
 * Validador de fecha COBOL AAAAMMDD.
 */
export function cobolDateValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const val = String(control.value || '').trim();
    if (!val) return null;
    if (!/^\d{8}$/.test(val)) return { invalidCobolDateFormat: true };

    const year = parseInt(val.substring(0, 4), 10);
    const month = parseInt(val.substring(4, 6), 10);
    const day = parseInt(val.substring(6, 8), 10);

    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return { invalidDateRange: true };
    }

    const date = new Date(year, month - 1, day);
    if (
      date.getFullYear() !== year ||
      date.getMonth() !== month - 1 ||
      date.getDate() !== day
    ) {
      return { invalidDateCalendar: true };
    }

    return null;
  };
}
```

---

## 3. Matriz de Programas y su Mapeo Angular

| Programa COBOL | Módulo | Componente Angular Target | Ruta Frontend | Copybooks Relacionados |
|---|---|---|---|---|
| `BNK0001` | Seguridad | `LoginComponent`, `ChangePasswordComponent` | `/login`, `/auth/change-password` | `fd-userprof`, `cpy-screen`, `cpy-common` |
| `COMMENU` / `BNK0010` | Menú Base | `MainMenuComponent` | `/dashboard`, `/menu` | `cpy-screen`, `cpy-common` |
| `CUSMNU00` | Clientes | `CustomerMenuComponent` | `/customers` | `cpy-screen`, `cpy-common` |
| `CUSSRH00` | Clientes | `CustomerSearchComponent` | `/customers/search` | `fd-customer`, `cpy-screen` |
| `CUSINQ00` | Clientes | `CustomerDetailComponent` | `/customers/:id` | `fd-customer`, `fd-accountxr` |
| `CUSMNT00` | Clientes | `CustomerCreateComponent` | `/customers/create` | `fd-customer`, `fd-accountxr`, `cpy-codtab` |
| `CUSUPD00` | Clientes | `CustomerEditComponent` | `/customers/:id/edit` | `fd-customer`, `cpy-common` |
| `ACTMNU00` | Cuentas | `AccountMenuComponent` | `/accounts` | `cpy-screen`, `cpy-common` |
| `ACTOPN00` | Cuentas | `AccountOpenComponent` | `/accounts/open` | `fd-account`, `fd-customer`, `fd-accountxr` |
| `ACTINQ00` | Cuentas | `AccountDetailComponent` | `/accounts/:id` | `fd-account`, `cpy-common` |
| `ACTBAL00` | Cuentas | `AccountBalanceComponent` | `/accounts/:id/balance` | `fd-account`, `cpy-common` |
| `ACTSTM00` | Cuentas | `AccountStatementComponent` | `/accounts/:id/statement` | `fd-account`, `fd-tranlog` |
| `TLRMNU00` | Ventanilla | `TellerMenuComponent` | `/teller` | `fd-tellerec`, `cpy-screen` |
| `TLRSGN00` | Ventanilla | `TellerSignonComponent` | `/teller/signon` | `fd-tellerec`, `fd-branch` |
| `TLRDEP00` | Ventanilla | `TellerDepositComponent` | `/teller/deposit` | `fd-account`, `fd-tranlog`, `fd-tellerec` |
| `TLRWTH00` | Ventanilla | `TellerWithdrawalComponent` | `/teller/withdrawal` | `fd-account`, `fd-tranlog`, `fd-tellerec` |
| `TLRTRF00` | Ventanilla | `TellerTransferComponent` | `/teller/transfer` | `fd-account`, `fd-tranlog`, `fd-tellerec` |
| `TLRPYM00` | Ventanilla | `TellerBillPayComponent` | `/teller/bill-pay` | `fd-account`, `fd-tranlog`, `fd-tellerec` |
| `TLRCHE00` | Ventanilla | `TellerCheckCashingComponent`| `/teller/check-cashing`| `fd-account`, `fd-chqbook`, `fd-tranlog` |
| `TLRSMG00` | Ventanilla | `TellerSummaryCloseComponent`| `/teller/close` | `fd-tellerec`, `cpy-screen` |
| `LONMNU00` | Préstamos | `LoanMenuComponent` | `/loans` | `cpy-screen`, `cpy-common` |
| `LONAPL00` | Préstamos | `LoanApplicationComponent` | `/loans/apply` | `fd-loanappl`, `fd-customer` |
| `LONAPV00` | Préstamos | `LoanApprovalComponent` | `/loans/approvals` | `fd-loanappl`, `fd-loanmast` |
| `LONDIS00` | Préstamos | `LoanDisbursementComponent` | `/loans/disbursement` | `fd-loanmast`, `fd-account`, `fd-tranlog` |
| `LONAMR00` | Préstamos | `LoanAmortizationComponent` | `/loans/:id/amortization`| `fd-loanmast` |
| `CRDMNU00` | Tarjetas | `CardMenuComponent` | `/cards` | `cpy-screen`, `cpy-common` |
| `CRDINQ00` | Tarjetas | `CardInquiryComponent` | `/cards/:pan` | `fd-card`, `fd-customer` |
| `CRDBLK00` | Tarjetas | `CardBlockComponent` | `/cards/:pan/block` | `fd-card`, `cpy-common` |
| `CRDPIN00` | Tarjetas | `CardPinChangeComponent` | `/cards/:pan/pin` | `fd-card`, `fd-security` |
| `TDMNU000` | Plazo Fijo | `TimeDepositMenuComponent` | `/time-deposits` | `fd-timedep`, `cpy-screen` |
| `TDOPN000` | Plazo Fijo | `TimeDepositOpenComponent` | `/time-deposits/open` | `fd-timedep`, `fd-ratefile` |
