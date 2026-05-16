# ==========================================
# 1. REDES (VPC, SUBREDES, RUTAS)
# ==========================================

resource "aws_vpc" "innovatech_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "innovatech-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.innovatech_vpc.id
  tags   = { Name = "innovatech-igw" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.innovatech_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = { Name = "innovatech-public-subnet" }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.innovatech_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = { Name = "innovatech-private-subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.innovatech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "innovatech-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================================
# 2. GRUPOS DE SEGURIDAD (SECURITY GROUPS)
# ==========================================

# SG Frontend (Público)
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "HTTP de internet y SSH"
  vpc_id      = aws_vpc.innovatech_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "innovatech-frontend-sg" }
}

# SG Backend (Privado)
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Acceso restringido solo desde el Frontend"
  vpc_id      = aws_vpc.innovatech_vpc.id

  # REQUISITO REGLA DE SEGURIDAD: Solo permite tráfico en el puerto de la API (3000) si viene del Front
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # SSH solo interno
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "innovatech-backend-sg" }
}

# ==========================================
# 3. SCRIPT DE INICIALIZACIÓN (DOCKER)
# ==========================================

locals {
  docker_script = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.p/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
  EOF
}

# ==========================================
# 4. INSTANCIAS EC2
# ==========================================

# Servidor Frontend (Público)
resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name               = var.key_name
  user_data              = local.docker_script

  tags = { Name = "innovatech-frontend-server" }
}

# Servidor Backend (Privado)
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_name
  user_data              = local.docker_script

  tags = { Name = "innovatech-backend-server" }
}