package com.isc.bb.sysbase_agent.router;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import org.springframework.beans.factory.ObjectProvider;

class ModelRouterTest {

    @SuppressWarnings("unchecked")
    private <T> ObjectProvider<T> noopProvider() {
        var p = (ObjectProvider<T>) Mockito.mock(ObjectProvider.class);
        when(p.getIfAvailable()).thenReturn(null);
        return p;
    }

    private ModelRouter newRouter(String fallback) {
        return new ModelRouter(0.6, 0.35, 0.55, fallback,
                noopProvider(), noopProvider(), noopProvider(),
                false, 60);
    }

    @SuppressWarnings("unchecked")
    private ObjectProvider<LlmClassifier> classifierProvider(Tier returns) {
        var classifier = mock(LlmClassifier.class);
        when(classifier.classify(Mockito.anyString())).thenReturn(returns);
        var p = (ObjectProvider<LlmClassifier>) Mockito.mock(ObjectProvider.class);
        when(p.getIfAvailable()).thenReturn(classifier);
        return p;
    }

    private ModelRouter newRouterWithClassifier(Tier classifierReturns) {
        return new ModelRouter(0.6, 0.35, 0.55, "cheap",
                classifierProvider(classifierReturns),
                noopProvider(), noopProvider(),
                false, 60);
    }

    @Test
    void greetingShort_isCheap_intentSimple() {
        var d = newRouter("cheap").route("hola", 0);
        assertThat(d.tier()).isEqualTo(Tier.CHEAP);
        assertThat(d.reason()).isEqualTo("intent-simple");
        assertThat(d.score()).isZero();
    }

    @Test
    void listIntentShort_isCheap_intentSimple() {
        var d = newRouter("cheap").route("muéstrame las tablas del schema cobis", 0);
        assertThat(d.tier()).isEqualTo(Tier.CHEAP);
        assertThat(d.reason()).isEqualTo("intent-simple");
    }

    @Test
    void migrationKeywords_isExpensive_aboveThreshold() {
        var d = newRouter("cheap").route("explícame la migración de este SP de Sybase", 0);
        assertThat(d.tier()).isEqualTo(Tier.EXPENSIVE);
        assertThat(d.reason()).contains("keywords");
        assertThat(d.score()).isGreaterThanOrEqualTo(0.6);
    }

    @Test
    void veryLongMessage_withKeyword_isExpensive() {
        var sb = new StringBuilder("revisa el siguiente análisis detallado. ");
        for (int i = 0; i < 100; i++) sb.append("contexto adicional detallado aquí. ");
        var d = newRouter("cheap").route(sb.toString(), 0);
        assertThat(d.tier()).as("len>1500 + keyword 'revisa' debe ser EXPENSIVE")
                .isEqualTo(Tier.EXPENSIVE);
    }

    @Test
    void longHistory_addsScore() {
        var d = newRouter("cheap").route("continúame por favor con esto", 15);
        assertThat(d.score()).as("hist>=10 suma +0.15").isGreaterThanOrEqualTo(0.15);
    }

    @Test
    void emptyMessage_fallsBack() {
        var d = newRouter("cheap").route("", 0);
        assertThat(d.tier()).isEqualTo(Tier.CHEAP);
        assertThat(d.reason()).isEqualTo("empty-msg");
    }

    @Test
    void nullMessage_fallsBack() {
        var d = newRouter("expensive").route(null, 5);
        assertThat(d.tier()).isEqualTo(Tier.EXPENSIVE);
    }

    @Test
    void multipleKeywords_capsAt08() {
        var d = newRouter("cheap").route("explícame y analiza y diseña el diagrama y la arquitectura y revisa", 0);
        assertThat(d.score()).isLessThanOrEqualTo(1.0);
        assertThat(d.tier()).isEqualTo(Tier.EXPENSIVE);
    }

    @Test
    void grayScore_invokesClassifier_returnsExpensive() {
        // "explícame" corto = 9 chars + keyword +0.40 → score 0.40 (gray 0.35-0.55)
        var d = newRouterWithClassifier(Tier.EXPENSIVE).route("explícame esto", 0);
        assertThat(d.score()).as("score debe ser 0.40 (dentro de gray)").isEqualTo(0.40);
        assertThat(d.reason()).startsWith("classifier:");
        assertThat(d.tier()).isEqualTo(Tier.EXPENSIVE);
    }

    @Test
    void grayScore_classifierFails_fallsBack() {
        var d = newRouterWithClassifier(null).route("explícame esto", 0);
        assertThat(d.tier()).as("fallback cheap").isEqualTo(Tier.CHEAP);
        assertThat(d.reason()).contains("classifier-fail");
    }

    @Test
    void isGray_rangeCorrect() {
        var r = newRouter("cheap");
        assertThat(r.isGray(0.0)).isFalse();
        assertThat(r.isGray(0.34)).isFalse();
        assertThat(r.isGray(0.35)).isTrue();
        assertThat(r.isGray(0.40)).isTrue();
        assertThat(r.isGray(0.55)).isFalse();
        assertThat(r.isGray(0.60)).isFalse();
    }
}