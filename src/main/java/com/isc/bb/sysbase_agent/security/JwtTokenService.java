package com.isc.bb.sysbase_agent.security;

import java.time.Duration;
import java.util.Date;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;

@Service
public class JwtTokenService {

    private final SecretKey key;
    private final Duration ttl;
    private final String keyId;

    public JwtTokenService(@Value("${app.security.jwt.secret}") String secret,
                           @Value("${app.security.jwt.ttl-minutes:60}") long ttlMinutes,
                           @Value("${app.security.jwt.key-id:current}") String keyId) {
        this.key = new SecretKeySpec(secret.getBytes(java.nio.charset.StandardCharsets.UTF_8), "HmacSHA256");
        this.ttl = Duration.ofMinutes(ttlMinutes);
        this.keyId = keyId;
    }

    public String issue(String subject, String role) {
        try {
            var signer = new MACSigner(key);
            var claims = new JWTClaimsSet.Builder()
                    .subject(subject)
                    .claim("role", role)
                    .issuer("sysbase-agent")
                    .jwtID(java.util.UUID.randomUUID().toString())
                    .issueTime(new Date())
                    .expirationTime(new Date(System.currentTimeMillis() + ttl.toMillis()))
                    .build();
            var headerBuilder = new JWSHeader.Builder(JWSAlgorithm.HS256);
            if (keyId != null && !keyId.isBlank()) {
                headerBuilder.keyID(keyId);
            }
            var jwt = new SignedJWT(headerBuilder.build(), claims);
            jwt.sign(signer);
            return jwt.serialize();
        } catch (Exception e) {
            throw new IllegalStateException("Fallo emisión JWT", e);
        }
    }

    // TODO(futuro): incluir claims de tenant/scopes cuando exista multi-tenant.
}
