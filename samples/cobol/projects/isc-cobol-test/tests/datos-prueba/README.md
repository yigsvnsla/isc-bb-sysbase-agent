# Datos de Prueba — Sistema Bancario COBOL

## Escenario General

Banco Nacional, S.A. con datos simulados para un banco de tamano mediano.

### Dimensiones

| Entidad              | Cantidad | Descripcion                           |
|----------------------|----------|---------------------------------------|
| Sucursales (BRANCH)  | 10       | S001 a S010, 5 regiones               |
| Clientes (CUSTOMER)  | 150      | 120 PF + 25 PM + 5 GO                |
| Cuentas (ACCOUNT)    | 150      | 80 CH + 40 AH + 20 NO + 10 IN        |
| Transacciones (TRANLOG)| 500    | Depositos, retiros, transferencias    |
| Prestamos (LOANMAST) | 50       | 25 PL + 10 HI + 10 AU + 5 CO         |
| Tarjetas (CARD)      | 80       | 50 DB + 25 CR + 5 CO                 |
| Relaciones (ACCTXREF)| 200      | Cliente-cuenta con roles              |
| Usuarios (USERPROF)  | 20       | 2 ADM + 3 GER + 5 CAJ + 5 OFI + 5 CON|
| Chequeras (CHQBOOK)  | 80       | Asociadas a cuentas tipo CH           |
| Fondo de Caja (TELLEREC)| 5     | Cajeros activos                       |

---

## Datos por Entidad

### 1. Sucursales (BRANCH)

| Codigo | Nombre              | Ciudad         | Region | Gerente  |
|--------|---------------------|----------------|--------|----------|
| S001   | CASA MATRIZ         | CIUDAD DE MEXICO | CC    | ADM0001  |
| S002   | POLANCO              | CIUDAD DE MEXICO | CC    | GER0001  |
| S003   | SANTA FE             | CIUDAD DE MEXICO | CC    | GER0001  |
| S004   | MONTERREY CENTRO     | MONTERREY       | NE     | GER0002  |
| S005   | GUADALAJARA CENTRO   | GUADALAJARA     | NO     | GER0003  |
| S006   | GUADALAJARA ANDARES  | GUADALAJARA     | NO     | GER0003  |
| S007   | PUEBLA CENTRO        | PUEBLA          | CE     | GER0004  |
| S008   | MERIDA CENTRO        | MERIDA          | SE     | GER0004  |
| S009   | LEON CENTRO          | LEON            | CE     | GER0005  |
| S010   | QUERETARO CENTRO     | QUERETARO       | CE     | GER0005  |

### 2. Clientes (CUSTOMER) — Muestra Representativa

| CUS-ID      | Tipo | Nombre                | RFC           | Segmento | Riesgo | Status |
|-------------|------|-----------------------|---------------|----------|--------|--------|
| CUS0000001  | PF   | JUAN PEREZ LOPEZ      | PELJ850101XXX | 02       | A      | A      |
| CUS0000002  | PF   | MARIA GARCIA HERNANDEZ| GAHM900205XXX | 02       | A      | A      |
| CUS0000003  | PF   | CARLOS LOPEZ MARTINEZ | LOMC750310XXX | 03       | B      | A      |
| CUS0000004  | PM   | EMPRESA XYZ SA DE CV  | XYZ850101XXX  | 05       | A      | A      |
| CUS0000005  | PF   | ANA TORRES RAMIREZ    | TORA650415XXX | 01       | C      | A      |
| CUS0000006  | PF   | PEDRO SANCHEZ GOMEZ   | SAGP550620XXX | 04       | A      | A      |
| CUS0000007  | PM   | COMERCIAL ABC SAPI    | COM901201XXX  | 05       | B      | A      |
| CUS0000008  | GO   | GOBIERNO ESTATAL      | GES000101XXX  | 05       | A      | A      |
| CUS0000009  | PF   | LUISA FERNANDA DIAZ   | DIAL800930XXX | 03       | A      | A      |
| CUS0000010  | PF   | ROBERTO CASTILLO NAVARRO | CANR700115XXX | 01    | B      | I      |

... 140 clientes adicionales con distribucion similar.

### 3. Cuentas (ACCOUNT) — Muestra Representativa

