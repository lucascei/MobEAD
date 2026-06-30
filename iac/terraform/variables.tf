# =============================================================================
# Variáveis gerais do projeto MobEAD IaC - Lucas Alves
# =============================================================================

variable "project_name" {
  description = "Nome do projeto utilizado como prefixo dos recursos"
  type        = string
  default     = "mobead"
}

variable "student_name" {
  description = "Nome do aluno para tags e documentação"
  type        = string
  default     = "Lucas Alves"
}

variable "environment" {
  description = "Ambiente (dev, prod, iac)"
  type        = string
  default     = "iac"
}

variable "location" {
  description = "Região Azure para provisionamento"
  type        = string
  default     = "brazilsouth"
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "rg-mobead-iac-lucas-alves"
}

variable "vnet_address_space" {
  description = "Espaço de endereçamento da Virtual Network"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Prefixo CIDR da subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "vm_name" {
  description = "Nome da máquina virtual Windows"
  type        = string
  default     = "vm-mobead-iac-lucas-alves"
}

variable "vm_size" {
  description = "Tamanho da VM Azure (Windows Server)"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Usuário administrador local da VM Windows"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Senha do administrador (mín. 12 caracteres, complexa)"
  type        = string
  sensitive   = true
}

variable "windows_sku" {
  description = "SKU do Windows Server (2019 ou 2022)"
  type        = string
  default     = "2022-Datacenter"
}

variable "os_disk_size_gb" {
  description = "Tamanho do disco OS em GB"
  type        = number
  default     = 128
}

variable "allowed_source_ips" {
  description = "IPs de origem permitidos no NSG (use seu IP público/32)"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos"
  type        = map(string)
  default = {
    Projeto    = "MobEAD"
    Aluno      = "Lucas Alves"
    Disciplina = "Engenharia DevOps"
    Unidade    = "IaC - Unidade 4"
    Gerenciado = "Terraform"
  }
}
