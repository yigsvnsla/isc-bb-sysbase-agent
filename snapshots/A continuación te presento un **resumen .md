A continuación te presento un **resumen sobre la estandarización Sybase y SQL Server** basado en la documentación encontrada:

---

## 📘 Resumen: Estandarización Sybase y SQL Server

### Fuente
Documento: **"Estandarización-de-formatos-BD-v5.3.pdf"** (Norma ARQT-EST-001 - Arquitectura y Soporte de TI, Versión 2.0)

---

### 1. Normas Generales para los objetos de la base de datos

Se aplican reglas comunes tanto para Sybase como para SQL Server:

| Regla | Descripción |
|-------|-------------|
| **Minúsculas y singular** | Todos los nombres de objetos deben estar en minúsculas y en singular. |
| **Nombres cortos y descriptivos** | Se debe buscar un equilibrio entre brevedad y claridad. |
| **Separador con guion bajo** | Para mejorar la legibilidad se usa el carácter `_` (underscore). |
| **Sin espacios ni caracteres especiales** | No se permiten espacios, `$`, `#` ni otros caracteres con significado especial en lenguajes de desarrollo o sistemas operativos. |

---

### 2. Normas para nombres de Bases de Datos

| Regla | Descripción |
|-------|-------------|
| **Longitud máxima** | 25 caracteres. |
| **Singular** | El nombre debe estar en singular. |
| **Prefijo `cob_`** | Si la base de datos es alimentada por aplicaciones **COBIS**. |
| **Prefijo `db_`** | Si pertenece a aplicaciones **no COBIS**. |
| **Sufijo `_his`** | Si la base de datos almacena **información histórica**. |

#### Ejemplos:
| Base de Datos | Descripción |
|---------------|-------------|
| `cob_cuentas` | Aplicación COBIS |
| `cob_cuentas_his` | Histórico de aplicación COBIS |
| `db_sat_his` | Histórico de aplicación no COBIS |

---

### 3. Nota adicional sobre proveedores externos

Cuando se adquieran aplicaciones de proveedores externos (Ej: Facturación Electrónica, Evolution, etc.) que sean **paquetes cerrados**, se debe incluir en la negociación un **anexo técnico** donde el proveedor entregue la documentación relacionada al estándar de su base de datos, diccionario de datos, etc.

---

### 4. Contexto de aplicación

Estos estándares aplican a los motores de base de datos:
- ✅ **Sybase**
- ✅ **SQL Server**
- ✅ Oracle
- ✅ MySQL
- ✅ PostgreSQL

---

Si deseas profundizar en alguna sección específica o necesitas el detalle de otras normas (como tablas, columnas, índices, stored procedures, etc.), házmelo saber y puedo buscar más información en los documentos disponibles.