| ACT-NBR     | Tipo | Moneda | Balance   | Status | Sucursal | Cliente    |
|-------------|------|--------|-----------|--------|----------|------------|
| ACT0000001  | CH   | MXN    | 12500.50  | A      | S001     | CUS0000001 |
| ACT0000002  | AH   | MXN    | 45000.00  | A      | S001     | CUS0000002 |
| ACT0000003  | CH   | USD    | 5000.00   | A      | S002     | CUS0000003 |
| ACT0000004  | NO   | MXN    | 15000.00  | A      | S001     | CUS0000001 |
| ACT0000005  | CH   | MXN    | 0.00      | C      | S003     | CUS0000005 |
| ACT0000006  | IN   | MXN    | 500000.00 | A      | S002     | CUS0000006 |
| ACT0000007  | AH   | MXN    | 2500.00   | D      | S004     | CUS0000007 |
| ACT0000008  | CH   | MXN    | 100000.00 | A      | S001     | CUS0000008 |
| ACT0000009  | CH   | MXN    | 800.00    | F      | S005     | CUS0000009 |
| ACT0000010  | AH   | USD    | 15000.00  | A      | S002     | CUS0000010 |

... 140 cuentas adicionales.

### 4. Transacciones (TRANLOG) — Muestra

| TRN-SEQ   | Tipo | Cuenta    | Monto     | Fecha     | Status |
|-----------|------|-----------|-----------|-----------|--------|
| TRN0000001| APE  | ACT0000001| 5000.00   | 20260102  | C      |
| TRN0000002| DEP  | ACT0000001| 2500.00   | 20260103  | C      |
| TRN0000003| DEP  | ACT0000002| 10000.00  | 20260103  | C      |
| TRN0000004| RET  | ACT0000001| 1000.00   | 20260104  | C      |
| TRN0000005| TRF  | ACT0000001| 2000.00   | 20260105  | C      |
| TRN0000006| DEP  | ACT0000003| 500.00    | 20260106  | C      |
| TRN0000007| INT  | ACT0000002| 150.25    | 20260107  | C      |
| TRN0000008| COM  | ACT0000001| 25.00     | 20260107  | C      |
| TRN0000009| CHQ  | ACT0000001| 3500.00   | 20260108  | P      |
| TRN0000010| RET  | ACT0000004| 3000.00   | 20260109  | C      |

... 490 transacciones adicionales.

### 5. Prestamos (LOANMAST) — Muestra

| LON-NBR     | Cliente    | Tipo | Monto     | Balance   | Plazo | Status |
|-------------|------------|------|-----------|-----------|-------|--------|
| LON0000001  | CUS0000001 | PL   | 100000.00 | 85000.00  | 12    | A      |
| LON0000002  | CUS0000003 | HI   | 1500000.00| 1450000.00| 240   | A      |
| LON0000003  | CUS0000005 | PL   | 50000.00  | 50000.00  | 6     | A      |
| LON0000004  | CUS0000002 | AU   | 200000.00 | 150000.00 | 36    | A      |
| LON0000005  | CUS0000010 | PL   | 30000.00  | 30000.00  | 12    | C      |
| LON0000006  | CUS0000004 | CO   | 500000.00 | 350000.00 | 60    | A      |
| LON0000007  | CUS0000007 | PL   | 15000.00  | 12000.00  | 6     | A      |
| LON0000008  | CUS0000006 | HI   | 2000000.00| 1980000.00| 360   | A      |

... 42 prestamos adicionales.

### 6. Tarjetas (CARD) — Muestra

| CRD-NBR            | Cliente    | Tipo | Producto | Limite    | Status | Expira  |
|--------------------|------------|------|----------|-----------|--------|---------|
| 4000010000000001   | CUS0000001 | DB   | CLAS     | 20000.00  | A      | 202812  |
| 4000010000000002   | CUS0000002 | DB   | CLAS     | 15000.00  | A      | 202811  |
| 4000010000000003   | CUS0000003 | CR   | GOLD     | 50000.00  | A      | 202810  |
| 4000010000000004   | CUS0000004 | CO   | PLAT     | 200000.00 | A      | 202809  |
| 4000010000000005   | CUS0000001 | CR   | CLAS     | 25000.00  | A      | 202808  |
| 4000010000000006   | CUS0000005 | DB   | CLAS     | 10000.00  | B      | 202707  |
| 4000010000000007   | CUS0000006 | CR   | BLCK     | 500000.00 | A      | 202806  |
| 4000010000000008   | CUS0000009 | DB   | GOLD     | 50000.00  | E      | 202401  |
| 4000010000000009   | CUS0000003 | DB   | CLAS     | 10000.00  | S      | 202805  |
| 4000010000000010   | CUS0000010 | CR   | GOLD     | 30000.00  | A      | 202804  |

