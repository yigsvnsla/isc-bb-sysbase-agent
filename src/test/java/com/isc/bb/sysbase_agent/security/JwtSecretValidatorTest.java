package com.isc.bb.sysbase_agent.security;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.springframework.core.env.Environment;

class JwtSecretValidatorTest {

    private static final String DEV_DEFAULT = "dev-only-secret-cambiar-en-produccion-32bytes";
    private static final String STRONG = "this-is-a-strong-prod-secret-with-32-plus-bytes!!";

    private Environment env(String... profiles) {
        var env = mock(Environment.class);
        when(env.getActiveProfiles()).thenReturn(profiles);
        return env;
    }

    @Test
    void prodWithDevDefault_throws() {
        assertThatThrownBy(() -> new JwtSecretValidator(DEV_DEFAULT, env("prod")))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("JWT_SECRET");
    }

    @Test
    void prodWithShortSecret_throws() {
        assertThatThrownBy(() -> new JwtSecretValidator("too-short", env("prod")))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void prodWithStrongSecret_ok() {
        assertThatCode(() -> new JwtSecretValidator(STRONG, env("prod"))).doesNotThrowAnyException();
    }

    @Test
    void devWithDevDefault_ok() {
        assertThatCode(() -> new JwtSecretValidator(DEV_DEFAULT, env("dev"))).doesNotThrowAnyException();
    }

    @Test
    void noProfilesWithDevDefault_ok() {
        assertThatCode(() -> new JwtSecretValidator(DEV_DEFAULT, env())).doesNotThrowAnyException();
    }
}
