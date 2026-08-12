package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.util.LinkedMultiValueMap;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.wait.strategy.HttpWaitStrategy;
import org.testcontainers.utility.DockerImageName;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

@AutoConfigureTestRestTemplate
class KeycloakE2ETest extends AbstractIntegrationTest {

    static final GenericContainer<?> keycloak = new GenericContainer<>(
            DockerImageName.parse("quay.io/keycloak/keycloak:26.0"))
            .withExposedPorts(8080)
            .withEnv("KEYCLOAK_ADMIN", "admin")
            .withEnv("KEYCLOAK_ADMIN_PASSWORD", "admin123")
            .withCommand("start-dev")
            .waitingFor(new HttpWaitStrategy()
                    .forPort(8080)
                    .forPath("/realms/master")
                    .withStartupTimeout(Duration.ofMinutes(3)));

    static {
        keycloak.start();
        setupTestRealm();
    }

    private static void setupTestRealm() {
        var base = "http://localhost:" + keycloak.getMappedPort(8080);
        var rest = org.springframework.web.client.RestClient.create();
        var adminToken = rest.post()
                .uri(base + "/realms/master/protocol/openid-connect/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(form("grant_type", "password", "client_id", "admin-cli",
                        "username", "admin", "password", "admin123"))
                .retrieve().body(String.class);
        var adminAuth = "Bearer " + adminToken.replaceAll(".*\"access_token\":\"([^\"]+)\".*", "$1");

        post(rest, base, adminAuth, "/admin/realms",
                """
                        {"realm":"sysbase","enabled":true,"registrationAllowed":false}
                        """);
        post(rest, base, adminAuth, "/admin/realms/sysbase/clients",
                """
                        {"clientId":"sysbase-agent","enabled":true,"publicClient":false,
                         "secret":"dev-secret-sysbase-agent","directAccessGrantsEnabled":true}
                        """);
        for (var role : new String[] { "READONLY", "DOC", "ADMIN" }) {
            post(rest, base, adminAuth, "/admin/realms/sysbase/roles",
                    "{\"name\":\"" + role + "\"}");
        }
        var location = post(rest, base, adminAuth, "/admin/realms/sysbase/users",
                """
                        {"username":"agent-test","firstName":"Agent","lastName":"Test",
                         "email":"agent-test@local.test","emailVerified":true,
                         "enabled":true,"requiredActions":[]}
                        """);
        var userId = location.replaceAll(".*/users/", "");

        rest.put()
                .uri(base + "/admin/realms/sysbase/users/{id}/reset-password", userId)
                .header(HttpHeaders.AUTHORIZATION, adminAuth)
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"type\":\"password\",\"value\":\"test1234\",\"temporary\":false}")
                .retrieve().toBodilessEntity();

        var docRole = rest.get()
                .uri(base + "/admin/realms/sysbase/roles/DOC")
                .header(HttpHeaders.AUTHORIZATION, adminAuth)
                .retrieve().body(String.class);

        rest.post()
                .uri(base + "/admin/realms/sysbase/users/{id}/role-mappings/realm", userId)
                .header(HttpHeaders.AUTHORIZATION, adminAuth)
                .contentType(MediaType.APPLICATION_JSON)
                .body("[" + docRole + "]")
                .retrieve().toBodilessEntity();
    }

    private static String post(org.springframework.web.client.RestClient rest, String base,
                               String adminAuth, String path, String body) {
        try {
            return rest.post()
                    .uri(base + path)
                    .header(HttpHeaders.AUTHORIZATION, adminAuth)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve().toBodilessEntity()
                    .getHeaders().getFirst("Location");
        } catch (org.springframework.web.client.HttpClientErrorException.Conflict e) {
            return null;
        }
    }

    private static LinkedMultiValueMap<String, String> form(String... kv) {
        var m = new LinkedMultiValueMap<String, String>();
        for (int i = 0; i < kv.length; i += 2) {
            m.add(kv[i], kv[i + 1]);
        }
        return m;
    }

    @DynamicPropertySource
    static void oidcIssuer(DynamicPropertyRegistry registry) {
        registry.add("app.security.oidc.issuer-uri",
                () -> "http://localhost:" + keycloak.getMappedPort(8080) + "/realms/sysbase");
    }

    @Autowired
    TestRestTemplate rest;

    @Test
    void keycloakToken_docRole_authenticatesChat() {
        var token = fetchToken("agent-test", "test1234");
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(token);

        var body = """
                {"conversationId":"e2e-keycloak-1","message":"hola"}
                """;
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers), String.class);

        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("sysbase-agent");
    }

    @Test
    void keycloakToken_invalidCredentials_rejected() {
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"e2e-keycloak-2","message":"hola"}
                        """, bearerHeaders("no-token")), String.class);
        assertThat(resp.getStatusCode().is4xxClientError()).isTrue();
    }

    private String fetchToken(String username, String password) {
        var form = new LinkedMultiValueMap<String, String>();
        form.add("grant_type", "password");
        form.add("client_id", "sysbase-agent");
        form.add("client_secret", "dev-secret-sysbase-agent");
        form.add("username", username);
        form.add("password", password);
        var resp = rest.postForEntity(
                "http://localhost:" + keycloak.getMappedPort(8080)
                        + "/realms/sysbase/protocol/openid-connect/token",
                new HttpEntity<>(form, new HttpHeaders()), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful())
                .as("token request -> %s %s", resp.getStatusCode(), resp.getBody()).isTrue();
        return resp.getBody().replaceAll(".*\"access_token\":\"([^\"]+)\".*", "$1");
    }

    private HttpHeaders bearerHeaders(String token) {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(token);
        return headers;
    }
}
