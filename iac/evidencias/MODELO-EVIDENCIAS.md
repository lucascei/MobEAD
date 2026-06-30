# Modelo de Evidências — Unidade 4 IaC (Terraform + Ansible)

**Aluno:** Lucas Alves  
**Projeto:** MobEAD — Infraestrutura como Código  
**Cloud:** Microsoft Azure

Salve os prints na pasta `evidencias/` com os nomes sugeridos.

---

## Checklist de evidências

| # | Evidência | Arquivo sugerido | Status |
|---|-----------|------------------|--------|
| 1 | Código Terraform (estrutura de arquivos) | `01-codigo-terraform.png` | [ ] |
| 2 | Código Ansible (estrutura de arquivos) | `02-codigo-ansible.png` | [ ] |
| 3 | Repositório GitHub com pasta `iac/` | `03-repositorio-github.png` | [ ] |
| 4 | `terraform init` executado | `04-terraform-init.png` | [ ] |
| 5 | `terraform validate` sem erros | `05-terraform-validate.png` | [ ] |
| 6 | `terraform plan` com recursos listados | `06-terraform-plan.png` | [ ] |
| 7 | `terraform apply` concluído | `07-terraform-apply.png` | [ ] |
| 8 | Outputs do Terraform (IP, VM, RG) | `08-terraform-outputs.png` | [ ] |
| 9 | Playbook Ansible executando | `09-ansible-playbook.png` | [ ] |
| 10 | IIS instalado (serviços W3SVC) | `10-iis-instalado.png` | [ ] |
| 11 | Página HTML funcionando no navegador | `11-pagina-html.png` | [ ] |
| 12 | VM criada no Portal Azure | `12-vm-azure-portal.png` | [ ] |
| 13 | IP Público no Portal Azure | `13-ip-publico-azure.png` | [ ] |
| 14 | Resource Group com todos os recursos | `14-resource-group-azure.png` | [ ] |
| 15 | Log final do Terraform (Apply complete) | `15-log-terraform.png` | [ ] |
| 16 | Log final do Ansible (PLAY RECAP ok) | `16-log-ansible.png` | [ ] |

---

## 1. Código Terraform

**O que capturar:** IDE ou terminal mostrando a pasta `iac/terraform/` com `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`.

---

## 2. Código Ansible

**O que capturar:** Estrutura `iac/ansible/` com `playbook.yml`, `roles/windows/`, `group_vars/`.

---

## 3. Repositório GitHub

**O que capturar:** https://github.com/lucascei/MobEAD — pasta `iac/` visível na branch `develop`.

---

## 4–8. Terraform

**Comandos para evidenciar:**

```bash
cd iac/terraform
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

**Prints:** terminal com cada comando e resultado. No `apply`, mostrar `Apply complete!`. No `output`, mostrar IP público e nome da VM.

---

## 9–11. Ansible e IIS

```bash
./iac/scripts/generate-inventory.sh
cd iac/ansible
ansible-playbook -i inventory.ini playbook.yml
./iac/scripts/validate-iis.sh
```

**Print do navegador:** `http://<IP_PUBLICO>/` mostrando página com MobEAD, Lucas Alves, Engenharia DevOps, etc.

---

## 12–14. Portal Azure

Acesse https://portal.azure.com

- **VM:** Virtual Machines → `vm-mobead-iac-lucas-alves`
- **IP:** Public IP addresses → `mobead-pip`
- **RG:** Resource groups → `rg-mobead-iac-lucas-alves` (todos os recursos)

---

## 15–16. Logs finais

**Terraform:** últimas linhas com `Apply complete! Resources: X added`

**Ansible:** `PLAY RECAP` com `ok=N` e `failed=0`

---

## Dicas

1. Organize prints na ordem do checklist
2. Inclua URL/barra de endereço quando possível
3. Para Azure, mostre o nome do Resource Group e região `Brazil South`
4. Após as evidências, execute `terraform destroy` para não gerar custos

---

## Comandos de verificação rápida

```bash
terraform output public_ip_address
curl http://$(cd iac/terraform && terraform output -raw public_ip_address)/
az vm list -g rg-mobead-iac-lucas-alves -o table
```
