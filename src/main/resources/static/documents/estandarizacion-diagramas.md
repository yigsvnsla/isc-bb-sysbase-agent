# Diagramas de Flujo - Estándares ARQT-EST-001

## Flujo de Desarrollo bajo Estándar

```mermaid
flowchart LR
    A[Requerimiento] --> B[Definir Nemónico Aplicación]
    B --> C[Diseñar Tablas]
    C --> D[Crear Constraints]
    D --> E[Crear Índices]
    E --> F[Desarrollar SPs]
    F --> G[Documentar Cabecera]
    G --> H[Revisión QA/DBA]
    H --> I{Pasa estándar?}
    I -->|Sí| J[Pase a Producción]
    I -->|No| C
```

## Nomenclatura de Tablas

```mermaid
flowchart LR
    A[Nemónico App] --> B["_"]
    B --> C[Tipo Tabla]
    C --> D["_"]
    D --> E[Descripción]
    E --> F[Ej: con_m_cuenta]
```

### Tipos Transaccionales

```mermaid
flowchart TD
    subgraph Transaccionales
        T1[m - Maestro]
        T2[r - Relacional]
        T3[t - Transacción]
        T4[c - Cabecera Factura]
        T5[d - Detalle Factura]
        T6[h - Histórico]
        T7[p - Parámetro/Catálogo]
        T8[s - Secuencial]
        T9[l - Log]
        T10[o - Paso BCP]
    end
```

### Tipos Analíticos

```mermaid
flowchart TD
    subgraph Analíticas
        A1[d - Dimensión]
        A2[h - Hecho]
        A3[r - Reporting]
        A4[o - Operaciones]
        A5[t - Transacciones]
        A6[e - Externas]
        A7[i - Internas CRM]
        A8[p - Plantilla]
    end
```

## Nomenclatura de Procedimientos Almacenados

```mermaid
flowchart LR
    A["pa_"] --> B[Nemónico App]
    B --> C["_"]
    C --> D[Tipo Operación]
    D --> E["_"]
    E --> F[Descripción]
    F --> G[Ej: pa_con_ccliente_gen]
```

### Tipos de Operación

```mermaid
flowchart TD
    subgraph "SP por especialidad (sin opciones)"
        OP1[i - Ingreso INSERT]
        OP2[a - Actualización UPDATE]
        OP3[e - Eliminación DELETE]
        OP4[c - Consulta específica]
        OP5[g - Consulta general]
        OP6[p - Proceso cálculo]
        OP7[t - Proceso transaccional OLTP]
        OP8[b - Proceso batch]
        OP9[d - Depuración]
    end
```

## Convención de Parámetros

```mermaid
flowchart LR
    subgraph Sybase
        P1["@e_variable - Entrada"]
        P2["@s_variable - Salida"]
    end
    subgraph Oracle
        P3["e_variable - Entrada"]
        P4["s_variable - Salida"]
    end
```

## Convención de Variables

```mermaid
flowchart LR
    subgraph Sybase
        V1["@v_variable - Trabajo"]
    end
    subgraph Oracle
        V2["v_variable - Trabajo"]
    end
```

## Constraints Naming

```mermaid
flowchart TD
    PK["pk_nombre_tabla<br/>Ej: pk_con_m_cuenta"]
    FK["fk_origen_ref<br/>Ej: fk_tcabfact_mclient"]
    UQ["uq_tabla_campo<br/>Ej: uq_mcliente_codiprov"]
    CK["ck_tabla_campo<br/>Ej: ck_mcliente_estado"]
    NN["nn_tabla_campo<br/>Ej: nn_mcliente_codigo"]
    DF["df_tabla_campo<br/>Ej: df_mcliente_fecha"]
```

## Estructura Cabecera SP (ANEXO 1)

```mermaid
flowchart TD
    H1["Archivo: nombre_físico"]
    H2["Motor de Base: SYBASE/SQLSERVER/ORACLE"]
    H3["Base de datos: nombre BD"]
    H4["Servidor: nombre servidor"]
    H5["Aplicación: nombre aplicación"]
    H6["Store procedure: nombre SP"]
    H7["Procesamiento: OLTP/BATCH/BATCH ESPECIAL"]
    H8["Ult.ControlTarea: código tarea"]
    H9["Ult.Referencia: REF #"]
    H10["PROPOSITO: descripción"]
```

## Referencia de Cambios

```mermaid
flowchart LR
    A[Código original] --> B[Modificación]
    B --> C["--<REF #<br/>código nuevo<br/>--REF #>"]
    C --> D[Revisión]
```

## Ciclo de Vida Tablas Temporales

```mermaid
flowchart LR
    A["Verificar existencia<br/>IF OBJECT_ID('#tmp') IS NOT NULL<br/>DROP TABLE #tmp"] --> B["Crear #tmp con SELECT INTO<br/>o CREATE TABLE #tmp"]
    B --> C["Operaciones DML contra #tmp"]
    C --> D["DROP TABLE #tmp<br/>al finalizar"]
```

## Flujo de Validación Estática con SonarQube

```mermaid
flowchart TD
    A[SP Compilado] --> B[Cabecera completa?]
    B -->|No| C[Rechazar]
    B -->|Sí| D[Nombre cumple pa_?]
    D -->|No| C
    D -->|Sí| E[Parámetros @e_/@s_?]
    E -->|No| C
    E -->|Sí| F[Variables @v_?]
    F -->|No| C
    F -->|Sí| G[Transacciones OK?]
    G -->|No| C
    G -->|Sí| H[@@error controlado?]
    H -->|No| C
    H -->|Sí| I[REF # marcado?]
    I -->|No| C
    I -->|Sí| J[✅ APROBADO]
```

## Orquestación de Componentes

```mermaid
flowchart TD
    subgraph "Capa Física"
        DB[(Base de Datos)]
        SP[Procedimientos Almacenados]
    end
    subgraph "Capa Lógica"
        TB[Tablas con constraints]
        IX[Índices]
        VW[Vistas]
        FN[Funciones]
        PK[Paquetes Oracle]
    end
    subgraph "Capa Control"
        SQ[SonarQube]
        QA[Revisión DBA]
        ST[Estándar ARQT-EST-001]
    end
    TB --> IX
    IX --> SP
    SP --> VW
    VW --> FN
    FN --> PK
    SP --> SQ
    SQ --> QA
    QA --> ST
    ST -->|Feedback| TB
```
