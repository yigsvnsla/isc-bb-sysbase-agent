# Fronteras de Arquitectura y Servicios: COBOL Backend → Angular 19+ Frontend

Este documento establece la delimitación rigurosa de responsabilidades entre el Backend transaccional bancario y el Frontend en **Angular 19+**, definiendo los límites de migración, los contratos de interfaz REST y las políticas de ciclo de vida seguro (RAII).

---

## 1. Delimitación de Frontera: Componentes No Migrables al Frontend

Los siguientes componentes y mecanismos pertenecen estrictamente a la capa de persistencia, reglas del Host o procesamiento por lotes del servidor, y **NO deben migrarse al frontend**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        FRONTEND ANGULAR 19+                            │
│  - Standalone Components & Directives (Posicionamiento, Formatos)     │
│  - Typed Reactive Forms (Validaciones síncronas de formato RFC/CURP)   │
│  - UI State Management con Signals (Store de sesión, filtros, grids)   │
│  - Manejo de Teclado PF-Keys & Action Bars                             │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ HTTP / REST APIs (JSON / DTOs)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                    BACKEND HOST / SERVICIOS CORE                       │
│  ❌ Archivos Indexados .DAT (CUSTOMER.DAT, ACCOUNT.DAT, TRANLOG.DAT)   │
│  ❌ Bloqueos de Registros y Concurrencia (File Status 99/24)           │
│  ❌ Procesos Batch Nocturnos (BCHDAY00, BCHMTH00, BCHINT00, BCHODO00)   │
│  ❌ Persistencia Contable y Partida Doble (GLMASTER.DAT, BCHGLI00)     │
│  ❌ Manejo Directo de Terminales CRT / Pantalla Física (COMSCRN)       │
└────────────────────────────────────────────────────────────────────────┘
```

### 1.1. Detalle de Dependencias Excluidas del Frontend

| Componente COBOL Original | Naturaleza en COBOL | Razón de Exclusión del Frontend | Solución Arquitectural en Backend |
|---|---|---|---|
| Archivos `.DAT` (22 archivos) | Archivos indexados ISAM (`ORGANIZATION IS INDEXED`) | El navegador no maneja sistemas de archivos directos ni accesos por llave ISAM. | Base de datos relacional (PostgreSQL/Oracle) o microservicios de datos con JPA/Spring/Node.js. |
| Bloqueos de registro (`FS='99'/'24'`) | Bloqueo pesimista físico a nivel de archivo | Inseguro y no escalable en entornos web concurrentes. | Control de concurrencia optimista (`@Version` / ETag) y transacciones ACID en base de datos. |
| Motor Batch (`BCH*`) | Cierres contables masivos, cálculo de intereses y mora (`BCHINT00`) | Procesamiento de alta carga de datos que requiere horas de cómputo y aislamiento. | Orquestación Batch (Spring Batch / Quartz / Cron Kubernetes) disparado por API de administración. |
| Partida Doble (`GLMASTER`) | Balances contables y afectación de cuentas de mayor | Lógica transaccional crítica y regulada del core bancario. | Motor de contabilidad centralizado en backend con validación de balance débito/crédito. |
| Seguridad física (`COMSCRN`, CRT) | Manipulación de buffer de video VGA/CRT 80x24 | Incompatible con el DOM y estándares web modernos. | CSS Grid / Flexbox / Componentes Web accesibles en Angular. |

---

## 2. Arquitectura de Servicios en Angular 19+

Para conectar las pantallas con el backend, se diseñan contratos HTTP tipados basados en `HttpClient` de Angular con funciones `inject()` e inyección en `root`.

### 2.1. Interfaces y Modelos DTO Tipados

```typescript
// src/app/core/models/api-response.model.ts
export interface ApiResponse<T> {
  success: boolean;
  returnCode: string; // '00'=OK, '01'=Not Found, '02'=Duplicate, etc.
  message: string;
  data: T;
  timestamp: string;
}

