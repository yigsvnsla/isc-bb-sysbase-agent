package com.isc.bb.sysbase_agent.util;

import static org.junit.jupiter.api.Assertions.*;

import org.junit.jupiter.api.Test;

class MarkdownFixerTest {

    @Test
    void nullIsNoop() {
        assertNull(MarkdownFixer.fix(null));
    }

    @Test
    void blankIsNoop() {
        assertEquals("", MarkdownFixer.fix(""));
        assertEquals("  ", MarkdownFixer.fix("  "));
    }

    @Test
    void headerSpace() {
        var got = MarkdownFixer.fix("##Título\n###Subtítulo");
        assertEquals("## Título\n### Subtítulo", got);
    }

    @Test
    void mermaidMissingNewlineFlowchart() {
        var got = MarkdownFixer.fix("```mermaidflowchart TD\nA[Inicio] --> B[Fin]\n```");
        assertEquals("```mermaid\nflowchart TD\nA[Inicio] --> B[Fin]\n```", got);
    }

    @Test
    void mermaidMissingNewlineGraph() {
        var got = MarkdownFixer.fix("```mermaidgraph LR\nA --> B\n```");
        assertEquals("```mermaid\ngraph LR\nA --> B\n```", got);
    }

    @Test
    void mermaidMissingNewlineSequence() {
        var got = MarkdownFixer.fix("```mermaidsequenceDiagram\nA->>B: Hello\n```");
        assertEquals("```mermaid\nsequenceDiagram\nA->>B: Hello\n```", got);
    }

    @Test
    void mermaidTypoMermai() {
        var got = MarkdownFixer.fix("```mermai\nflowchart TD\n```");
        assertEquals("```mermaid\nflowchart TD\n```", got);
    }

    @Test
    void mermaidTypoMermaidd() {
        var got = MarkdownFixer.fix("```mermaidd\nflowchart LR\n```");
        assertEquals("```mermaid\nflowchart LR\n```", got);
    }

    @Test
    void mermaidTypoSpaceBeforeD() {
        var got = MarkdownFixer.fix("```mermai d\nflowchart TD\n    A --> B\n```");
        assertEquals("```mermaid\nflowchart TD\n    A --> B\n```", got);
    }

    @Test
    void correctMermaidUnchanged() {
        var input = "```mermaid\nflowchart TD\n    A[Inicio] --> B[Fin]\n```";
        assertEquals(input, MarkdownFixer.fix(input));
    }

    @Test
    void sqlFenceUnchanged() {
        var input = "```sql\nSELECT * FROM foo\n```";
        assertEquals(input, MarkdownFixer.fix(input));
    }

    @Test
    void multipleFixesInOnePass() {
        var input = "##Diagrama:\n```mermai d\nflowchart TD\n    A --> B\n```";
        var expected = "## Diagrama:\n```mermaid\nflowchart TD\n    A --> B\n```";
        assertEquals(expected, MarkdownFixer.fix(input));
    }

    @Test
    void mixedContentPreserved() {
        var input = "## Título\n\n```sql\nSELECT 1\n```\n\n```mermai\nflowchart LR\n```";
        var expected = "## Título\n\n```sql\nSELECT 1\n```\n\n```mermaid\nflowchart LR\n```";
        assertEquals(expected, MarkdownFixer.fix(input));
    }

    @Test
    void nodeLabelWithParensIsQuoted() {
        var input = "```mermaid\nflowchart TD\n    A[cc_tran_servicio (hoy)<br>+ cc_tran_s] --> B[Fin]\n```";
        var expected = "```mermaid\nflowchart TD\n    A[\"cc_tran_servicio (hoy)<br>+ cc_tran_s\"] --> B[Fin]\n```";
        assertEquals(expected, MarkdownFixer.fix(input));
    }

    @Test
    void diamondAndEdgeLabelsWithParensAreQuoted() {
        var input = "```mermaid\nflowchart TD\n    C{existe (hoy)} -->|inserta (1)| D\n```";
        var expected = "```mermaid\nflowchart TD\n    C{\"existe (hoy)\"} -->|\"inserta (1)\"| D\n```";
        assertEquals(expected, MarkdownFixer.fix(input));
    }

    @Test
    void subgraphTitleWithParensIsQuoted() {
        var input = "```mermaid\nflowchart TD\n    subgraph SG[Grupo (hoy)]\n    A --> B\n    end\n```";
        var expected = "```mermaid\nflowchart TD\n    subgraph SG[\"Grupo (hoy)\"]\n    A --> B\n    end\n```";
        assertEquals(expected, MarkdownFixer.fix(input));
    }

    @Test
    void alreadyQuotedLabelUnchanged() {
        var input = "```mermaid\nflowchart TD\n    A[\"cc_tran_servicio (hoy)\"] --> B\n```";
        assertEquals(input, MarkdownFixer.fix(input));
    }

    @Test
    void labelWithoutSpecialCharsUnchanged() {
        var input = "```mermaid\nflowchart TD\n    A[foo + bar - baz] --> B[fin: ok]\n```";
        assertEquals(input, MarkdownFixer.fix(input));
    }

    @Test
    void labelsOutsideMermaidBlocksUntouched() {
        var input = "```sql\nSELECT a[foo (hoy)] FROM t\n```\n\nTexto suelto: A[foo (hoy)]\n```mermaid\nflowchart TD\n    A --> B\n```";
        var expected = "```sql\nSELECT a[foo (hoy)] FROM t\n```\n\nTexto suelto: A[foo (hoy)]\n```mermaid\nflowchart TD\n    A --> B\n```";
        assertEquals(expected, MarkdownFixer.fix(input));
    }
}
