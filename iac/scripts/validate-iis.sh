#!/bin/bash
# Valida se o IIS está respondendo na VM provisionada
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")/terraform"

cd "${TF_DIR}"
PUBLIC_IP=$(terraform output -raw public_ip_address 2>/dev/null || echo "")

if [ -z "${PUBLIC_IP}" ]; then
  echo "ERRO: IP público não encontrado. Execute terraform apply."
  exit 1
fi

echo ">>> Validando IIS em http://${PUBLIC_IP}/"
HTTP_CODE=$(curl -s -o /tmp/mobead-iis.html -w "%{http_code}" --connect-timeout 15 "http://${PUBLIC_IP}/" || echo "000")

if [ "${HTTP_CODE}" = "200" ]; then
  if grep -q "MobEAD" /tmp/mobead-iis.html && grep -q "Lucas Alves" /tmp/mobead-iis.html; then
    echo ">>> IIS OK (HTTP ${HTTP_CODE}) - Página MobEAD publicada"
    exit 0
  fi
fi

echo ">>> ERRO: IIS não respondeu corretamente (HTTP ${HTTP_CODE})"
exit 1