export interface PagedResponse<T> {
  items: T[];
  totalCount: number;
  pageIndex: number;
  pageSize: number;
  totalPages: number;
}
```

```typescript
// src/app/core/models/customer.model.ts
export interface CustomerDTO {
  cusId: string;
  cusIdType: 'PF' | 'PM' | 'GO';
  cusName: string;
  cusFirstLastname?: string;
  cusSecondLastname?: string;
  cusRfc: string;
  cusCurp?: string;
  cusAddress: {
    stret: string;
    numExt: string;
    numInt?: string;
    colonia: string;
    ciudad: string;
    estado: string;
    pais: string;
    cp: string;
  };
  cusContact: {
    telefono1: string;
    telefono2?: string;
    celular?: string;
    email: string;
  };
  cusEmployment?: {
    empresa: string;
    puesto: string;
    ingresoMensual: number;
  };
  cusSegmento: '01' | '02' | '03' | '04' | '05';
  cusRiesgoCategoria: 'A' | 'B' | 'C' | 'D';
  cusStatus: 'A' | 'I' | 'B' | 'F';
  cusFechaAlta: string;
}

export interface CreateCustomerCommand extends Omit<CustomerDTO, 'cusId' | 'cusSegmento' | 'cusRiesgoCategoria' | 'cusStatus' | 'cusFechaAlta'> {}
```

```typescript
// src/app/core/models/teller.model.ts
export interface TellerDepositRequest {
  accountNbr: string;
  amount: number;
  type: 'E' | 'C'; // Efectivo / Cheque
  chqNbr?: string;
  chqBank?: string;
  chqAccount?: string;
}

export interface TellerDepositResult {
  transactionSeq: string;
  accountNbr: string;
  previousBalance: number;
  depositAmount: number;
  newBalance: number;
  effectiveDate: string;
  tellerId: string;
  branch: string;
}
```

---

### 2.2. Definición de Servicios Core

#### 1. `CustomerService` (Reemplaza llamadas a `CUS*`)
```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiResponse, PagedResponse } from '../models/api-response.model';
import { CustomerDTO, CreateCustomerCommand } from '../models/customer.model';

@Injectable({ providedIn: 'root' })
export class CustomerService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/v1/customers';

  searchCustomers(query: { type: string; value: string; page?: number; size?: number }): Observable<ApiResponse<PagedResponse<CustomerDTO>>> {
    const params = new HttpParams()
      .set('searchType', query.type)
      .set('searchValue', query.value)
      .set('page', query.page?.toString() ?? '1')
      .set('size', query.size?.toString() ?? '20');

    return this.http.get<ApiResponse<PagedResponse<CustomerDTO>>>(`${this.baseUrl}/search`, { params });
  }

  getCustomerById(cusId: string): Observable<ApiResponse<CustomerDTO>> {
    return this.http.get<ApiResponse<CustomerDTO>>(`${this.baseUrl}/${cusId}`);
  }

  createCustomer(command: CreateCustomerCommand): Observable<ApiResponse<CustomerDTO>> {
    return this.http.post<ApiResponse<CustomerDTO>>(this.baseUrl, command);
  }

  updateCustomer(cusId: string, command: Partial<CreateCustomerCommand>): Observable<ApiResponse<CustomerDTO>> {
    return this.http.put<ApiResponse<CustomerDTO>>(`${this.baseUrl}/${cusId}`, command);
  }

  changeStatus(cusId: string, newStatus: string, reason: string): Observable<ApiResponse<void>> {
    return this.http.patch<ApiResponse<void>>(`${this.baseUrl}/${cusId}/status`, { status: newStatus, reason });
  }
}
```

#### 2. `TellerService` (Reemplaza llamadas a `TLR*`)
```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiResponse } from '../models/api-response.model';
import { TellerDepositRequest, TellerDepositResult } from '../models/teller.model';

export interface TellerSignonRequest {
  tellerId: string;
  initialCash: number;
}

export interface TellerCloseRequest {
  tellerId: string;
  closingCash: number;
}

