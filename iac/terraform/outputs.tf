# =============================================================================
# Outputs Terraform - MobEAD IaC
# =============================================================================

output "resource_group_name" {
  description = "Nome do Resource Group criado"
  value       = azurerm_resource_group.mobead.name
}

output "location" {
  description = "Região Azure utilizada"
  value       = azurerm_resource_group.mobead.location
}

output "vm_name" {
  description = "Nome da máquina virtual"
  value       = azurerm_windows_virtual_machine.mobead.name
}

output "vm_id" {
  description = "ID da máquina virtual"
  value       = azurerm_windows_virtual_machine.mobead.id
}

output "public_ip_address" {
  description = "Endereço IP público da VM"
  value       = azurerm_public_ip.mobead.ip_address
}

output "admin_username" {
  description = "Usuário administrador da VM"
  value       = var.admin_username
}

output "vnet_name" {
  description = "Nome da Virtual Network"
  value       = azurerm_virtual_network.mobead.name
}

output "subnet_name" {
  description = "Nome da Subnet"
  value       = azurerm_subnet.mobead.name
}

output "nsg_name" {
  description = "Nome do Network Security Group"
  value       = azurerm_network_security_group.mobead.name
}

output "winrm_endpoint" {
  description = "Endpoint WinRM HTTPS para Ansible"
  value       = "https://${azurerm_public_ip.mobead.ip_address}:5986/wsman"
}

output "rdp_connection" {
  description = "String de conexão RDP"
  value       = "mstsc /v:${azurerm_public_ip.mobead.ip_address}"
}

output "iis_url" {
  description = "URL HTTP da aplicação (após Ansible)"
  value       = "http://${azurerm_public_ip.mobead.ip_address}"
}

output "ansible_inventory_snippet" {
  description = "Trecho para inventory Ansible (substitua a senha)"
  value       = <<-EOT
    [windows]
    ${var.vm_name} ansible_host=${azurerm_public_ip.mobead.ip_address}

    [windows:vars]
    ansible_user=${var.admin_username}
    ansible_password=SUA_SENHA_AQUI
    ansible_connection=winrm
    ansible_winrm_transport=ntlm
    ansible_winrm_server_cert_validation=ignore
    ansible_port=5986
    ansible_winrm_scheme=https
  EOT
  sensitive = true
}
