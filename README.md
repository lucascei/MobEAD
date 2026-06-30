# MobEAD - Pipeline CI/CD (Unidade 2)

**Aluno:** Lucas Alves  
**Disciplina:** Engenharia DevOps  
**Objetivo:** Pipeline CI/CD com Jenkins, GitHub, SonarQube e deploy automatizado (DEV + PROD)

---

## Visão geral

Este projeto implementa uma pipeline completa para a aplicação [MobEAD](https://github.com/osanam-giordane/MobEAD):

```
Checkout GitHub
    ↓
Instalar dependências
    ↓
Build
    ↓
Testes
    ↓
SonarQube
    ↓
Gerar artefato
    ↓
Deploy DEV (8081)
    ↓
Aprovação manual
    ↓
Deploy PROD (8082)
```

### Ambientes

| Ambiente | URL | Container |
|----------|-----|-----------|
| DEV | http://localhost:8081 | `mobead-dev` |
| PROD | http://localhost:8082 | `mobead-prod` |
| Jenkins | http://localhost:8080 | `jenkins` |
| SonarQube | http://localhost:9000 | `sonarqube` |

---

## Pré-requisitos

- Docker e Docker Compose instalados
- Git
- Conta no GitHub (para fork)
- Mínimo 4 GB de RAM livre (SonarQube + Jenkins)

---

## Passo 1 — Fork e clone do repositório

1. Acesse https://github.com/osanam-giordane/MobEAD
2. Clique em **Fork** para sua conta GitHub
3. Clone o fork e crie a branch de desenvolvimento

Os comandos completos estão em [`comandos-git.txt`](comandos-git.txt).

---

## Passo 2 — Subir infraestrutura local

Na raiz do projeto:

```bash
docker compose up -d --build
```

Aguarde os serviços ficarem prontos (SonarQube pode levar 2–3 minutos):

```bash
docker compose ps
docker logs sonarqube --tail 20
docker logs jenkins --tail 20
```

### Credenciais padrão

| Serviço | Usuário | Senha |
|---------|---------|-------|
| Jenkins | `admin` | `admin123` |
| SonarQube | `admin` | `admin` (alterar no 1º acesso) |

---

## Passo 3 — Configurar SonarQube

1. Acesse http://localhost:9000
2. Faça login (`admin` / `admin`) e altere a senha quando solicitado
3. Vá em **My Account → Security → Generate Token**
4. Copie o token gerado

### Atualizar token no Jenkins

1. Acesse http://localhost:8080 (login: `admin` / `admin123`)
2. Vá em **Manage Jenkins → Credentials → System → Global credentials**
3. Edite a credencial `sonar-token` e cole o token do SonarQube
4. Reinicie o Jenkins se necessário:

```bash
docker compose restart jenkins
```

---

## Passo 4 — Criar pipeline no Jenkins

1. Acesse http://localhost:8080
2. Clique em **New Item**
3. Nome: **`MobEAD - Lucas Alves - CI/CD`** (obrigatório conter seu nome)
4. Tipo: **Pipeline**
5. Em **Pipeline → Definition**, selecione **Pipeline script from SCM**
6. SCM: **Git**
7. Repository URL: URL do seu fork no GitHub (ex.: `https://github.com/SEU_USUARIO/MobEAD.git`)
8. Branch: `develop` (ou `*/develop`)
9. Script Path: `Jenkinsfile`
10. Salve

### Permissão para aprovação manual

O usuário que aprova o deploy em produção precisa ter permissão no Jenkins. Com o login `admin`, a aprovação funciona normalmente.

---

## Passo 5 — Executar a pipeline

1. Na pipeline **MobEAD - Lucas Alves - CI/CD**, clique em **Build Now**
2. Acompanhe cada estágio em **Stage View**
3. Quando chegar em **Aprovação para Produção**, clique no build e depois em **Proceed** (ou **Aprovar**)
4. Aguarde conclusão com status **SUCCESS**

### Verificar aplicação nos ambientes

Após execução bem-sucedida:

```bash
curl -I http://localhost:8081   # DEV
curl -I http://localhost:8082   # PROD
```

Abra no navegador:
- DEV: http://localhost:8081
- PROD: http://localhost:8082

---

## Passo 6 — Evidências da atividade

Use o modelo em [`evidencias/MODELO-EVIDENCIAS.md`](evidencias/MODELO-EVIDENCIAS.md).

Salve os prints na pasta `evidencias/` com os nomes sugeridos no modelo.

---

## Estrutura do projeto

```
.
├── Jenkinsfile                 # Pipeline CI/CD completa
├── docker-compose.yml          # Jenkins + SonarQube
├── Dockerfile                  # Imagem da aplicação MobEAD
├── package.json                # Dependências e scripts de teste
├── sonar-project.properties    # Configuração SonarQube
├── comandos-git.txt            # Comandos Git documentados
├── lib/                        # Código testável
├── tests/                      # Testes automatizados (Mocha + Chai)
├── scripts/
│   ├── build.js
│   ├── deploy-dev.sh
│   ├── deploy-prod.sh
│   └── validate-app.sh
├── docker/
│   ├── jenkins/                # Imagem customizada do Jenkins
│   └── nginx/                  # Config Nginx da aplicação
└── evidencias/
    └── MODELO-EVIDENCIAS.md
```

---

## Testes locais (sem Jenkins)

```bash
npm install
npm run build
npm run test:coverage
docker build -t mobead:local .
./scripts/deploy-dev.sh mobead:local mobead-dev 8081
./scripts/validate-app.sh http://localhost:8081 DEV
```

---

## SonarQube — métricas esperadas

Após a pipeline executar a etapa SonarQube, acesse http://localhost:9000 e abra o projeto **MobEAD - Lucas Alves**.

Evidencie:
- **Quality Gate** (Passed/Failed)
- **Bugs**
- **Vulnerabilities**
- **Code Smells**
- **Coverage** (se disponível)

---

## Comandos úteis

```bash
# Parar tudo
docker compose down

# Parar e remover volumes (reset completo)
docker compose down -v

# Ver containers da aplicação
docker ps --filter name=mobead

# Logs da pipeline (container Jenkins)
docker logs jenkins -f

# Remover deploy DEV/PROD manualmente
docker stop mobead-dev mobead-prod
docker rm mobead-dev mobead-prod
```

---

## Solução de problemas

### SonarQube não sobe
- Verifique memória: `sysctl vm.max_map_count` deve ser >= 262144
- Linux: `sudo sysctl -w vm.max_map_count=262144`

### Pipeline falha no SonarQube
- Confirme que o token está configurado em **Credentials → sonar-token**
- Verifique se o SonarQube está UP: http://localhost:9000/api/system/status

### Validação DEV/PROD falha
- Confirme containers: `docker ps | grep mobead`
- Teste manualmente: `curl http://localhost:8081`

### Jenkins não acessa Docker
- O socket está montado em `/var/run/docker.sock`
- Jenkins roda como root para usar Docker

---

## Referências

- Repositório original: https://github.com/osanam-giordane/MobEAD
- Jenkins: https://www.jenkins.io/doc/
- SonarQube: https://docs.sonarqube.org/
