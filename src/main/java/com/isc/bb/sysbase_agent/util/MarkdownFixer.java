package com.isc.bb.sysbase_agent.util;

import java.util.regex.Pattern;

public final class MarkdownFixer {

    private static final Pattern HEADER_SPACE = Pattern.compile("(?m)^(#{1,6})(\\w)");

    private static final Pattern MERMAID_TYPO = Pattern.compile(
            "(?im)^(`{3,})mermai d$");
    private static final Pattern MERMAID_TYPO2 = Pattern.compile(
            "(?im)^(`{3,})mermaid*$");

    private static final Pattern MERMAID_MISSING_NEWLINE = Pattern.compile(
            "(?im)^(```)mermaid(flowchart|graph|sequenceDiagram|classDiagram|stateDiagram|erDiagram|journey|gantt|pie|requirementDiagram)(.*)$");

    private MarkdownFixer() {}

    public static String fix(String content) {
        if (content == null || content.isBlank()) return content;
        var step1 = HEADER_SPACE.matcher(content).replaceAll("$1 $2");
        var step2 = MERMAID_TYPO.matcher(step1).replaceAll("$1mermaid");
        var step3 = MERMAID_TYPO2.matcher(step2).replaceAll("$1mermaid");
        return MERMAID_MISSING_NEWLINE.matcher(step3).replaceAll("$1mermaid\n$2$3");
    }
}
