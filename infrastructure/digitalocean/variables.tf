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
  sensitive   = true

  validation {
    condition     = length(var.pvt_key) > 0
    error_message = "The pvt_key variable must be provided and non-empty."
  }
}

variable "digitalocean_project" {
  description = "The name of the DigitalOcean project to use."
  type        = string
  default     = "BAS"
}

variable "database_password" {
  description = "The password for the bas database."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.database_password) >= 8
    error_message = "The database_password must be at least 8 characters long."
  }
}

variable "digital_ocean_ssh_key" {
  description = "The name of the SSH key to use for DigitalOcean."
  type        = string
}
