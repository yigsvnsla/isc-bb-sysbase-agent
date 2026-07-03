package com.isc.bb.sysbase_agent.documentation.adapter;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.model.DocumentMeta;
import com.isc.bb.sysbase_agent.documentation.model.DocumentType;
import com.isc.bb.sysbase_agent.documentation.model.PublishResult;
import com.isc.bb.sysbase_agent.documentation.port.DocumentPublisher;

public class DocusaurusPublisher implements DocumentPublisher {

    private static final Logger log = LoggerFactory.getLogger(DocusaurusPublisher.class);

    private final Path docsPath;
    private final Path sitePath;

    public DocusaurusPublisher(String docsPath, String sitePath) {
        this.docsPath = Path.of(docsPath);
        this.sitePath = Path.of(sitePath);
    }

    @Override
    public PublishResult publish(DocumentContent content) {
        try {
            var filePath = resolvePath(content.meta());
            Files.createDirectories(filePath.getParent());

            var frontMatter = buildFrontMatter(content);
            var fullContent = frontMatter + "\n" + content.markdown();
            Files.writeString(filePath, fullContent, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

            log.info("Doc published: {}", filePath);
            return PublishResult.ok(content.meta().id(), filePath.toString());
        } catch (IOException e) {
            log.error("Error publishing doc: {}", content.meta().id(), e);
            return PublishResult.fail(content.meta().id(), e.getMessage());
        }
    }

    @Override
    public PublishResult update(String docId, DocumentContent content) {
        return publish(content);
    }

    @Override
    public boolean exists(String docId) {
        try {
            var files = Files.walk(docsPath);
            var found = files.anyMatch(f -> docToId(f).equals(docId));
            files.close();
            return found;
        } catch (IOException e) {
            return false;
        }
    }

    @Override
    public Optional<DocumentMeta> findById(String docId) {
        try (var files = Files.walk(docsPath)) {
            return files.filter(f -> docToId(f).equals(docId))
                    .findFirst()
                    .map(this::pathToMeta);
        } catch (IOException e) {
            return Optional.empty();
        }
    }

    @Override
    public List<DocumentMeta> listByCategory(String category) {
        var catPath = docsPath.resolve(category);
        if (!Files.isDirectory(catPath)) return List.of();

        try (var files = Files.walk(catPath)) {
            return files.filter(f -> f.toString().endsWith(".md") && !f.getFileName().toString().equals("index.md"))
                    .map(this::pathToMeta)
                    .toList();
        } catch (IOException e) {
            return List.of();
        }
    }

    @Override
    public PublishResult buildIndex() {
        try {
            ensureCategoryIndices();
            var categories = listCategories();
            var sidebarJs = generateSidebarJs(categories);
            var sidebarPath = sitePath.resolve("sidebars.js");
            Files.writeString(sidebarPath, sidebarJs, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);

            log.info("Sidebar regenerated: {} categories", categories.size());
            return PublishResult.ok("sidebar", sidebarPath.toString());
        } catch (IOException e) {
            log.error("Error building index", e);
            return PublishResult.fail("sidebar", e.getMessage());
        }
    }

    @Override
    public String adapterType() {
        return "docusaurus";
    }

    private Path resolvePath(DocumentMeta meta) {
        return docsPath.resolve(meta.category()).resolve(meta.id() + ".md");
    }

    private String buildFrontMatter(DocumentContent content) {
        var sb = new StringBuilder();
        sb.append("---\n");
        sb.append("id: ").append(content.meta().id()).append("\n");
        sb.append("title: ").append(content.meta().title()).append("\n");
        if (content.meta().tags() != null && !content.meta().tags().isEmpty()) {
            sb.append("tags: [").append(String.join(", ", content.meta().tags())).append("]\n");
        }
        if (content.meta().engine() != null && !content.meta().engine().isBlank()) {
            sb.append("engine: ").append(content.meta().engine()).append("\n");
        }
        if (content.meta().generatedAt() != null) {
            sb.append("generated: ")
                    .append(content.meta().generatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
                    .append("\n");
        }
        for (var entry : content.frontMatter().entrySet()) {
            var value = entry.getValue();
            if (value instanceof List<?> list) {
                sb.append(entry.getKey()).append(": [")
                        .append(list.stream().map(Object::toString).collect(Collectors.joining(", ")))
                        .append("]\n");
            } else if (value instanceof Map<?, ?> map) {
                sb.append(entry.getKey()).append(":\n");
                map.forEach((k, v) -> sb.append("  ").append(k).append(": ").append(v).append("\n"));
            } else if (value instanceof Boolean || value instanceof Number) {
                sb.append(entry.getKey()).append(": ").append(value).append("\n");
            } else {
                sb.append(entry.getKey()).append(": \"").append(value).append("\"\n");
            }
        }
        sb.append("---\n");
        return sb.toString();
    }

    private String docToId(Path file) {
        var name = file.getFileName().toString();
        if (name.endsWith(".md")) name = name.substring(0, name.length() - 3);
        return name;
    }

    private DocumentMeta pathToMeta(Path file) {
        var id = docToId(file);
        var category = docsPath.relativize(file.getParent()).toString();
        return new DocumentMeta(id, id, category, null, DocumentType.OVERVIEW,
                List.of(), null, null, null);
    }

    private List<String> listCategories() throws IOException {
        try (var files = Files.walk(docsPath, 1)) {
            return files.filter(Files::isDirectory)
                    .map(docsPath::relativize)
                    .map(Path::toString)
                    .filter(s -> !s.isEmpty())
                    .sorted()
                    .toList();
        }
    }

    private void ensureCategoryIndices() throws IOException {
        var categories = listCategories();
        for (var cat : categories) {
            var indexPath = docsPath.resolve(cat).resolve("index.md");
            if (!Files.exists(indexPath)) {
                Files.createDirectories(indexPath.getParent());
                var frontMatter = "---\ntitle: " + capitalize(cat) + "\n---\n\n";
                Files.writeString(indexPath, frontMatter + "# " + capitalize(cat) + "\n");
            }
            var categoryJsonPath = docsPath.resolve(cat).resolve("_category_.json");
            if (!Files.exists(categoryJsonPath)) {
                var json = "{\"label\":\"" + capitalize(cat) + "\",\"link\":{\"type\":\"doc\",\"id\":\"" +
                        cat + "/index\"}}\n";
                Files.writeString(categoryJsonPath, json);
            }
        }
    }

    private String generateSidebarJs(List<String> categories) {
        var sb = new StringBuilder();
        sb.append("const sidebars = {\n");
        sb.append("  mainSidebar: [\n");
        sb.append("    'intro',\n");
        for (var cat : categories) {
            var label = capitalize(cat);
            sb.append("    {\n");
            sb.append("      type: 'category',\n");
            sb.append("      label: '").append(label).append("',\n");
            sb.append("      link: { type: 'doc', id: '").append(cat).append("/index' },\n");
            sb.append("      items: [\n");
            try {
                var docs = listByCategory(cat);
                for (var doc : docs) {
                    var docPath = doc.category() + "/" + doc.id();
                    sb.append("        '").append(docPath).append("',\n");
                }
            } catch (Exception ignored) {
            }
            sb.append("      ],\n");
            sb.append("    },\n");
        }
        sb.append("  ],\n");
        sb.append("};\n");
        sb.append("module.exports = sidebars;\n");
        return sb.toString();
    }

    private static String capitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }
}
