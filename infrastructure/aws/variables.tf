variable "aws_access_key" {
  description = "The AWS access key ID."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The AWS secret access key."
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "pvt_key" {
  description = "The private SSH key file path."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "aws_key_pair_name" {
  description = "The name of the AWS key pair to use for EC2 instances."
  type        = string
  sensitive   = true
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

variable "instance_type" {
  description = "The EC2 instance type to use."
  type        = string
  default     = "t2.micro"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.10.10.0/24"
}
