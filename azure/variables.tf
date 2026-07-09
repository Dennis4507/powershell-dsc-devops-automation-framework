# variables.tf
#
# The inputs this Terraform configuration needs. Think of this the same
# way as windows/ControlPlane.config.psd1 - it is the answer sheet that
# fills in the blanks in main.tf.

variable "location" {
  description = "The Azure region to create everything in, for example westeurope"
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "A short name used as the start of every resource's name, for example controlplane"
  type        = string
  default     = "controlplane"
}

variable "vm_size" {
  description = "The Azure VM size to use. Standard_B2s is a small, cheap size that can be stopped when not needed - a good fit for a control plane that is not a heavy, always-busy server."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "The local administrator account created on the VM"
  type        = string
  default     = "controlplaneadmin"
}

variable "admin_password" {
  description = "The local administrator password for the VM. Never write a real password here, and never put one in a .tfvars file that gets saved into source control. Pass this value in at the moment you run Terraform instead, for example using the TF_VAR_admin_password environment variable, or a proper secret store."
  type        = string
  sensitive   = true
}