... 70 tarjetas adicionales.

### 7. Usuarios (USERPROF)

| USR-ID   | Nombre              | Rol  | Sucursal | Status |
|----------|---------------------|------|----------|--------|
| ADM0001  | ADMIN SISTEMAS      | ADM  | S001     | A      |
| ADM0002  | SEGURIDAD INFORMATICA| ADM | S001     | A      |
| GER0001  | GERENTE MATRIZ      | GER  | S001     | A      |
| GER0002  | GERENTE MONTERREY   | GER  | S004     | A      |
| GER0003  | GERENTE GUADALAJARA | GER  | S005     | A      |
| GER0004  | GERENTE PUEBLA      | GER  | S007     | A      |
| GER0005  | GERENTE LEON        | GER  | S009     | A      |
| CAJ0001  | CAJERO MATRIZ 1     | CAJ  | S001     | A      |
| CAJ0002  | CAJERO MATRIZ 2     | CAJ  | S001     | A      |
| CAJ0003  | CAJERO POLANCO      | CAJ  | S002     | A      |
| CAJ0004  | CAJERO MONTERREY    | CAJ  | S004     | A      |
| CAJ0005  | CAJERO GUADALAJARA  | CAJ  | S005     | A      |
| OFI0001  | OFICIAL CREDITO 1   | OFI  | S001     | A      |
| OFI0002  | OFICIAL CREDITO 2   | OFI  | S002     | A      |
| OFI0003  | OFICIAL CREDITO 3   | OFI  | S004     | A      |
| OFI0004  | OFICIAL CREDITO 4   | OFI  | S005     | A      |
| OFI0005  | OFICIAL CREDITO 5   | OFI  | S007     | A      |
| CON0001  | CONSULTA 1          | CON  | S001     | A      |
| CON0002  | CONSULTA 2          | CON  | S002     | A      |
| CON0003  | CONSULTA 3          | CON  | S008     | I      |

---

## Consultas de Verificacion de Integridad

Las siguientes consultas SQL (simuladas) verifican que los datos de prueba sean consistentes.

### V-01: Total de Depositos vs Suma de Saldos

```sql
SELECT SUM(ACT-BALANCE) AS TOTAL_SALDOS
  FROM ACCOUNT
 WHERE ACT-STATUS = 'A';
```

```sql
SELECT SUM(TRN-AMOUNT) AS TOTAL_DEPOSITOS
  FROM TRANLOG
 WHERE TRN-TYPE = 'DEP'
   AND TRN-STATUS = 'C';
```

**Regla**: SUM(ACT-BALANCE) ≈ SUM(DEP) - SUM(RET) + SUM(INT) - SUM(COM)

### V-02: Relaciones Cliente-Cuenta

```sql
SELECT COUNT(DISTINCT AXR-CUSTOMER-ID) AS CLIENTES_CON_CUENTAS
  FROM ACCTXREF
 WHERE AXR-STATUS = 'A'
   AND AXR-ROL = 'TI';
```

**Regla**: Cada cuenta activa debe tener al menos un titular.

### V-03: Integridad Prestamos

```sql
SELECT COUNT(*) AS PRESTAMOS_ACTIVOS
  FROM LOANMAST
 WHERE LON-STATUS = 'A';

SELECT SUM(LON-BALANCE) AS SALDO_TOTAL_PRESTAMOS
  FROM LOANMAST
 WHERE LON-STATUS = 'A';
```

**Regla**: LON-BALANCE debe ser <= LON-AMOUNT-DISBURSED.

### V-04: Balance de Caja por Cajero

```sql
SELECT TLR-ID, TLR-FONDO-INICIAL, TLR-TOTAL-DEPOSITOS,
       TLR-TOTAL-RETIROS, TLR-FONDO-ACTUAL
  FROM TELLEREC
 WHERE TLR-STATUS = 'O';
```

**Regla**: TLR-FONDO-ACTUAL = TLR-FONDO-INICIAL + TLR-TOTAL-DEPOSITOS - TLR-TOTAL-RETIROS ± TLR-DIFERENCIA

### V-05: Limites de Tarjeta

```sql
SELECT CRD-NBR, CRD-LIMIT-CASH, CRD-LIMIT-PURCHASE, CRD-BALANCE-CURRENT,
       CRD-BALANCE-AVAILABLE
  FROM CARD
 WHERE CRD-STATUS = 'A';
```

