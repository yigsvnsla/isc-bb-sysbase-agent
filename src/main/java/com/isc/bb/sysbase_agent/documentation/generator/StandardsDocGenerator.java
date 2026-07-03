package com.isc.bb.sysbase_agent.documentation.generator;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.model.DocumentMeta;
import com.isc.bb.sysbase_agent.documentation.model.DocumentType;

@Component
public class StandardsDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(StandardsDocGenerator.class);

    private final Path docsPath;

    public StandardsDocGenerator(@Value("${app.knowledge-base.pdf-dir:classpath:static/documents}") String basePath) {
        this.docsPath = Path.of(basePath.replaceFirst("^classpath:", ""));
    }

    public DocumentContent generate(String engine) {
        var engineName = switch (engine.toLowerCase()) {
            case "sybase" -> "Sybase ASE / SQL Server";
            case "mssql" -> "Microsoft SQL Server";
            case "oracle" -> "Oracle Database";
            case "postgresql" -> "PostgreSQL";
            default -> engine;
        };

        var slug = "ARQT-EST-001";
        var meta = new DocumentMeta(
                slug,
                "Estándares ARQT-EST-001 v5.3",
                "estandares",
                "estandares/index",
                DocumentType.STANDARDS,
                List.of("estandares", engine, "ARQT-EST-001"),
                engine,
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "sidebar_position", 1,
                "engine", engine,
                "version", "5.3"
        );

        var md = new StringBuilder();
        md.append("# Estándares de Programación de Base de Datos\n\n");
        md.append("## ARQT-EST-001 — Versión 5.3\n\n");
        md.append("**Motor**: ").append(engineName).append("\n\n");

        md.append("Estándares aplicables del Banco Bolivariano para el motor ")
                .append(engineName).append(".\n\n");

        md.append("## Referencias\n\n");
        md.append("Los estándares completos están documentados en los siguientes archivos:\n\n");

        var refFiles = List.of(
                "sybase-sqlserver.md",
                "oracle.md",
                "anexos.md",
                "control-cambios.md"
        );

        for (var ref : refFiles) {
            var refPath = docsPath.resolve("md").resolve(ref);
            if (Files.exists(refPath)) {
                md.append("- `").append(ref).append("` — disponible en documents/md/\n");
            }
        }
        md.append("\n");

        md.append("## Naming conventions\n\n");
        md.append("### Procedimientos almacenados\n");
        md.append("- Prefijo: `pa_`\n");
        md.append("- Formato: `pa_{nemónico}_{tipo}_{descripción}`\n");
        md.append("- Máx. 30 caracteres\n\n");

        md.append("### Parámetros\n");
        md.append("- Entrada: `e_` (ej. `e_cuenta`)\n");
        md.append("- Salida: `s_` (ej. `s_mensaje`)\n");
        md.append("- Máx. 25 caracteres\n\n");

        md.append("### Variables\n");
        md.append("- Prefijo: `v_` (ej. `v_oficina`)\n");
        md.append("- Máx. 25 caracteres\n\n");

        md.append("### Tablas\n");
        md.append("- Formato: `{nemónico}_{tipo}_{descripción}`\n");
        md.append("- Máx. 25 caracteres\n");
        md.append("- Tipos: `m` (maestro), `t` (transacción), `h` (histórico), `p` (parámetro), etc.\n\n");

        md.append("## Plantilla de cabecera\n\n");
        md.append("```sql\n");
        md.append("/**********************************************************************/\n");
        md.append("/* Archivo:              nombre.sp                                   */\n");
        md.append("/* Motor de Base:        ").append(engineName.toUpperCase()).append("                                  */\n");
        md.append("/* Base de datos:        nome_db                                     */\n");
        md.append("/* Servidor:             nome_servidor                               */\n");
        md.append("/* Aplicacion:           nome_app                                    */\n");
        md.append("/* Stored procedure:     pa_con_tult_dia_habil_ant                   */\n");
        md.append("/* Procesamiento:        OLTP                                        */\n");
        md.append("/* Ult.ControlTarea:     J-PROYECTO-001                              */\n");
        md.append("/* Ult.Referencia:       REF 1                                       */\n");
        md.append("/* Disenado por:         Nombre Autor                                */\n");
        md.append("/* Fecha de escritura:   DD/Mmm/AAAA                                 */\n");
        md.append("/**********************************************************************/\n");
        md.append("/*                          IMPORTANTE                                */\n");
        md.append("/*  Este programa es parte de los paquetes bancarios propiedad de     */\n");
        md.append("/*  \"BANCO BOLIVARIANO C.A.\"                                          */\n");
        md.append("/*  Su uso no autorizado queda expresamente prohibido asi como        */\n");
        md.append("/*  cualquier alteracion o agregado hecho por alguno de sus           */\n");
        md.append("/*  usuarios sin el debido consentimiento por escrito de la           */\n");
        md.append("/*  Presidencia Ejecutiva de BANCO BOLIVARIANO o su representante     */\n");
        md.append("/**********************************************************************/\n");
        md.append("/* PROPOSITO:                                                         */\n");
        md.append("/*    Descripcion del proposito del programa                          */\n");
        md.append("/**********************************************************************/\n");
        md.append("/* REF   FECHA          AUTOR                  TAREA                  */\n");
        md.append("/*  1    DD/Mmm/AAAA    Nombre Autor           PROYECTO-001           */\n");
        md.append("/*       Emision inicial                                              */\n");
        md.append("/**********************************************************************/\n");
        md.append("```\n\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }
}
