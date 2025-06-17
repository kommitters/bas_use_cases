terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

variable "pvt_key" {
  description = "The private SSH key for the DigitalOcean account."
  type        = string
  default     = "~/.ssh/id_rsa"
  sensitive   = true
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

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = var.digital_ocean_ssh_key
}

data "digitalocean_project" "bas_project" {
  name = var.digitalocean_project
}
