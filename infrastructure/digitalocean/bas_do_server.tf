resource "digitalocean_droplet" "bas" {
  image = "ubuntu-24-10-x64"
  name = "bas"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.bas-network.id
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    timeout = "2m"
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    script = "../common/scripts/install_docker_on_ubuntu.sh"
  } 
}

resource "digitalocean_project_resources" "bas_server_assignment" {
  project   = data.digitalocean_project.bas_project.id
  resources = [digitalocean_droplet.bas.urn]
}

resource "null_resource" "configure-bas-server" {
  triggers = {
    bas_instance_id     = digitalocean_droplet.bas.id
    database_instance_id = digitalocean_droplet.bas-database.id
    database_password    = var.database_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'DB_PORT=8001' >> /etc/environment",
      "echo 'DB_HOST=${digitalocean_droplet.bas-database.ipv4_address_private}' >> /etc/environment",
      "echo 'PGPASSWORD=${var.database_password}' >> /etc/environment"
    ]
  }

  connection {
    host = digitalocean_droplet.bas.ipv4_address
    user = "root"
    type = "ssh"
    timeout = "2m"
    private_key = file(var.private_key_path)
  }
}
