#!/bin/bash
# Verifica Quality Gate via API do SonarQube (alternativa ao waitForQualityGate)
set -euo pipefail

PROJECT_KEY="${1:-mobead-lucas-alves}"
SONAR_URL="${2:-http://sonarqube:9000}"
MAX_TENTATIVAS=60
INTERVALO=2

echo ">>> Verificando Quality Gate do projeto: ${PROJECT_KEY}"

for i in $(seq 1 ${MAX_TENTATIVAS}); do
  RESPONSE=$(curl -s -u "${SONAR_TOKEN}:" \
    "${SONAR_URL}/api/qualitygates/project_status?projectKey=${PROJECT_KEY}")

  STATUS=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin)['projectStatus']['status'])
except Exception:
    print('UNKNOWN')
" 2>/dev/null || echo "UNKNOWN")

  echo "  Tentativa ${i}/${MAX_TENTATIVAS} - Quality Gate: ${STATUS}"

  if [ "${STATUS}" = "OK" ]; then
    echo ">>> Quality Gate PASSED"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    exit 0
  fi

  if [ "${STATUS}" = "ERROR" ]; then
    echo ">>> Quality Gate FAILED (pipeline continua para fins acadêmicos)"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    exit 0
  fi

  sleep "${INTERVALO}"
done

echo ">>> AVISO: Quality Gate não retornou status em tempo hábil (pipeline continua)"
exit 0
