# Relatório — Infraestrutura como Código (IaC)

**Disciplina:** Engenharia DevOps  
**Instituição:** Unyleya  
**Aluno:** Lucas Alves  
**Unidade:** 4 — Terraform + Ansible + Azure  
**Projeto:** MobEAD (continuação das Unidades 2 e 3)

---

## 1. Objetivo

Evoluir o projeto MobEAD — desenvolvido nas Unidades 2 e 3 com pipeline CI/CD completa (Jenkins, SonarQube, Docker, deploy DEV/PROD) — implementando **Infraestrutura como Código (IaC)** para provisionar e configurar automaticamente um servidor Windows na nuvem Microsoft Azure.

O objetivo é eliminar configurações manuais, garantir reprodutibilidade e aplicar boas práticas de automação em infraestrutura, complementando a esteira de CI/CD já existente.

---

## 2. Arquitetura

### 2.1 Visão geral

A solução adota uma abordagem em duas camadas:

1. **Terraform** — provisiona a infraestrutura base na Azure
2. **Ansible** — configura o software e publica a aplicação na VM criada

### 2.2 Componentes Azure

| Recurso | Nome | Função |
|---------|------|--------|
| Resource Group | `rg-mobead-iac-lucas-alves` | Agrupamento lógico de recursos |
| Virtual Network | `mobead-vnet` | Rede isolada (10.10.0.0/16) |
| Subnet | `mobead-subnet` | Segmento da VM (10.10.1.0/24) |
| NSG | `mobead-nsg` | Firewall de rede (3389, 5986, 80, 443) |
| Public IP | `mobead-pip` | Acesso externo à VM |
| NIC | `mobead-nic` | Interface de rede da VM |
| VM | `vm-mobead-iac-lucas-alves` | Windows Server 2022 + IIS |

### 2.3 Integração com o projeto anterior

O projeto IaC complementa — e não substitui — a pipeline CI/CD local:

- **Unidades 2/3:** Jenkins orquestra build, testes, SonarQube e deploy em containers Docker (DEV:8081, PROD:8082)
- **Unidade 4:** Terraform + Ansible provisionam infraestrutura cloud e publicam aplicação no IIS

Ambos compartilham o mesmo repositório GitHub (`lucascei/MobEAD`) e a mesma identidade de projeto (MobEAD — Lucas Alves).

---

## 3. Funcionamento do Terraform

### 3.1 Estrutura modular

O código Terraform está organizado em arquivos com responsabilidades definidas:

- `providers.tf` — provider Azure RM e versões
- `variables.tf` — parâmetros reutilizáveis (sem valores fixos)
- `main.tf` — recursos de infraestrutura
- `outputs.tf` — informações exportadas após o apply
- `terraform.tfvars.example` — modelo de configuração

### 3.2 Recursos provisionados

O `terraform apply` executa sequencialmente:

1. Criação do Resource Group na região `brazilsouth`
2. Criação da VNet e Subnet
3. Criação do NSG com regras de entrada para RDP, WinRM, HTTP e HTTPS
4. Alocação de IP Público estático
5. Criação da NIC associada à subnet, IP e NSG
6. Provisionamento da VM Windows Server 2022
7. Execução da extensão Custom Script para configurar WinRM HTTPS (porta 5986)

### 3.3 Outputs gerados

Após o apply, são exibidos:

- `public_ip_address` — IP para acesso HTTP e WinRM
- `vm_name` — nome da máquina virtual
- `admin_username` — usuário administrador
- `resource_group_name` — grupo de recursos
- `winrm_endpoint` — URL WinRM para Ansible
- `iis_url` — URL da aplicação

### 3.4 Boas práticas aplicadas

- Variáveis para todos os parâmetros configuráveis
- Tags padronizadas em todos os recursos
- Senhas marcadas como `sensitive`
- Arquivo `.tfvars` fora do versionamento (`.gitignore`)
- Código comentado e formatado (`terraform fmt`)

---

## 4. Funcionamento do Ansible

### 4.1 Estrutura

```
ansible/
├── playbook.yml          # Orquestração principal
├── inventory.ini         # Hosts (gerado do Terraform)
├── group_vars/windows.yml
└── roles/windows/
    ├── tasks/main.yml    # Instalação IIS + site
    ├── handlers/main.yml # Reinício do IIS
    └── templates/
        └── index.html.j2 # Página MobEAD
```

