# =============================================================================
# MobEAD IaC - Infraestrutura Azure com Terraform
# Aluno: Lucas Alves | Engenharia DevOps - Unyleya
# =============================================================================

locals {
  common_tags = merge(var.tags, {
    Ambiente = var.environment
  })
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "mobead" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Rede Virtual e Subnet
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "mobead" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.mobead.location
  resource_group_name = azurerm_resource_group.mobead.name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "mobead" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.mobead.name
  virtual_network_name = azurerm_virtual_network.mobead.name
  address_prefixes     = [var.subnet_address_prefix]
}

# -----------------------------------------------------------------------------
# IP Público
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "mobead" {
  name                = "${var.project_name}-pip"
  location            = azurerm_resource_group.mobead.location
  resource_group_name = azurerm_resource_group.mobead.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# -----------------------------------------------------------------------------
# Network Security Group (NSG)
# Portas: 3389 RDP | 5986 WinRM HTTPS | 80 HTTP | 443 HTTPS
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "mobead" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.mobead.location
  resource_group_name = azurerm_resource_group.mobead.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.allowed_source_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-WinRM-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefixes    = var.allowed_source_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.allowed_source_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowed_source_ips
    destination_address_prefix = "*"
  }
}

# -----------------------------------------------------------------------------
# Interface de Rede (NIC)
# -----------------------------------------------------------------------------
resource "azurerm_network_interface" "mobead" {
  name                = "${var.project_name}-nic"
  location            = azurerm_resource_group.mobead.location
  resource_group_name = azurerm_resource_group.mobead.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mobead.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mobead.id
  }
}

resource "azurerm_network_interface_security_group_association" "mobead" {
  network_interface_id      = azurerm_network_interface.mobead.id
  network_security_group_id = azurerm_network_security_group.mobead.id
}

# -----------------------------------------------------------------------------
# Máquina Virtual Windows Server
# -----------------------------------------------------------------------------
resource "azurerm_windows_virtual_machine" "mobead" {
  name                = var.vm_name
  location            = azurerm_resource_group.mobead.location
  resource_group_name = azurerm_resource_group.mobead.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = local.common_tags

  network_interface_ids = [
    azurerm_network_interface.mobead.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_sku
    version   = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true
}

# -----------------------------------------------------------------------------
# Extensão: Configurar WinRM HTTPS (porta 5986) para Ansible
# -----------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "winrm" {
  name                       = "configure-winrm-ansible"
  virtual_machine_id         = azurerm_windows_virtual_machine.mobead.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iwr -useb https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 | iex}\""
  })

  depends_on = [azurerm_windows_virtual_machine.mobead]
}
