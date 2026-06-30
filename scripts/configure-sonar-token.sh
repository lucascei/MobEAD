#!/bin/bash
# Gera token no SonarQube e configura automaticamente no Jenkins
set -euo pipefail

cd "$(dirname "$0")/.."

echo "=========================================="
echo " Configurar token SonarQube no Jenkins"
echo "=========================================="
echo ""
echo "Informe a senha do usuário admin do SonarQube"
echo "(a senha que você definiu em http://localhost:9000)"
echo ""
read -rsp "Senha admin SonarQube: " SONAR_PASS
echo ""

echo ">>> Gerando token no SonarQube..."
RESPONSE=$(curl -s -u "admin:${SONAR_PASS}" \
  -X POST "http://localhost:9000/api/user_tokens/generate?name=jenkins-mobead")

TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('token',''))" 2>/dev/null || true)

if [ -z "$TOKEN" ]; then
  echo "ERRO: Não foi possível gerar o token."
  echo "Resposta do SonarQube: $RESPONSE"
  echo ""
  echo "Verifique se a senha está correta e se o SonarQube está rodando:"
  echo "  docker compose ps"
  exit 1
fi

echo ">>> Token gerado com sucesso."

# Salva no .env (não vai para o Git)
echo "SONAR_TOKEN=${TOKEN}" > .env
chmod 600 .env

# Atualiza CasC no volume do Jenkins e recria credencial
echo ">>> Atualizando credencial no Jenkins..."
docker cp docker/jenkins/casc_configs/jenkins.yaml jenkins:/var/jenkins_home/casc_configs/jenkins.yaml
docker exec jenkins rm -f /var/jenkins_home/credentials.xml

echo ">>> Reiniciando Jenkins..."
docker compose up -d jenkins

echo ">>> Aguardando Jenkins..."
sleep 20

# Valida token no SonarQube
VALID=$(curl -s -u "${TOKEN}:" "http://localhost:9000/api/authentication/validate" | python3 -c "import sys,json; print(json.load(sys.stdin).get('valid', False))" 2>/dev/null || echo "false")

if [ "$VALID" = "True" ] || [ "$VALID" = "true" ]; then
  echo ""
  echo "=========================================="
  echo " SUCESSO! Token configurado."
  echo "=========================================="
  echo "Agora no Jenkins clique em: Build Now"
else
  echo "AVISO: Token salvo, mas validação retornou: $VALID"
  echo "Tente Build Now mesmo assim."
fi