@Injectable({ providedIn: 'root' })
export class TellerService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/v1/teller';

  signOn(request: TellerSignonRequest): Observable<ApiResponse<{ sessionToken: string; openedAt: string }>> {
    return this.http.post<ApiResponse<{ sessionToken: string; openedAt: string }>>(`${this.baseUrl}/sign-on`, request);
  }

  deposit(request: TellerDepositRequest): Observable<ApiResponse<TellerDepositResult>> {
    return this.http.post<ApiResponse<TellerDepositResult>>(`${this.baseUrl}/transactions/deposit`, request);
  }

  withdraw(request: { accountNbr: string; amount: number }): Observable<ApiResponse<TellerDepositResult>> {
    return this.http.post<ApiResponse<TellerDepositResult>>(`${this.baseUrl}/transactions/withdraw`, request);
  }

  transfer(request: { sourceAccount: string; targetAccount: string; amount: number }): Observable<ApiResponse<TellerDepositResult>> {
    return this.http.post<ApiResponse<TellerDepositResult>>(`${this.baseUrl}/transactions/transfer`, request);
  }

  closeSession(request: TellerCloseRequest): Observable<ApiResponse<{ variance: number; isBalanced: boolean }>> {
    return this.http.post<ApiResponse<{ variance: number; isBalanced: boolean }>>(`${this.baseUrl}/close`, request);
  }
}
```

#### 3. Catálogo de Servicios Frontend Restantes

| Servicio Angular | Endpoints Base | Funcionalidad COBOL Equivalente |
|---|---|---|
| `AccountService` | `/api/v1/accounts` | `ACTOPN00` (apertura), `ACTINQ00` (consulta), `ACTBAL00` (saldos), `ACTSTM00` (estados de cuenta), `ACTCLS00` (cierre), `ACTFRZ00` (bloqueo). |
| `LoanService` | `/api/v1/loans`, `/api/v1/loan-applications` | `LONAPL00` (solicitud y score), `LONAPV00` (aprobación), `LONDIS00` (desembolso), `LONAMR00` (tabla amortización), `LONPYM00` (pagos). |
| `CardService` | `/api/v1/cards` | `CRDINQ00` (consulta), `CRDBLK00` (bloqueo/robo), `CRDPIN00` (cambio PIN), `CRDLMT00` (límites). |
| `DepositService` | `/api/v1/time-deposits` | `TDOPN000` (apertura CD plazo fijo), `TDINQ000` (consulta), `TDCLS000` (liquidación/renovación). |
| `SecurityService` | `/api/v1/auth`, `/api/v1/users` | `BNK0001` (login/autenticación), `SECPWD00` (cambio password), `SECUSR00` (usuarios/roles). |
| `AuditService` | `/api/v1/audit-trail` | `AUDTRL00`, `SECAUD00` (consulta de pista de auditoría y sesiones). |
| `BatchService` | `/api/v1/batch-admin` | `BCHMNU00`, `BCHDAY00` (ejecución y monitoreo de procesos nocturnos para rol Administrador). |
| `ReportService` | `/api/v1/reports` | `RPTBAL00`, `RPTTXN00`, `RPTDEL00`, `RPTTLR00` (generación y descarga PDF/Excel). |

---

## 3. Pipeline de Interceptores HTTP

Se configuran 4 interceptores funcionales en Angular 19+ (`provideHttpClient(withInterceptors([...]))`):

```typescript
// src/app/core/interceptors/auth.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();

  if (token && !req.headers.has('Authorization')) {
    const authReq = req.clone({
      headers: req.headers.set('Authorization', `Bearer ${token}`)
    });
    return next(authReq);
  }
  return next(req);
};
```

```typescript
// src/app/core/interceptors/session-context.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { SessionContextService } from '../services/session-context.service';

export const sessionContextInterceptor: HttpInterceptorFn = (req, next) => {
  const session = inject(SessionContextService);
  
  const headers = req.headers
    .set('X-Branch-ID', session.branchId() || 'S001')
    .set('X-Terminal-ID', session.terminalId() || 'TERM001')
    .set('X-User-ID', session.userId() || 'COBOL01')
    .set('X-Correlation-ID', crypto.randomUUID());

  return next(req.clone({ headers }));
};
```

```typescript
// src/app/core/interceptors/http-error.interceptor.ts
import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { ToastService } from '../services/toast.service';

