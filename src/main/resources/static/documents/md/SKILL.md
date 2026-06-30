---
name: bd-estandares-bancobolivariano
description: Estándares de desarrollo de Programación de Base de Datos del Banco Bolivariano (ARQT-EST-001, v5.3) para los motores Sybase, SQL Server y Oracle. Usar esta skill SIEMPRE que se vaya a nombrar, diseñar, crear o revisar objetos de base de datos (bases de datos, esquemas, tablas, tablas temporales, campos, constraints de PK/FK/Null/Not Null/Unique/Default/Check, índices, procedimientos almacenados, funciones, paquetes, triggers, vistas, secuencias, tablespaces, roles, variables o parámetros) para aplicaciones del Banco Bolivariano, así como al nombrar archivos físicos de procedimientos (.sp), programas SQR (.sqr) o scripts (.sql), al escribir cabeceras de comentarios de programas, al documentar referencias de cambio en código (REF #), o al escribir/revisar sentencias SQL/PL-SQL bajo estas convenciones. También usar al pedir el nemónico de una aplicación del banco, o al pedir "estándares de base de datos", "naming conventions de BD", "cómo se nombra una tabla/procedimiento/índice en Cobis/Cyberbank/Sybase/Oracle/SqlServer".
---

# Estándares de desarrollo de Programación de Base de Datos — Banco Bolivariano

Arquitectura Tecnológica — Documento ARQT-EST-001 — Versión 5.3 (30/11/2022), formato de Arquitectura Versión 2.0.

> ESTÁ PROHIBIDA LA IMPRESIÓN DE ESTE DOCUMENTO. UNA VEZ TERMINADA LA REVISIÓN DEL MISMO, EL DOCUMENTO WORD COPIADO EN SU MÁQUINA DEBE SER ELIMINADO. LA ÚNICA VERSIÓN VÁLIDA DISPONIBLE ES LA PUBLICADA EN EL SISTEMA DE GESTIÓN DOCUMENTAL.

Esta skill reproduce íntegramente la redacción y el set de instrucciones del estándar de programación de base de datos del Banco Bolivariano, para que Claude lo aplique al nombrar y diseñar objetos de base de datos, procedimientos, scripts y cabeceras de control de cambios.

## 1. Objetivo

El presente documento tiene por objeto describir los estándares, herramientas y metodologías que rigen los servicios y desarrollos de TI. Esta guía y todos sus anexos se encuentran publicados en el portal departamental de sistemas.

El responsable del contenido de este documento es el área de Arquitectura y Soporte de TI.

Cualquier sugerencia o duda, petición de reunión, reporte de incompatibilidad del documento con las directrices corporativas, o petición de adaptación a casos concretos de los estándares definidos en este documento deberá dirigirse a Subgerencia de Arquitectura y Soporte de TI.

El presente documento establece los entregables y uso común de herramientas, estando permitidos cuantos entregables y actividades adicionales se consideren oportunos desde la jefatura de cada proyecto o en las reuniones de definición con los Arquitectos designados para la revisión.

Documentar los estándares de programación de base de datos a ser utilizados en la construcción de aplicaciones en los motores de base de datos: **Sybase, SqlServer y Oracle**.

## 2. Alcance

Está dirigido al equipo responsable del área de desarrollo del Banco Bolivariano.

## 3. Condiciones generales

### Entornos

A continuación, se describen los motores de base de datos utilizados en la institución y las aplicaciones que los utilizan.

| Motor | Aplicaciones que acceden |
|---|---|
| Sybase | Cobis - Core bancario |
| Oracle | Cyberbank y Tarifario |
| SqlServer | Aplicaciones como VDT, MonitorPlus, entre otros |

**Cómo usar esta condición**: antes de aplicar cualquier norma de nomenclatura, identifica primero qué motor corresponde a la aplicación sobre la que se trabaja (Cobis → Sybase; Cyberbank/Tarifario → Oracle; VDT/MonitorPlus y similares → SqlServer), y luego dirígete al archivo de referencia correspondiente:

- Sybase y SQL Server comparten el mismo estándar → ver `references/sybase-sqlserver.md`
- Oracle tiene su propio estándar → ver `references/oracle.md`
- Plantillas de cabecera de programas (Anexo 1, 2, 3) y catálogo de nemónicos de aplicación (Anexo 4) → ver `references/anexos.md`
- Restricciones de diseño y control de cambios del propio documento → ver `references/control-cambios.md`

## 4 y 5. Estandarización por motor

Este documento estandariza tres motores de base de datos:

1. **Sybase y SQL Server** (sección 4 del documento original) — comparten exactamente las mismas normas. Léase íntegro en `references/sybase-sqlserver.md` antes de nombrar cualquier objeto Sybase o SqlServer. Cubre: normas generales de objetos, bases de datos, nemónico de aplicación, tablas, tablas temporales, tablas fijas de uso temporal (BATCH), campos, constraints (PK, FK, Null, Not Null, Unique, Default, Check), índices, procedimientos almacenados, parámetros, funciones de usuario, variables, vistas, programas SQR, y nombre físico de programas (procedimientos `.sp`, SQR, scripts `.sql`, referencia de cambio en código adicionado).

2. **Oracle** (sección 5 del documento original) — normas propias y más extensas (roles, tablespaces, esquemas, secuencias, paquetes, disparadores/triggers, normas de escritura de sentencias SQL, archivos .SQL para pases y órdenes de proceso). Léase íntegro en `references/oracle.md` antes de nombrar o escribir cualquier objeto/sentencia Oracle.

**Regla general aplicable a ambos** (repetida en ambos motores, válida siempre): los nombres de los objetos deben estar en minúsculas y en singular, deben ser cortos y descriptivos, se debe usar el carácter de subrayado ("_") para legibilidad, y no se permiten espacios ni caracteres especiales como "$", "#" u otros con sentido propio en bases de datos, lenguajes o sistemas operativos.

## 6. Restricciones de diseño y control de cambios

Ver `references/control-cambios.md` para:
- a. Bases de datos (restricciones de diseño)
- Tabla de control de cambios del documento (versiones 1 a 5)

## Cómo aplicar esta skill en la práctica

1. Determina el **motor de base de datos** (Sybase/SqlServer u Oracle) según la aplicación (tabla de Entornos arriba), o pregunta al usuario si no es evidente.
2. Carga el archivo de referencia correspondiente (`references/sybase-sqlserver.md` o `references/oracle.md`) y aplica la norma exacta del tipo de objeto solicitado (base de datos, tabla, campo, constraint, índice, procedimiento, función, vista, paquete, trigger, secuencia, tablespace, esquema, rol).
3. Si necesitas el **nemónico de la aplicación**, consúltalo en `references/anexos.md` (Anexo 4). Si la aplicación no está en el listado, indícalo explícitamente al usuario en lugar de inventar un nemónico.
4. Si vas a escribir o documentar la **cabecera de un programa** (procedimiento almacenado `.sp`, programa SQR `.sqr`, o script `.sql`), usa las plantillas exactas del Anexo 1, 2 o 3 en `references/anexos.md`, incluyendo las etiquetas obligatorias.
5. Si vas a documentar un **cambio de código** (adición, modificación o comentario de bloque/campo), usa exactamente la sintaxis de marcado `--<REF n` / `--REF n>` y `/*<REF n ... REF n>*/` descrita en `references/sybase-sqlserver.md` (sección "Referencia de cambio en el código adicionado").
6. Respeta siempre los límites de longitud máxima de caracteres indicados para cada tipo de objeto (son parte integral de la norma, no sugerencias).
7. No inventes excepciones a la norma. Si el caso del usuario no encaja claramente en una norma documentada, dilo explícitamente y sugiere dirigirse a la Subgerencia de Arquitectura y Soporte de TI, tal como indica el propio documento.
