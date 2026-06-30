#!/bin/bash
# Gera inventory.ini a partir dos outputs do Terraform
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IAC_DIR="$(dirname "$SCRIPT_DIR")"
TF_DIR="${IAC_DIR}/terraform"
ANSIBLE_DIR="${IAC_DIR}/ansible"
INVENTORY="${ANSIBLE_DIR}/inventory.ini"

cd "${TF_DIR}"

PUBLIC_IP=$(terraform output -raw public_ip_address 2>/dev/null || echo "")
VM_NAME=$(terraform output -raw vm_name 2>/dev/null || echo "vm-mobead-iac-lucas-alves")
ADMIN_USER=$(terraform output -raw admin_username 2>/dev/null || echo "azureadmin")

if [ -z "${PUBLIC_IP}" ]; then
  echo "ERRO: Execute 'terraform apply' antes de gerar o inventory."
  exit 1
fi

read -rsp "Senha do administrador Windows (${ADMIN_USER}): " ADMIN_PASS
echo ""

cat > "${INVENTORY}" <<EOF
# Gerado automaticamente em $(date -Iseconds)
[windows]
${VM_NAME} ansible_host=${PUBLIC_IP}

[windows:vars]
ansible_user=${ADMIN_USER}
ansible_password=${ADMIN_PASS}
ansible_connection=winrm
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
ansible_port=5986
ansible_winrm_scheme=https
EOF

chmod 600 "${INVENTORY}"
echo ">>> Inventory gerado: ${INVENTORY}"
echo ">>> Host: ${PUBLIC_IP}"
