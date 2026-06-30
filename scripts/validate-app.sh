#!/bin/bash
# Valida se a aplicação está respondendo corretamente
set -euo pipefail

URL="${1:-http://localhost:8081}"
AMBIENTE="${2:-DEV}"
MAX_TENTATIVAS=30
INTERVALO=2

echo ">>> Validando ambiente ${AMBIENTE} em ${URL}"

for i in $(seq 1 ${MAX_TENTATIVAS}); do
  HTTP_CODE=$(curl -s -o /tmp/mobead-response.html -w "%{http_code}" "${URL}" || echo "000")

  if [ "${HTTP_CODE}" = "200" ]; then
    if grep -q "MobEAD" /tmp/mobead-response.html; then
      echo ">>> Validação ${AMBIENTE} OK (HTTP ${HTTP_CODE}) - aplicação respondendo"
      exit 0
    fi
  fi

  echo "  Tentativa ${i}/${MAX_TENTATIVAS} - aguardando aplicação... (HTTP ${HTTP_CODE})"
  sleep "${INTERVALO}"
done

echo ">>> ERRO: Aplicação em ${AMBIENTE} não respondeu corretamente em ${URL}"
exit 1
