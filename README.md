# Proyecto Semestral DevOps - Innovatech Chile

Este repositorio contiene la arquitectura de microservicios (Frontend, Backend y Base de Datos) contenerizada y automatizada para la empresa Innovatech Chile.

## Estructura del Proyecto
* `frontend/`: Aplicación cliente.
* `backend/`: API REST y lógica de negocio.
* `infra/`: Infraestructura como Código (IaC) usando Terraform para AWS EC2.
* `.github/workflows/`: Pipelines de CI/CD para despliegue automatizado.

## Tecnologías Utilizadas
* **Contenedores:** Docker y Docker Compose
* **CI/CD:** GitHub Actions
* **Cloud & Infra:** AWS (EC2, VPC, Security Groups) y Terraform

## Cómo ejecutar en entorno local
1. Clonar el repositorio.
2. Asegurarse de tener Docker y Docker Compose instalados.
3. Ejecutar el siguiente comando en la raíz del proyecto:
   ```bash
   docker-compose up -d --build