### 4.2 Conexão WinRM

O Ansible conecta à VM Windows via **WinRM HTTPS** na porta **5986**, utilizando autenticação NTLM. A extensão Terraform configura o WinRM automaticamente após a criação da VM.

### 4.3 Tarefas executadas

1. **Validação** — `win_ping` confirma conectividade
2. **IIS** — instalação do recurso Web-Server via `win_feature`
3. **Diretório** — criação de `C:\inetpub\wwwroot\mobead`
4. **Página HTML** — template Jinja2 com dados do projeto
5. **Site IIS** — configuração na porta 80 via PowerShell
6. **Serviços** — W3SVC e WAS com inicialização automática
7. **Firewall** — liberação das portas 80 e 443
8. **Validação** — requisição HTTP local retornando status 200

### 4.4 Página publicada

A página HTML contém:

- MobEAD
- Lucas Alves
- Engenharia DevOps
- Pipeline CI/CD
- Terraform, Ansible, Docker, Jenkins, SonarQube
- Data da implantação (gerada automaticamente)

---

## 5. Benefícios da IaC (Infrastructure as Code)

| Benefício | Descrição |
|-----------|-----------|
| **Reprodutibilidade** | Mesma infraestrutura criada quantas vezes necessário |
| **Versionamento** | Código Terraform/Ansible no GitHub com histórico |
| **Auditoria** | Mudanças rastreáveis via commits e `terraform plan` |
| **Redução de erros** | Elimina configuração manual propensa a falhas |
| **Velocidade** | Provisionamento em minutos vs. horas manuais |
| **Padronização** | Ambientes idênticos para dev, teste e produção |
| **Documentação viva** | O código é a documentação da infraestrutura |
| **Destruição segura** | `terraform destroy` remove tudo de forma controlada |

---

## 6. Benefícios da automação (Ansible)

| Benefício | Descrição |
|-----------|-----------|
| **Configuração idempotente** | Executar várias vezes produz o mesmo resultado |
| **Sem agente permanente** | WinRM nativo do Windows, sem instalar daemon |
| **Modularidade** | Roles reutilizáveis para outros projetos |
| **Templates** | Página HTML dinâmica com variáveis |
| **Integração** | Inventory gerado automaticamente do Terraform |
| **Validação** | Playbook inclui testes pós-configuração |

---

## 7. Resultados obtidos

Com a implementação completa, foi possível:

- Provisionar automaticamente **7 tipos de recursos** na Azure via Terraform
- Configurar **IIS** e publicar página web via Ansible sem intervenção manual
- Integrar o projeto IaC ao repositório MobEAD existente no GitHub
- Documentar todo o processo (README, relatório, comandos, evidências)
- Criar pipeline Jenkins opcional para automação end-to-end
- Validar funcionamento via script HTTP (`validate-iis.sh`)

### Métricas

| Métrica | Valor |
|---------|-------|
| Arquivos Terraform | 5 principais + exemplo |
| Recursos Azure | 8 (RG, VNet, Subnet, NSG, PIP, NIC, VM, Extension) |
| Portas liberadas | 3389, 5986, 80, 443 |
| Tasks Ansible | 10+ tarefas automatizadas |
| Tempo estimado apply | 5–10 minutos |
| Tempo estimado playbook | 3–5 minutos |

---

## 8. Conclusão

A atividade da Unidade 4 foi concluída com a implementação de uma solução completa de Infraestrutura como Código, utilizando **Terraform** para provisionamento na **Microsoft Azure** e **Ansible** para configuração automatizada de um servidor **Windows Server** com **IIS**.

O projeto demonstra a evolução natural de uma esteira DevOps madura: das Unidades 2 e 3, que automatizaram build, testes, qualidade e deploy em containers Docker, para a Unidade 4, que automatiza a própria infraestrutura em cloud.

A combinação Terraform + Ansible + GitHub representa o estado da arte em práticas DevOps, garantindo ambientes reprodutíveis, auditáveis e escaláveis — fundamentais para a Engenharia DevOps moderna.

O código está versionado em: **https://github.com/lucascei/MobEAD** (pasta `iac/`, branch `develop`).

---

*Relatório elaborado para entrega acadêmica — Engenharia DevOps, Unyleya.*
