#!/bin/bash
# Deploy da aplicação no ambiente DEV (porta 8081)
set -euo pipefail

IMAGE="${1:-mobead:latest}"
CONTAINER="${2:-mobead-dev}"
PORT="${3:-8081}"

echo ">>> Deploy DEV: imagem=${IMAGE}, container=${CONTAINER}, porta=${PORT}"

docker stop "${CONTAINER}" 2>/dev/null || true
docker rm "${CONTAINER}" 2>/dev/null || true

docker run -d \
  --name "${CONTAINER}" \
  --network mobead-network \
  -p "${PORT}:80" \
  -e APP_ENV=development \
  --restart unless-stopped \
  "${IMAGE}"

echo ">>> Deploy DEV concluído: http://localhost:${PORT}"
