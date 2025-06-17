
# Infrastructure Documentation

## Using Digital Ocean

This infrastructure deploys two droplets, one for the BAS instance and other for the PostgreSQL database server.

## Prerequisites

1. Terraform installed on your local machine.
2. A Digital Ocean account with an API token.
3. A registered SSH key in your Digital Ocean account. Register it [here](https://cloud.digitalocean.com/account/security).

```bash
# Set required environment variables
export TF_LOG=INFO
export DO_PAT=dop_v1_...
```

### Deployment Commands

Initialize Terraform

```bash
terraform init 
```

#### Plan deployment

Re-run this command when you change the infrastructure configuration

```bash
terraform plan -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key"
```

By default, the droplets are set to be created under the BAS project, you can specify a different project by adding
`-var "digitalocean_project=Your-Project-Name"` flag to the commands.

#### Deploy infrastructure

Remember to replace My-Personal-Key with your actual key you registered on the digital ocean dashboard. Also, use a secure database password

```bash
terraform apply -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key" -var "pvt_key=~/.ssh/id_rsa" -var "database_password=my-password"
```

Sometimes it may be necessary to refresh the state after making changes outside terraform or if the initial deployment fails. You can do this with the following command:

```bash
# Refresh state (if needed)
terraform refresh -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key"
```

#### Destroy Infrastructure

If you were testing and want to remove the infrastructure, you can use the following command.

> [!CAUTION]
> This will destroy all resources created by Terraform and cannot be undone. Make sure you have backups of any important data.

```bash
terraform destroy -var "do_token=${DO_PAT}" -var "digital_ocean_ssh_key=My-Personal-Key"
```

## Using Amazon Web Services (AWS)
