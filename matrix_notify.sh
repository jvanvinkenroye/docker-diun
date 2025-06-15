#!/bin/bash

# Optional: .env laden
ENV_FILE="$(dirname "$0")/.env"
if [[ -f "$ENV_FILE" ]]; then
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
else
  echo "⚠️ .env-Datei nicht gefunden: $ENV_FILE"
fi

# Username in Matrix-konformen lokalen Teil umwandeln
LOGIN_USER="${MATRIX_USERNAME#@}"      # Entfernt führendes @
LOGIN_USER="${LOGIN_USER%%:*}"         # Entfernt Domain

echo "[DEBUG] Login wird ausgeführt mit user=$LOGIN_USER"

LOGIN_RESPONSE=$(curl -s -X POST "${MATRIX_TARGET}/_matrix/client/r0/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"m.login.password\",
    \"user\": \"${LOGIN_USER}\",
    \"password\": \"${MATRIX_PASSWORD}\"
  }")

echo "[DEBUG] Login-Antwort:"
echo "$LOGIN_RESPONSE"

# Token extrahieren
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r .access_token)

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
  echo "❌ Fehler: Kein Access Token erhalten. Login fehlgeschlagen."
  exit 1
fi

# Optional: wer bin ich?
WHOAMI=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "${MATRIX_TARGET}/_matrix/client/v3/account/whoami")

echo "[DEBUG] Wer bin ich laut Token?"
echo "$WHOAMI"
