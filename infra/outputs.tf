output "frontend_public_ip" {
  value       = aws_instance.frontend.public_ip
  description = "Dirección IP pública para acceder al Frontend desde el navegador"
}

output "backend_private_ip" {
  value       = aws_instance.backend.private_ip
  description = "Dirección IP privada interna del servidor de Backend"
}

output "vpc_id" {
  value       = aws_vpc.innovatech_vpc.id
  description = "ID de la VPC de Innovatech"
}