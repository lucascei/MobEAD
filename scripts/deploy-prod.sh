#!/bin/bash
# Deploy da aplicação no ambiente PROD (porta 8082)
set -euo pipefail

IMAGE="${1:-mobead:latest}"
CONTAINER="${2:-mobead-prod}"
PORT="${3:-8082}"

echo ">>> Deploy PROD: imagem=${IMAGE}, container=${CONTAINER}, porta=${PORT}"

docker stop "${CONTAINER}" 2>/dev/null || true
docker rm "${CONTAINER}" 2>/dev/null || true

docker run -d \
  --name "${CONTAINER}" \
  --network mobead-network \
  -p "${PORT}:80" \
  -e APP_ENV=production \
  --restart unless-stopped \
  "${IMAGE}"

echo ">>> Deploy PROD concluído: http://localhost:${PORT}"
