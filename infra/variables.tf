variable "aws_region" {
  type        = string
  description = "Región de AWS para desplegar"
}

variable "vpc_cidr" {
  type        = string
  description = "Bloque CIDR para la VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Bloque CIDR para la subred pública (Frontend)"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Bloque CIDR para la subred privada (Backend)"
}

variable "ami_id" {
  type        = string
  description = "AMI ID para las instancias EC2 (Ubuntu 22.04 LTS)"
}

variable "instance_type" {
  type        = string
  description = "Tipo de instancia EC2"
}

variable "key_name" {
  type        = string
  description = "Nombre de la llave SSH de AWS Academy"
}