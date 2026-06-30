# Modelo de Evidências — Unidade 2 CI/CD

**Aluno:** Lucas Alves  
**Pipeline:** MobEAD - Lucas Alves - CI/CD

Salve os prints nesta pasta (`evidencias/`) com os nomes sugeridos abaixo.

---

## Checklist de evidências

| # | Evidência | Arquivo sugerido | Status |
|---|-----------|------------------|--------|
| 1 | Fork do repositório no GitHub | `01-fork-github.png` | [ ] |
| 2 | Comandos Git utilizados | `02-comandos-git.png` | [ ] |
| 3 | Pipeline no Jenkins (nome com Lucas Alves) | `03-pipeline-jenkins.png` | [ ] |
| 4 | Execução da pipeline com sucesso | `04-pipeline-sucesso.png` | [ ] |
| 5 | Etapa SonarQube executada | `05-sonarqube-etapa.png` | [ ] |
| 6 | Logs finais da pipeline | `06-logs-finais.png` | [ ] |
| 7 | Aplicação rodando em DEV (8081) | `07-app-dev.png` | [ ] |
| 8 | Aplicação rodando em PROD (8082) | `08-app-prod.png` | [ ] |
| 9 | Aprovação manual antes do deploy PROD | `09-aprovacao-manual.png` | [ ] |
| 10 | SonarQube — Quality Gate e métricas | `10-sonarqube-metricas.png` | [ ] |

---

## 1. Fork do repositório no GitHub

**O que capturar:**
- Página do fork em `https://github.com/SEU_USUARIO/MobEAD`
- Mostrar que é um fork de `osanam-giordane/MobEAD`

**Como obter:**
1. Acesse seu fork no GitHub
2. Print da página inicial do repositório (banner "forked from...")

---

## 2. Comandos Git utilizados

**O que capturar:**
- Terminal com os comandos de clone, branch, commit e push
- Ou o arquivo `comandos-git.txt` aberto no editor/terminal

**Comandos mínimos a evidenciar:**
```bash
git clone https://github.com/SEU_USUARIO/MobEAD.git
git checkout -b develop
git add .
git commit -m "Adiciona pipeline CI/CD..."
git push -u origin develop
```

---

## 3. Pipeline no Jenkins (nome com Lucas Alves)

**O que capturar:**
- Dashboard do Jenkins com o job **MobEAD - Lucas Alves - CI/CD** visível
- Ou tela de configuração da pipeline mostrando o nome

**URL:** http://localhost:8080

---

## 4. Execução da pipeline com sucesso

**O que capturar:**
- **Stage View** com todos os estágios em verde (SUCCESS)
- Estágios esperados:
  - Checkout GitHub
  - Instalar dependências
  - Build
  - Testes
  - SonarQube
  - Quality Gate
  - Gerar artefato
  - Deploy DEV
  - Validar DEV
  - Aprovação para Produção
  - Deploy PROD
  - Validar PROD

---

## 5. Etapa SonarQube executada

**O que capturar:**
- Log da etapa **SonarQube** no console output do Jenkins
- Mostrar execução do `sonar-scanner` com sucesso

---

## 6. Logs finais da pipeline

**O que capturar:**
- Final do **Console Output** com a mensagem:

```
========================================
Pipeline MobEAD - Lucas Alves - CI/CD
STATUS: SUCESSO
========================================
```

---

## 7. Aplicação rodando em DEV

**O que capturar:**
- Navegador em http://localhost:8081
- Página MobEAD carregada (título "MobEAD - Treinamento Unyleya 2021")
- Opcional: `docker ps` mostrando container `mobead-dev`

---

## 8. Aplicação rodando em PROD

**O que capturar:**
- Navegador em http://localhost:8082
- Página MobEAD carregada
- Opcional: `docker ps` mostrando container `mobead-prod`

---

## 9. Aprovação manual antes do deploy PROD

**O que capturar:**
- Tela do Jenkins pausada em **Aprovação para Produção**
- Botão **Aprovar** / **Proceed** visível
- Ou print do momento em que você clicou para aprovar

**Texto esperado:** "Aprovar deploy em PRODUÇÃO? (porta 8082)"

---

## 10. SonarQube — Quality Gate e métricas

**O que capturar:**
- Dashboard do projeto **MobEAD - Lucas Alves** em http://localhost:9000
- Métricas visíveis:
  - Quality Gate (Passed/Failed)
  - Bugs
  - Vulnerabilities
  - Code Smells
  - Coverage (se disponível)

---

## Dicas para a entrega

1. Organize os prints na ordem do checklist
2. Use nomes de arquivo consistentes (`01-`, `02-`, etc.)
3. Inclua URL visível na barra do navegador quando possível
4. Para logs do Jenkins, role até o final do Console Output
5. Anexe este checklist preenchido junto com os prints

---

## Comandos para validar antes dos prints

```bash
# Infraestrutura
docker compose ps

# Aplicação
curl -I http://localhost:8081
curl -I http://localhost:8082

# Containers
docker ps --filter name=mobead
```
