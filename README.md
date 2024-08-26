# Password-Generator-App

## Overview

**Password-Generator-App** is a web application that generates secure and customizable passwords. Built with HTML, CSS, and JavaScript, the application is designed to help users create strong passwords for enhanced security.

## Features

- **Password Generation**: Generate secure and customizable passwords.
- **User-Friendly Interface**: Simple and intuitive web interface.
- **Responsive Design**: Works seamlessly across various devices and screen sizes.

## Infrastructure

The infrastructure for the Password-Generator-App is managed using Terraform (TF), which provides a consistent and reliable way to provision and manage cloud resources.

## Containerization

- **Docker**: The application is containerized using Docker, which allows for consistent development and deployment environments.
- **DockerHub**: The Docker images are stored and managed on DockerHub.

## Deployment

- **Kubernetes EKS**: The application is deployed on Amazon EKS (Elastic Kubernetes Service) to manage containerized applications with Kubernetes.

## CI/CD Pipeline

- **GitHub Actions**: Continuous Integration and Continuous Deployment (CI/CD) are implemented using GitHub Actions. This automates the build, test, and deployment processes.

## Monitoring (Future Enhancements)

- **Grafana**: Will be used for creating dashboards and visualizing metrics.
- **Prometheus**: Will be used for monitoring and alerting.

## Getting Started

### Prerequisites

- Docker
- Terraform
- Kubernetes CLI (`kubectl`)
- GitHub account with Actions enabled

### Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/Password-Generator-App.git
   cd Password-Generator-App

2. **Build and Push Docker Image**
   ```bash
   docker build -t yourusername/password-generator-app:latest .
   docker push yourusername/password-generator-app:latest

3. **Provision Infrastructure with Terraform**
   ```bash
   cd terraform
   terraform init
   terraform apply
   
4. **Deploy to Kubernetes**
   ```bash
   kubectl apply -f Kubernetes_Manifests/deployment.yaml
   kubectl apply -f Kubernetes_Manifests/service.yaml

5. **Verify Deployment**
   Check the status of the deployed pods and services:
   ```bash
   kubectl get pods
   kubectl get services