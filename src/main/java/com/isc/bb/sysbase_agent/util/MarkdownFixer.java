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

    private static final Pattern MERMAID_FENCE = Pattern.compile("^`{3,}mermaid.*$");

    private static final Pattern NODE_LABEL = Pattern.compile("(\\b\\w+\\s*)(\\[)([^\\]\"\\n]*)(\\])");
    private static final Pattern DIAMOND_LABEL = Pattern.compile("(\\b\\w+\\s*)(\\{)([^}\"\\n]*)(\\})");
    private static final Pattern EDGE_LABEL = Pattern.compile("(\\|)([^|\"\\n]*)(\\|)");

    private MarkdownFixer() {}

    public static String fix(String content) {
        if (content == null || content.isBlank()) return content;
        var step1 = HEADER_SPACE.matcher(content).replaceAll("$1 $2");
        var step2 = MERMAID_TYPO.matcher(step1).replaceAll("$1mermaid");
        var step3 = MERMAID_TYPO2.matcher(step2).replaceAll("$1mermaid");
        var step4 = MERMAID_MISSING_NEWLINE.matcher(step3).replaceAll("$1mermaid\n$2$3");
        return fixMermaidLabels(step4);
    }

    public static String fixMermaidLabels(String content) {
        if (content == null || content.isBlank()) return content;
        var lines = content.split("\n", -1);
        var sb = new StringBuilder(content.length() + 64);
        boolean inMermaid = false;
        for (var line : lines) {
            if (line.startsWith("```")) {
                inMermaid = MERMAID_FENCE.matcher(line).matches();
                sb.append(line).append('\n');
                continue;
            }
            sb.append(inMermaid ? fixLabelLine(line) : line).append('\n');
        }
        var result = sb.toString();
        if (!content.endsWith("\n") && result.endsWith("\n")) {
            return result.substring(0, result.length() - 1);
        }
        return result;
    }

    private static String fixLabelLine(String line) {
        var withNodes = NODE_LABEL.matcher(line).replaceAll(MarkdownFixer::quoteLabel);
        var withDiamonds = DIAMOND_LABEL.matcher(withNodes).replaceAll(MarkdownFixer::quoteLabel);
        return EDGE_LABEL.matcher(withDiamonds).replaceAll(MarkdownFixer::quoteEdgeLabel);
    }

    private static String quoteLabel(java.util.regex.MatchResult m) {
        var quoted = quoteIfNeeded(m.group(3));
        if (quoted == null) return m.group();
        return m.group(1) + m.group(2) + quoted + m.group(4);
    }

    private static String quoteEdgeLabel(java.util.regex.MatchResult m) {
        var quoted = quoteIfNeeded(m.group(2));
        if (quoted == null) return m.group();
        return m.group(1) + quoted + m.group(3);
    }

    private static String quoteIfNeeded(String label) {
        if (label == null || label.isBlank()) return null;
        if (label.indexOf('"') >= 0) return null;
        for (int i = 0; i < label.length(); i++) {
            char c = label.charAt(i);
            if (c == '(' || c == ')' || c == '{' || c == '}' || c == '|') {
                return "\"" + label + "\"";
            }
        }
        return null;
    }
}
