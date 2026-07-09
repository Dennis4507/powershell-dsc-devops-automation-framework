# main.tf
#
# Creates one Azure Virtual Machine that becomes a cloud copy of the same
# control plane this whole framework already manages locally, plus a
# storage account to hold the compiled DSC checklist files, and the Azure
# VM DSC Extension that actually runs windows/ControlPlane.ps1 on the VM
# once it starts up.
#
# STATUS: written to show the intended shape. This has not been run with
# "terraform apply" yet, since doing so creates real, billed Azure
# resources and needs real Azure credentials. Review every value before
# ever running this for real - see docs/azure-vm-setup.md.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- Checklist item 1: a resource group must exist to hold everything else ---
resource "azurerm_resource_group" "control_plane" {
  name     = "${var.project_name}-rg"
  location = var.location
}

# --- Checklist item 2: a private network for the VM to live inside ---
resource "azurerm_virtual_network" "control_plane" {
  name                = "${var.project_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.control_plane.location
  resource_group_name = azurerm_resource_group.control_plane.name
}

resource "azurerm_subnet" "control_plane" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.control_plane.name
  virtual_network_name = azurerm_virtual_network.control_plane.name
  address_prefixes     = ["10.0.1.0/24"]
}

# --- Checklist item 3: a public IP address, so the VM can actually be
#     reached in order to manage it ---
resource "azurerm_public_ip" "control_plane" {
  name                = "${var.project_name}-pip"
  location            = azurerm_resource_group.control_plane.location
  resource_group_name = azurerm_resource_group.control_plane.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "control_plane" {
  name                = "${var.project_name}-nic"
  location            = azurerm_resource_group.control_plane.location
  resource_group_name = azurerm_resource_group.control_plane.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.control_plane.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.control_plane.id
  }
}

# --- Checklist item 4: the actual Windows virtual machine ---
resource "azurerm_windows_virtual_machine" "control_plane" {
  name                = "${var.project_name}-vm"
  resource_group_name = azurerm_resource_group.control_plane.name
  location            = azurerm_resource_group.control_plane.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.control_plane.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

# --- Checklist item 5: a storage account to hold the compiled DSC
#     checklist files (the .mof files), so the VM DSC Extension below
#     has somewhere to fetch them from ---
resource "azurerm_storage_account" "dsc" {
  name                     = "${var.project_name}dscstorage"
  resource_group_name      = azurerm_resource_group.control_plane.name
  location                 = azurerm_resource_group.control_plane.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "dsc_mof" {
  name                  = "dsc-mof"
  storage_account_id    = azurerm_storage_account.dsc.id
  container_access_type = "private"
}

# --- Checklist item 6: the Azure VM DSC Extension - this is the piece
#     that actually applies windows/ControlPlane.ps1 on the VM once it
#     boots, the cloud equivalent of running Apply-ControlPlane.ps1 by
#     hand ---
resource "azurerm_virtual_machine_extension" "dsc" {
  name                       = "${var.project_name}-dsc-extension"
  virtual_machine_id         = azurerm_windows_virtual_machine.control_plane.id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.83"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    configuration = {
      url      = "REPLACE_WITH_STORAGE_URL/ControlPlane.ps1.zip"
      script   = "ControlPlane.ps1"
      function = "ControlPlane"
    }
  })

  depends_on = [azurerm_storage_container.dsc_mof]
}
