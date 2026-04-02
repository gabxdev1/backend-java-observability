#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="${1:-/tmp/corp-certs}"
STOREPASS="${JVM_CACERTS_PASSWORD:-changeit}"

JAVA_BIN="$(readlink -f "$(command -v java)")"
JAVA_HOME_DIR="$(dirname "$(dirname "${JAVA_BIN}")")"
JAVA_CACERTS="${JAVA_HOME_DIR}/lib/security/cacerts"

if [[ ! -f "${JAVA_CACERTS}" ]] && [[ -f "/etc/ssl/certs/java/cacerts" ]]; then
  JAVA_CACERTS="/etc/ssl/certs/java/cacerts"
fi

if [[ -f "${CERT_DIR}/cacerts" ]]; then
  cp "${CERT_DIR}/cacerts" "${JAVA_CACERTS}"
  chmod 0644 "${JAVA_CACERTS}"
  echo "[certs] Truststore corporativa aplicada em ${JAVA_CACERTS}."
  exit 0
fi

shopt -s nullglob
certs=("${CERT_DIR}"/*.crt "${CERT_DIR}"/*.cer "${CERT_DIR}"/*.pem)

if (( ${#certs[@]} == 0 )); then
  echo "[certs] Nenhum certificado encontrado em ${CERT_DIR}. Pulando import."
  exit 0
fi

for cert in "${certs[@]}"; do
  name="$(basename "${cert}")"
  alias="corp-$(echo "${name%.*}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-')"

  if keytool -cacerts -storepass "${STOREPASS}" -list -alias "${alias}" >/dev/null 2>&1; then
    keytool -cacerts -storepass "${STOREPASS}" -delete -alias "${alias}"
  fi

  keytool -cacerts -storepass "${STOREPASS}" -importcert -noprompt -alias "${alias}" -file "${cert}"
  echo "[certs] Importado: ${name} (alias: ${alias})"
done
