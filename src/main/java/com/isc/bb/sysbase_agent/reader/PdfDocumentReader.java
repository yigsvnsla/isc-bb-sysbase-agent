package com.isc.bb.sysbase_agent.reader;

import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Supplier;

import org.apache.pdfbox.Loader;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.document.Document;
import org.springframework.ai.document.DocumentReader;

public class PdfDocumentReader implements DocumentReader {

    private static final Logger log = LoggerFactory.getLogger(PdfDocumentReader.class);

    private final Path pdfPath;

    public PdfDocumentReader(Path pdfPath) {
        this.pdfPath = pdfPath;
    }

    @Override
    public List<Document> get() {
        return read();
    }

    public List<Document> read() {
        var docs = new ArrayList<Document>();
        try (var doc = Loader.loadPDF(pdfPath.toFile())) {
            var stripper = new PDFTextStripper();
            for (int i = 1; i <= doc.getNumberOfPages(); i++) {
                stripper.setStartPage(i);
                stripper.setEndPage(i);
                var text = stripper.getText(doc);
                if (!text.isBlank()) {
                    docs.add(new Document(text, Map.of(
                            "source", pdfPath.getFileName().toString(),
                            "page", i)));
                }
            }
            log.debug("PDF leído: {} ({} páginas, {} chunks)", pdfPath.getFileName(), doc.getNumberOfPages(), docs.size());
        } catch (IOException e) {
            throw new RuntimeException("Error leyendo PDF: " + pdfPath, e);
        }
        return docs;
    }
}