export const httpErrorInterceptor: HttpInterceptorFn = (req, next) => {
  const toast = inject(ToastService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let userMessage = 'ERROR DE COMUNICACIÓN CON EL SERVIDOR';
      
      // Mapeo de códigos de retorno COBOL y HTTP Status
      if (error.status === 400) {
        userMessage = error.error?.message || 'DATOS INVÁLIDOS (CÓDIGO 05)';
      } else if (error.status === 401) {
        userMessage = 'SESIÓN EXPIRADA O NO AUTORIZADO (CÓDIGO 03)';
      } else if (error.status === 404) {
        userMessage = 'REGISTRO NO ENCONTRADO (CÓDIGO 01)';
      } else if (error.status === 409) {
        userMessage = 'REGISTRO DUPLICADO O EN CONFLICTO (CÓDIGO 02)';
      } else if (error.status >= 500) {
        userMessage = 'ERROR INTERNO DEL HOST (CÓDIGO 99)';
      }

      toast.showError(userMessage);
      return throwError(() => error);
    })
  );
};
```

---

## 4. Gestión de Ciclo de Vida Seguro (RAII Frontend en Angular 19+)

Para garantizar la liberación determinista de recursos, evitar memory leaks y desacoplar suscripciones asíncronas, se aplican los siguientes patrones estandarizados:

### 4.1. `takeUntilDestroyed` con `DestroyRef`

```typescript
import { Component, OnInit, inject, DestroyRef, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { debounceTime, distinctUntilChanged, switchMap } from 'rxjs';
import { CustomerService } from '../../core/services/customer.service';

@Component({
  selector: 'app-customer-search-auto',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <input [formControl]="searchControl" placeholder="Buscar por RFC o Nombre..." />
  `
})
export class CustomerSearchAutoComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly customerService = inject(CustomerService);
  private readonly destroyRef = inject(DestroyRef); // Inyección de contexto de destrucción

  readonly searchControl = this.fb.control('');
  readonly results = signal<any[]>([]);

  ngOnInit(): void {
    // Suscripción segura atada al ciclo de vida del componente
    this.searchControl.valueChanges.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap(query => this.customerService.searchCustomers({ type: '02', value: query || '' })),
      takeUntilDestroyed(this.destroyRef) // Desuscripción automática al destruir el componente
    ).subscribe({
      next: res => this.results.set(res.data.items),
      error: err => console.error('Error en búsqueda:', err)
    });
  }
}
```

### 4.2. Conversión Declarativa a Signals (`toSignal`)

```typescript
import { Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { AccountService } from '../../core/services/account.service';

@Component({
  selector: 'app-account-rate-display',
  standalone: true,
  template: `
    @if (rates(); as rateList) {
      <div class="rates-widget">
        <span>TASA VIGENTE: {{ rateList[0].rate }}%</span>
      </div>
    }
  `
})
export class AccountRateDisplayComponent {
  private readonly accountService = inject(AccountService);

  // toSignal se encarga internamente de la suscripción y desuscripción automática
  readonly rates = toSignal(this.accountService.getInterestRates(), { initialValue: [] });
}
```

---

## 5. Mapeo Canónico de Códigos de Retorno COBOL → HTTP & Problem Details

| Código COBOL (`WS-RETURN-CODE`) | Mensaje COBOL Original | HTTP Status | Problem Details Code | Tratamiento UI |
|---|---|---|---|---|
| `00` | Operación exitosa | `200 OK` / `201 Created` | `SUCCESS` | Toast verde / Continuar flujo |
| `01` | Registro no encontrado | `404 Not Found` | `ENTITY_NOT_FOUND` | Alerta amarilla en formulario |
| `02` | Registro duplicado | `409 Conflict` | `DUPLICATE_KEY` | Error en campo clave (RFC/Cuenta) |
| `03` | Usuario no autorizado | `403 Forbidden` | `ACCESS_DENIED` | Modal de permiso insuficiente |
| `04` | Error de archivo | `500 Internal Server Error` | `FILE_IO_ERROR` | Banner rojo crítico |
| `05` | Datos inválidos | `400 Bad Request` | `VALIDATION_FAILED` | Resaltado de controles inválidos |
| `06` | Cuenta cerrada | `422 Unprocessable Entity`| `ACCOUNT_CLOSED` | Bloqueo de operaciones de abono/cargo |
| `07` | Fondos insuficientes | `422 Unprocessable Entity`| `INSUFFICIENT_FUNDS`| Mensaje en pantalla de retiro |
| `08` | Registro bloqueado | `423 Locked` | `RECORD_LOCKED` | Indicador de reintento |
| `09` | Registro expirado | `410 Gone` | `RECORD_EXPIRED` | Forzar refresco de datos |
| `10` | Sesión expirada / Timeout | `401 Unauthorized` | `SESSION_TIMEOUT` | Redirección a Login (`/login`) |
| `11` | Transacción rechazada | `422 Unprocessable Entity`| `TRANSACTION_REJECTED`| Razón de rechazo en línea de estado |
| `99` | Error desconocido / Fallo host| `500 Internal Error` | `HOST_FAILURE` | Modal de asistencia técnica |
