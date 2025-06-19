resource "digitalocean_droplet" "bas-database" {
  image = "ubuntu-24-10-x64"
  name = "bas-database"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  vpc_uuid = digitalocean_vpc.bas-network.id
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    timeout = "2m"
    private_key = file(var.pvt_key)
  }

  user_data = templatefile("../common/templates/env_vars.tftpl", {
    postgres_password = var.database_password
  })

  provisioner "remote-exec" {
      script = "../common/scripts/install_docker_on_ubuntu.sh"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /db"]
  }

  provisioner "file" {
    source      = "../common/scripts/db_docker-compose.yml"
    destination = "/db/docker-compose.yml"
  }

  provisioner "file" {
    source = "../common/scripts/create_basic_db_structure.sql"
    destination = "/db/create_basic_db_structure.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "docker network create db_net || true",
      "cd /db && docker-compose up -d --remove-orphans"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "docker exec -i bas_db psql -U postgres -f /db/create_basic_db_structure.sql"
    ]
  }
}

resource "digitalocean_project_resources" "bas_db_assignment" {
  project   = data.digitalocean_project.bas_project.id
  resources = [digitalocean_droplet.bas-database.urn]
}
