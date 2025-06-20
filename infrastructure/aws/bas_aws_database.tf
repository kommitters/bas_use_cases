# BAS Database EC2 Instance - equivalent to DigitalOcean database droplet
resource "aws_instance" "bas_database" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = data.aws_key_pair.terraform.key_name
  vpc_security_group_ids      = [aws_security_group.bas_database_sg.id]
  subnet_id                   = aws_subnet.bas_public_subnet.id
  associate_public_ip_address = true

  # Use cloud-init to set up environment variables
  user_data = templatefile("../common/templates/env_vars.tftpl", {
    postgres_password = var.database_password
    env_file_path = "/home/ubuntu/db/.env"
  })

  tags = {
    Name = "bas-database"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"  # Ubuntu AMI uses ubuntu user, not root
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  # Install Docker
  provisioner "remote-exec" {
    script = "../common/scripts/install_docker_on_ubuntu.sh"
  }

  # Create database directory
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/db",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/db"
    ]
  }

  # Copy docker-compose file
  provisioner "file" {
    source      = "../common/scripts/db_docker-compose.yml"
    destination = "/home/ubuntu/db/docker-compose.yml"
  }

  # Copy database schema file
  provisioner "file" {
    source      = "../common/scripts/create_basic_db_structure.sql"
    destination = "/home/ubuntu/db/create_basic_db_structure.sql"
  }

  # Start PostgreSQL container
  provisioner "remote-exec" {
    inline = [
      "sudo docker network create db_net || true",
      "cd /home/ubuntu/db && sudo chown -R ubuntu:ubuntu .",
      "cd /home/ubuntu/db && sudo -E docker-compose up -d --remove-orphans"
    ]
  }

  # Initialize database schema
  provisioner "remote-exec" {
    inline = [
      "sleep 12",  # Wait for PostgreSQL to be ready
      "sudo docker exec -i bas_db psql -U postgres -f /tmp/db/create_basic_db_structure.sql"
    ]
  }
}
