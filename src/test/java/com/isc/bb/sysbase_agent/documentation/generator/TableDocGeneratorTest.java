package com.isc.bb.sysbase_agent.documentation.generator;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;

import com.isc.bb.sysbase_agent.db.SchemaObjects.ColumnDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ConstraintDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.IndexDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableInfo;
import com.isc.bb.sysbase_agent.documentation.model.DocumentType;

/**
 * TableDocGenerator es lógica pura (schema metadata -> Markdown), sin tests
 * previos pese a ser el generador más grande del paquete `documentation`.
 */
class TableDocGeneratorTest {

    private final TableDocGenerator generator = new TableDocGenerator();

    @Test
    void generate_populatesMetaAndFrontMatter() {
        var info = new TableInfo("bank", "customer",
                "CREATE TABLE bank.customer (...)",
                List.of(new ColumnDef(1, "cus_id", "varchar(20)", false, null)),
                List.of(), List.of(), List.of());

        var doc = generator.generate(info);

        assertThat(doc.meta().id()).isEqualTo("bank_customer");
        assertThat(doc.meta().title()).isEqualTo("customer");
        assertThat(doc.meta().type()).isEqualTo(DocumentType.TABLE);
        assertThat(doc.meta().category()).isEqualTo("tablas/bank");
        assertThat(doc.frontMatter()).containsEntry("schema", "bank").containsEntry("columns", 1);
    }

    @Test
    void generate_rendersColumnsTable_withNullableAndDefault() {
        var info = new TableInfo("bank", "customer", "DDL", List.of(
                new ColumnDef(1, "cus_id", "varchar(20)", false, null),
                new ColumnDef(2, "status", "char(1)", true, "'A'")),
                List.of(), List.of(), List.of());

        var md = generator.generate(info).markdown();

        assertThat(md).contains("| 1 | `cus_id` | varchar(20) | NO | — |");
        assertThat(md).contains("| 2 | `status` | char(1) | SI | `'A'` |");
    }

    @Test
    void generate_omitsConstraintsAndIndexSections_whenEmpty() {
        var info = new TableInfo("bank", "customer", "DDL",
                List.of(new ColumnDef(1, "cus_id", "varchar(20)", false, null)),
                List.of(), List.of(), List.of());

        var md = generator.generate(info).markdown();

        assertThat(md).doesNotContain("## Constraints").doesNotContain("## Índices");
    }

    @Test
    void generate_escapesPipesAndNewlinesInConstraintDefinition() {
        var info = new TableInfo("bank", "customer", "DDL",
                List.of(new ColumnDef(1, "cus_id", "varchar(20)", false, null)),
                List.of(),
                List.of(new ConstraintDef("chk_status", "CHECK", "status IN ('A'|'I')\nother")),
                List.of());

        var md = generator.generate(info).markdown();

        assertThat(md).contains("status IN ('A'\\|'I') other");
        assertThat(md).doesNotContain("'A'|'I')\nother");
    }

    @Test
    void generate_rendersIndexes_whenPresent() {
        var info = new TableInfo("bank", "customer", "DDL",
                List.of(new ColumnDef(1, "cus_id", "varchar(20)", false, null)),
                List.of(new IndexDef("idx_cus_id", List.of("cus_id"), "btree", true, null)),
                List.of(), List.of());

        var md = generator.generate(info).markdown();

        assertThat(md).contains("## Índices");
        assertThat(md).contains("| `idx_cus_id` | cus_id | btree | SI |");
    }

    @Test
    void generate_mermaidType_stripsSizeAndSpaces() {
        var info = new TableInfo("bank", "customer", "DDL",
                List.of(
                        new ColumnDef(1, "amount", "numeric(12, 2)", false, null),
                        new ColumnDef(2, "created_at", "timestamp with time zone", false, null),
                        new ColumnDef(3, "flag", "", true, null)),
                List.of(), List.of(), List.of());

        var md = generator.generate(info).markdown();

        assertThat(md).contains("numeric amount");
        assertThat(md).contains("timestamp_with_time_zone created_at");
        assertThat(md).contains("string flag");
    }
}
