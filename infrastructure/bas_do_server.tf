resource "digitalocean_droplet" "bas" {
  image = "ubuntu-24-10-x64"
  name = "bas"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    timeout = "2m"
    private_key = file(var.pvt_key)
  }

  provisioner "remote-exec" {
    script = "scripts/install_docker_on_ubuntu.sh"
  } 
}

resource "digitalocean_project_resources" "bas_server_assignment" {
  project   = data.digitalocean_project.bas_project.id
  resources = [digitalocean_droplet.bas.urn]
}
