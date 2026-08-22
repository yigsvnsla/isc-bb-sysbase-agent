package com.isc.bb.sysbase_agent.cli;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.security.ApiKeyRepository;
import com.isc.bb.sysbase_agent.security.JwtRevocationService;
import com.isc.bb.sysbase_agent.security.JwtTokenService;
import com.nimbusds.jwt.SignedJWT;

@Component
public class SecurityCli {

    private final JwtTokenService tokenService;
    private final ApiKeyRepository apiKeyRepository;
    private final JwtRevocationService revocations;

    public SecurityCli(JwtTokenService tokenService, ApiKeyRepository apiKeyRepository,
                       JwtRevocationService revocations) {
        this.tokenService = tokenService;
        this.apiKeyRepository = apiKeyRepository;
        this.revocations = revocations;
    }

    @Command(name = "token-create", description = "Emite un JWT autogenerado (HMAC) para consumir la API")
    public String tokenCreate(
            @Option(longName = "sub", description = "Sujeto/identificador (default: cli-user)") String subject,
            @Option(longName = "role", description = "READONLY | DOC | ADMIN") String role,
            @Option(longName = "ttl-min", description = "Validez en minutos (default 60)") Long ttlMinutes) {
        var token = tokenService.issue(subject != null ? subject : "cli-user",
                role != null ? role.toUpperCase() : "READONLY");
        return token;
    }

    @Command(name = "token-revoke", description = "Revoca un JWT antes de su expiración natural (denylist en Redis)")
    public String tokenRevoke(@Option(longName = "token", description = "El JWT completo a revocar") String token) {
        try {
            var claims = SignedJWT.parse(token).getJWTClaimsSet();
            var jti = claims.getJWTID();
            var exp = claims.getExpirationTime();
            revocations.revoke(jti, exp != null ? exp.toInstant() : null);
            return "Token revocado (jti=" + jti + ").";
        } catch (IllegalArgumentException e) {
            return "No se pudo revocar: " + e.getMessage();
        } catch (Exception e) {
            return "Token inválido, no se pudo parsear: " + e.getMessage();
        }
    }

    @Command(name = "apikey-create", description = "Crea una API key (la key plana se muestra UNA sola vez)")
    public String apiKeyCreate(
            @Option(longName = "name", description = "Nombre identificador") String name,
            @Option(longName = "role", description = "READONLY | DOC | ADMIN") String role,
            @Option(longName = "expire-days", description = "Días de validez (default: sin expiración)") Long expireDays) {
        var expiresAt = expireDays != null ? Instant.now().plus(expireDays, ChronoUnit.DAYS) : null;
        var plain = apiKeyRepository.create(name != null ? name : "unnamed",
                role != null ? role.toUpperCase() : "READONLY", expiresAt);
        return "API key creada (guárdala, no se mostrará de nuevo):\n" + plain;
    }

    @Command(name = "apikey-list", description = "Lista API keys registradas")
    public String apiKeyList() {
        var keys = apiKeyRepository.list();
        if (keys.isEmpty()) {
            return "No hay API keys.";
        }
        var sb = new StringBuilder();
        for (var k : keys) {
            sb.append(String.format("#%d %s rol=%s activa=%s expira=%s%n",
                    k.id(), k.name(), k.role(), k.active(),
                    k.expiresAt() != null ? k.expiresAt().toString() : "nunca"));
        }
        return sb.toString();
    }

    @Command(name = "apikey-revoke", description = "Desactiva una API key por id")
    public String apiKeyRevoke(@Option(longName = "id", description = "Id de la key") long id) {
        return apiKeyRepository.revoke(id) ? "Key #" + id + " revocada." : "Key #" + id + " no encontrada.";
    }
}
