variable "do_token" {
  description = "The DigitalOcean API token."
  type        = string
  sensitive   = true
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
  default     = "ChangeMeASAP!"
  sensitive   = true
}

variable "digital_ocean_ssh_key" {
  description = "The name of the SSH key to use for DigitalOcean."
  type        = string
}
