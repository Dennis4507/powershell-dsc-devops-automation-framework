# outputs.tf
#
# The values Terraform prints back once it finishes - the pieces of
# information you actually need afterward to connect to or reference the
# VM it just created.

output "resource_group_name" {
  description = "The resource group everything in this configuration lives inside"
  value       = azurerm_resource_group.control_plane.name
}

output "vm_name" {
  description = "The name of the control plane VM"
  value       = azurerm_windows_virtual_machine.control_plane.name
}

output "vm_public_ip" {
  description = "The public IP address of the control plane VM"
  value       = azurerm_public_ip.control_plane.ip_address
}
