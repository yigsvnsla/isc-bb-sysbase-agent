#!/usr/bin/env bash
set -euo pipefail

# Setup del realm de desarrollo en Keycloak (vía admin API).
# El import por JSON rompe el direct grant en Keycloak 26 (resolve_required_actions).
# Uso: ./.container/keycloak/setup.sh  (requiere keycloak arriba en localhost:8081)
# Idempotente: los 409 se ignoran.

BASE="${KC_BASE_URL:-http://localhost:8081}"
ADMIN_USER="${KC_ADMIN_USER:-admin}"
ADMIN_PASS="${KC_ADMIN_PASS:-admin123}"

tok() {
    curl -sf --max-time 15 -X POST "$BASE/realms/master/protocol/openid-connect/token" \
        -d "grant_type=password&client_id=admin-cli&username=$ADMIN_USER&password=$ADMIN_PASS" \
        | grep -oE '"access_token":"[^"]+"' | sed 's/"access_token":"//;s/"//'
}

api() { curl -sf --max-time 15 -H "Authorization: Bearer $TOKEN" "$@"; }

TOKEN=$(tok)

api -o /dev/null -X POST "$BASE/admin/realms" -H "Content-Type: application/json" \
    -d '{"realm":"sysbase","enabled":true,"registrationAllowed":false}' || true

api -o /dev/null -X POST "$BASE/admin/realms/sysbase/clients" -H "Content-Type: application/json" \
    -d '{"clientId":"sysbase-agent","enabled":true,"publicClient":false,"secret":"dev-secret-sysbase-agent","directAccessGrantsEnabled":true}' || true

for ROLE in READONLY DOC ADMIN; do
    api -o /dev/null -X POST "$BASE/admin/realms/sysbase/roles" -H "Content-Type: application/json" \
        -d "{\"name\":\"$ROLE\"}" || true
done

USER_ID=$(api "$BASE/admin/realms/sysbase/users?username=agent-test" \
    | grep -oE '"id":"[^"]+"' | head -1 | sed 's/"id":"//;s/"//' || true)
if [ -z "$USER_ID" ]; then
    USER_ID=$(api -sS -X POST "$BASE/admin/realms/sysbase/users" -H "Content-Type: application/json" \
        -d '{"username":"agent-test","firstName":"Agent","lastName":"Test","email":"agent-test@local.test","emailVerified":true,"enabled":true,"requiredActions":[]}' \
        -o /dev/null -D /tmp/kc-loc.txt; grep -iE '^Location:' /tmp/kc-loc.txt | tr -d '\r' | sed 's/.*\/users\///')
fi

api -o /dev/null -X PUT "$BASE/admin/realms/sysbase/users/$USER_ID/reset-password" -H "Content-Type: application/json" \
    -d '{"type":"password","value":"test1234","temporary":false}'

DOC_ROLE=$(api "$BASE/admin/realms/sysbase/roles/DOC")
api -o /dev/null -X POST "$BASE/admin/realms/sysbase/users/$USER_ID/role-mappings/realm" -H "Content-Type: application/json" \
    -d "[$DOC_ROLE]"

echo "Setup OK: realm sysbase + client sysbase-agent + user agent-test (DOC)"
