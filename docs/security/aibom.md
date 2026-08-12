# AIBOM — Inventario de IA (OWASP AIBOM)

## Modelos
| Componente | Versión | Origen | Proveedor | Licencia |
|---|---|---|---|---|
| deepseek-v4-flash | API (configurable) | DeepSeek API | DeepSeek | API comercial |
| deepseek-v4-pro | API (configurable) | DeepSeek API | DeepSeek | API comercial |
| all-MiniLM-L6-v2 | ONNX 1.20.0 | HuggingFace | sentence-transformers | Apache-2.0 |
| Clasificador (router) | deepseek-v4-flash | DeepSeek API | DeepSeek | API comercial |

## Datasets / ingesta
| Dataset | Fuente | Formato | Riesgo |
|---|---|---|---|
| Docs de BD (PDFs/MDs) | src/main/resources/static/documents | PDF/MD/SQL/TXT | Envenenamiento (R07) |
| Esquemas (pg_catalog) | PostgreSQL local | SQL | Sensibilidad (ver data-governance) |

## Runtime
| Componente | Versión |
|---|---|
| Spring Boot | 4.1.1-SNAPSHOT |
| Spring AI | 2.0.0 (BOM) |
| Java | 26 (Temurin) |
| PGVector | pgvector/pgvector:pg16 |
| Redis | redis:7-alpine |
| ONNX Runtime | onnxruntime 1.20.0 |

## Verificación
- SBOM Maven: TODO (añadir cyclonedx-maven-plugin en CI).
- Escaneo de imágenes: TODO (trivy).
- Hash de prompts activos: TODO (model-registry.md).