**Regla**: CRD-BALANCE-AVAILABLE = CRD-LIMIT-PURCHASE - CRD-BALANCE-CURRENT
**Regla**: CRD-LIMIT-CASH <= CRD-LIMIT-PURCHASE * 0.50

### V-06: Consistencia de Fechas

```sql
SELECT ACT-NBR, ACT-DATE-OPEN, ACT-DATE-LAST-ACTIVITY
  FROM ACCOUNT
 WHERE ACT-STATUS = 'A';
```

**Regla**: ACT-DATE-OPEN <= ACT-DATE-LAST-ACTIVITY <= TODAY

### V-07: Transacciones por Cuenta

```sql
SELECT TRN-ACCOUNT-NBR, COUNT(*) AS TXN_COUNT,
       SUM(TRN-AMOUNT) AS TXN_TOTAL
  FROM TRANLOG
 WHERE TRN-STATUS = 'C'
 GROUP BY TRN-ACCOUNT-NBR;
```

**Regla**: Toda transaccion debe tener TRN-ACCOUNT-NBR existente en ACCOUNT.

### V-08: Scoring de Prestamos

```sql
SELECT LAP-APPL-ID, LAP-SCORE, LAP-STATUS
  FROM LOANAPPL
 WHERE LAP-STATUS IN ('A', 'R', 'Z');
```

**Regla**: LAP-SCORE >= LAP-SCORE-APROBACION para prestamos aprobados (status 'A').

### V-09: Saldos Contables (GL)

```sql
SELECT GL-TYPE, SUM(GL-BALANCE-CURRENT) AS TOTAL
  FROM GLMASTER
 WHERE GL-STATUS = 'A'
 GROUP BY GL-TYPE;
```

**Regla**: SUM(Activo) = SUM(Pasivo) + SUM(Capital) (ecuacion contable)

### V-10: Auditoria de Cambios

```sql
SELECT AUD-DATE, AUD-USUARIO, AUD-EVENTO, AUD-ENTITY-TYPE, COUNT(*) AS CAMBIOS
  FROM AUDITLOG
 GROUP BY AUD-DATE, AUD-USUARIO, AUD-EVENTO, AUD-ENTITY-TYPE
 ORDER BY AUD-DATE DESC;
```

**Regla**: Todo cambio en datos maestros debe tener registro AUDITLOG correspondiente.

---

## Archivos de Datos

Los datos se almacenan en archivos indexados (VSAM) en el directorio `src/data/`:

| Archivo         | Nombre Fisico          | Registros Estimados |
|-----------------|------------------------|---------------------|
| CUSTOMER.DAT    | src/data/CUSTOMER.DAT  | 150                 |
| ACCOUNT.DAT     | src/data/ACCOUNT.DAT   | 150                 |
| TRANLOG.DAT     | src/data/TRANLOG.DAT   | 500                 |
| CARD.DAT        | src/data/CARD.DAT      | 80                  |
| LOANMAST.DAT    | src/data/LOANMAST.DAT  | 50                  |
| LOANAPPL.DAT    | src/data/LOANAPPL.DAT  | 10                  |
| USERPROF.DAT    | src/data/USERPROF.DAT  | 20                  |
| SECURITY.DAT    | src/data/SECURITY.DAT  | 200                 |
| DEPMAST.DAT     | src/data/DEPMAST.DAT   | 30                  |
| TIMEDEP.DAT     | src/data/TIMEDEP.DAT   | 20                  |
| GLMASTER.DAT    | src/data/GLMASTER.DAT  | 100                 |
| AUDITLOG.DAT    | src/data/AUDITLOG.DAT  | 300                 |
| BATCHCTL.DAT    | src/data/BATCHCTL.DAT  | 365                 |
| RATEFILE.DAT    | src/data/RATEFILE.DAT  | 25                  |
| PARAMSTR.DAT    | src/data/PARAMSTR.DAT  | 50                  |
| FEESCHED.DAT    | src/data/FEESCHED.DAT  | 15                  |
| CHQBOOK.DAT     | src/data/CHQBOOK.DAT   | 80                  |
| ACCTXREF.DAT    | src/data/ACCTXREF.DAT  | 200                 |
| TELLEREC.DAT    | src/data/TELLEREC.DAT  | 5                   |
| BRANCH.DAT      | src/data/BRANCH.DAT    | 10                  |
| CURRENCY.DAT    | src/data/CURRENCY.DAT  | 5                   |
| MESSAGES.DAT    | src/data/MESSAGES.DAT  | 30                  |
