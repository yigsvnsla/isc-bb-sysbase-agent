---
sidebar_position: 1
title: Sysbase Agent
slug: /intro
---

# Sysbase Agent — Documentación Técnica

Agente de inteligencia artificial para migración de stored procedures Sybase ASE a PostgreSQL, estandarización de base de datos y generación de documentación técnica del Banco Bolivariano.

## Capacidades

| Funcionalidad | Descripción |
|---------------|-------------|
| Análisis de SQL | Detección de dialecto, estructura, tablas, naming conventions |
| Migración Sybase → PG | Conversión de sintaxis, parámetros, transacciones |
| Validación ARQT-EST-001 | Cumplimiento de estándares de programación de BD |
| Documentación automática | Generación de fichas técnicas de SPs y esquemas |
| Búsqueda semántica | RAG sobre documentación indexada con PGVector |

## Secciones

- **Procedimientos Almacenados** — Documentación individual de SPs migrados
- **Esquemas** — Catálogo de objetos por esquema de base de datos
- **Migraciones** — Reportes de migración Sybase ASE → PostgreSQL
- **Estándares** — Normas ARQT-EST-001 v5.3 para Sybase, SQL Server, Oracle
- **Diagramas** — Diagramas Mermaid de dependencias y flujos

## Tecnologías

- **Backend**: Spring Boot 4.1 + Java 26
- **AI**: DeepSeek LLM via OpenAI-compatible API
- **Vector Store**: PGVector (384d, HNSW)
- **Cache**: Redis
- **Documentación**: Docusaurus 3
- **Contenedores**: Podman + Docker Compose
