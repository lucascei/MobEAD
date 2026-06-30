# MobEAD — Infraestrutura como Código (IaC)

**Aluno:** Lucas Alves  
**Disciplina:** Engenharia DevOps — Unyleya  
**Unidade:** 4 — Infraestrutura como Código (Terraform + Ansible)  
**Continuação:** Unidades 2 e 3 (CI/CD com Jenkins, SonarQube, Docker)

**Repositório:** https://github.com/lucascei/MobEAD (branch `develop`)

---

## Objetivo

Provisionar automaticamente uma infraestrutura em **Microsoft Azure** utilizando **Terraform** e configurar uma máquina virtual **Windows Server** com **IIS** e página web MobEAD utilizando **Ansible**, integrando com o projeto CI/CD desenvolvido nas unidades anteriores.

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                        Microsoft Azure                          │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Resource Group: rg-mobead-iac-lucas-alves     │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │           Virtual Network (10.10.0.0/16)             │  │  │
│  │  │  ┌───────────────────────────────────────────────┐  │  │  │
│  │  │  │  Subnet (10.10.1.0/24)                         │  │  │  │
│  │  │  │  ┌─────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │  VM Windows Server 2022                  │  │  │  │  │
│  │  │  │  │  - IIS (porta 80/443)                    │  │  │  │  │
│  │  │  │  │  - WinRM HTTPS (5986)                    │  │  │  │  │
│  │  │  │  │  - RDP (3389)                            │  │  │  │  │
│  │  │  │  │  - Página HTML MobEAD                    │  │  │  │  │
│  │  │  │  └─────────────────────────────────────────┘  │  │  │  │
│  │  │  │         ▲ NIC + IP Público + NSG              │  │  │  │
│  │  │  └───────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         ▲                                    ▲
         │ Terraform (provisiona)             │ Ansible (configura)
         │                                    │
    ┌────┴────┐                          ┌────┴────┐
    │  DevOps │                          │  WinRM  │
    │ Engineer│                          │  HTTPS  │
    └─────────┘                          └─────────┘
```

### Fluxo de execução

```
1. terraform init / validate / plan / apply  →  Cria infraestrutura Azure
2. scripts/generate-inventory.sh             →  Gera inventory Ansible
3. ansible-playbook playbook.yml             →  Instala IIS + publica página
4. scripts/validate-iis.sh                   →  Valida HTTP 200
```

### Integração com CI/CD (Unidades 2 e 3)

| Componente | Unidade anterior | Esta unidade (IaC) |
|------------|------------------|---------------------|
| GitHub | Repositório MobEAD | Versionamento Terraform + Ansible |
| Jenkins | Pipeline CI/CD DEV/PROD | Pipeline IaC opcional (`Jenkinsfile`) |
| Docker | Containers locais | VM Windows na Cloud |
| SonarQube | Análise de código | Mantido no projeto principal |
| Deploy | DEV:8081 / PROD:8082 | IIS na Azure (HTTP 80) |

---

## Estrutura do projeto

```
iac/
├── terraform/              # Infraestrutura Azure (IaC)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   └── README.md
├── ansible/                # Configuração do servidor Windows
│   ├── playbook.yml
│   ├── inventory.ini.example
│   ├── ansible.cfg
│   ├── requirements.yml
│   ├── group_vars/windows.yml
│   ├── host_vars/
│   └── roles/windows/
├── scripts/
│   ├── generate-inventory.sh
│   └── validate-iis.sh
├── docs/
├── evidencias/
│   └── MODELO-EVIDENCIAS.md
├── Jenkinsfile             # Pipeline IaC opcional
├── README.md
├── RELATORIO.md
├── comandos.txt
└── .gitignore
```

---

## Pré-requisitos

### Ferramentas locais

| Ferramenta | Versão mínima | Instalação |
|------------|---------------|------------|
| Terraform | >= 1.5 | https://developer.hashicorp.com/terraform/downloads |
| Azure CLI | latest | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |
| Ansible | >= 2.14 | `pip install ansible pywinrm` |
| Git | latest | já instalado |

### Coleções Ansible

```bash
cd iac/ansible
ansible-galaxy collection install -r requirements.yml
```

### Conta Azure

- Subscription ativa
- Permissões para criar Resource Groups, VMs e redes
- Créditos de estudante Azure (recomendado)

---

## Configuração Azure

### 1. Login

```bash
az login
az account list --output table
az account set --subscription "SUA_SUBSCRIPTION_ID"
```

### 2. Variáveis de ambiente (opcional — Service Principal)

```bash
export ARM_SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_CLIENT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export ARM_CLIENT_SECRET="sua-chave-secreta"
```

---

## Terraform — Como executar

```bash
cd iac/terraform

# 1. Configurar variáveis
cp terraform.tfvars.example terraform.tfvars
# Edite admin_password com senha forte

# 2. Inicializar
terraform init

# 3. Validar sintaxe
terraform validate

# 4. Formatar código
terraform fmt -recursive

# 5. Planejar mudanças
terraform plan -out=tfplan

# 6. Aplicar (criar infraestrutura)
terraform apply tfplan

# 7. Ver outputs (IP público, nome VM, etc.)
terraform output
```

### Recursos criados

- Resource Group
- Virtual Network + Subnet
- Network Security Group (portas 3389, 5986, 80, 443)
- IP Público (estático)
- Network Interface
- VM Windows Server 2022
- Extensão WinRM para Ansible

---

## Ansible — Como executar

> Aguarde 3–5 minutos após `terraform apply` para a VM e WinRM ficarem prontos.

```bash
# 1. Gerar inventory a partir do Terraform
./iac/scripts/generate-inventory.sh

# 2. Executar playbook
cd iac/ansible
ansible-playbook -i inventory.ini playbook.yml

# 3. Validar IIS
../scripts/validate-iis.sh
```

### O que o playbook faz

1. Conecta via WinRM HTTPS (porta 5986)
2. Valida conexão (`win_ping`)
3. Instala IIS (Web-Server feature)
4. Cria diretório e publica página HTML MobEAD
5. Configura site IIS na porta 80
6. Habilita serviços W3SVC e WAS (inicialização automática)
7. Abre portas 80/443 no firewall Windows
8. Valida resposta HTTP

### Acessar a aplicação

Após o playbook:

```
http://<IP_PUBLICO>
```

O IP está em `terraform output public_ip_address`.

---

## Como destruir o ambiente

```bash
cd iac/terraform
terraform destroy
```

Confirme com `yes` quando solicitado. Todos os recursos Azure serão removidos.

---

## Pipeline Jenkins (opcional)

Arquivo: `iac/Jenkinsfile`

```
Checkout → Terraform Init → Validate → Plan → Apply
    → Gerar Inventory → Ansible Playbook → Validar IIS
```

**Credenciais necessárias no Jenkins:**
- `azure-subscription-id` — ID da subscription Azure
- `azure-vm-password` — senha da VM (mesma do terraform.tfvars)

---

## Evidências

Consulte `evidencias/MODELO-EVIDENCIAS.md` para o checklist completo de prints.

---

## Documentação adicional

- `RELATORIO.md` — Relatório acadêmico completo
- `comandos.txt` — Todos os comandos utilizados
- `../README.md` — Projeto CI/CD (Unidades 2 e 3)

---

## Autor

**Lucas Alves** — Engenharia DevOps, Unyleya
