
## Digital Ocean

```bash
terraform init 
```

```bash
export TF_LOG=1
export DIGITALOCEAN_SSH_KEY=Jhon-Doe
export DO_PAT=dop_v1_...
```


```bash
terraform plan -var "do_token=${DO_PAT}" -var "pvt_key=$HOME/.ssh/digital_ocean_key"
```