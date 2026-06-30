#!/bin/bash
# Corrige permissões e reinicia o Jenkins após mudanças na imagem
set -euo pipefail

cd "$(dirname "$0")/.."

echo ">>> Reconstruindo imagem do Jenkins..."
docker compose build jenkins

echo ">>> Reiniciando Jenkins..."
docker compose up -d jenkins

echo ">>> Aguardando Jenkins ficar pronto..."
sleep 15

echo ">>> Verificando acesso ao Docker dentro do Jenkins..."
docker exec -u jenkins jenkins docker ps --format "{{.Names}}" | head -5

echo ">>> Pronto! Acesse http://localhost:8080 e clique em Build Now"
