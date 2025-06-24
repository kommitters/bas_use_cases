# BAS Server EC2 Instance - equivalent to DigitalOcean droplet
resource "aws_instance" "bas" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.terraform.key_name
  vpc_security_group_ids      = [aws_security_group.bas_server_sg.id]
  subnet_id                   = aws_subnet.bas_public_subnet.id
  associate_public_ip_address = true
  get_password_data           = false
  source_dest_check           = true
  user_data_replace_on_change = false

  tags = {
    Name = "bas"
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
}

# Configure BAS server with database connection credentials
resource "null_resource" "configure_bas_server" {
  triggers = {
    bas_instance_id     = aws_instance.bas.id
    database_instance_id = aws_instance.bas_database.id
    database_password    = var.database_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'DB_PORT=8001' | sudo tee -a /etc/environment",
      "echo 'DB_HOST=${aws_instance.bas_database.private_ip}' | sudo tee -a /etc/environment",
      "echo 'PGPASSWORD=${var.database_password}' | sudo tee -a /etc/environment"
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.bas.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)  
      timeout     = "5m"
      agent       = false
    }
  }

  depends_on = [aws_instance.bas_database]
}
