# BAS Server EC2 Instance - equivalent to DigitalOcean droplet
resource "aws_instance" "bas" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.terraform.key_name
  vpc_security_group_ids      = [aws_security_group.bas_server_sg.id]
  subnet_id                   = aws_subnet.bas_public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "bas"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"  # Ubuntu AMI uses ubuntu user, not root
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    script = "../common/scripts/install_docker_on_ubuntu.sh"
  }
}

# Configure BAS server with database connection credentials
resource "null_resource" "configure_bas_server" {
  provisioner "remote-exec" {
    inline = [
      "echo 'DB_PORT=8001' | sudo tee -a /etc/environment",
      "echo 'DB_HOST=${aws_instance.bas_database.private_ip}' | sudo tee -a /etc/environment",
      "echo 'PGPASSWORD=${var.database_password}' | sudo tee -a /etc/environment"
    ]
  }

  connection {
    type        = "ssh"
    host        = aws_instance.bas.public_ip
    user        = "ubuntu"
    private_key = file(var.pvt_key)  
    timeout     = "2m"
  }

  depends_on = [aws_instance.bas_database]
}
