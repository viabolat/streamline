variable "hub" {
  default = "global"
}

variable "stage" {
  type = string
}

variable "module_name" {
  type = string
}

variable "source_dataset_type" {
  default = "cdh"
}

variable "enable_alerts" {
  type    = bool
  default = false
}

variable "pseudonymizer_api_key_name" {
  type        = string
  default     = null
  description = "Name of the secret containing the pseudonymizer API key."
}

variable "vpc_name" {
  type = string
}

variable "vpc_subnet_index" {
  type = number
}

locals {
  custom_files_folder_name_path = abspath("../../../code")

  tags = {
    Name = "vehicle_key_data_pre_gdpr"
  }
}


