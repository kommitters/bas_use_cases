variable "do_token" {
  description = "The DigitalOcean API token."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.do_token) > 0
    error_message = "The do_token variable must be provided and non-empty."
  }
}

variable "pvt_key" {
  description = "The private SSH key for the DigitalOcean account."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "digitalocean_project" {
  description = "The name of the DigitalOcean project to use."
  type        = string
  default     = "BAS"
}

variable "database_password" {
  description = "The password for the bas database."
  type        = string
  default     = "DefaultPass!"
  sensitive   = true

  validation {
    condition     = var.database_password != "" && var.database_password != "DefaultPass!"
    error_message = "Please set a strong database_password and do not use the placeholder."
  }
}

variable "digital_ocean_ssh_key" {
  description = "The name of the SSH key to use for DigitalOcean."
  type        = string
}
