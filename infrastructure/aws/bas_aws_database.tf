# BAS Database EC2 Instance - equivalent to DigitalOcean database droplet
resource "aws_instance" "bas_database" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.terraform.key_name
  vpc_security_group_ids      = [aws_security_group.bas_database_sg.id]
  subnet_id                   = aws_subnet.bas_public_subnet.id
  associate_public_ip_address = true
  get_password_data           = false
  source_dest_check           = true
  user_data_replace_on_change = false

  # Use cloud-init to set up environment variables
  user_data = templatefile("../common/templates/env_vars.tftpl", {
    postgres_password = var.database_password
    env_file_path = "/home/ubuntu/db/.env"
  })

  tags = {
    Name = "bas-database"
  }

  # Wait for instance to be ready
  provisioner "remote-exec" {
    inline = ["echo 'Instance is ready'"]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      timeout     = "5m"
      agent       = false
    }
  }

  # Install Docker
  provisioner "remote-exec" {
    script = "../common/scripts/install_docker_on_ubuntu.sh"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      timeout     = "10m"
      agent       = false
    }
  }

  # Create database directory
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/db",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/db"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      timeout     = "5m"
      agent       = false
    }
  }

  # Copy docker-compose file
  provisioner "file" {
    source      = "../common/scripts/db_docker-compose.yml"
    destination = "/home/ubuntu/db/docker-compose.yml"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      timeout     = "5m"
      agent       = false
    }
  }

  # Copy database schema file
  provisioner "file" {
    source      = "../common/scripts/create_basic_db_structure.sql"
    destination = "/home/ubuntu/db/create_basic_db_structure.sql"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      timeout     = "5m"
      agent       = false
    }
  }

  # Start PostgreSQL container
  provisioner "remote-exec" {
    inline = [
      "sudo docker network create db_net || true",
      "cd /home/ubuntu/db && sudo chown -R ubuntu:ubuntu .",
      "cd /home/ubuntu/db && sudo -E docker-compose up -d --remove-orphans"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      timeout     = "10m"
      agent       = false
    }
  }

  # Initialize database schema
  provisioner "remote-exec" {
    inline = [
      "sleep 12",  # Wait for PostgreSQL to be ready
      "sudo docker exec -i bas_db psql -U postgres -f /tmp/db/create_basic_db_structure.sql"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      timeout     = "10m"
      agent       = false
    }
  }
}
