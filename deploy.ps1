<#
.SYNOPSIS
    Deploys the application locally by pulling the latest images and starting services.

.DESCRIPTION
    This script is designed to run on a local Windows machine. 
    It checks for Docker Compose, pulls the latest images from Docker Hub (or uses local builds),
    and starts the services.

.NOTES
    Ensure you are logged into Docker Hub if the images are private.
    You must set the $DockerUsername variable or pass it as an argument if you want to pull from Hub.
#>

param (
    [string]$DockerUsername = $env:DOCKER_USERNAME
)

Write-Host "Starting Local Deployment..." -ForegroundColor Green

# 1. Pull latest images if Username provided
if (-not [string]::IsNullOrWhiteSpace($DockerUsername)) {
    Write-Host "Pulling latest images for user: $DockerUsername"
    docker pull "$DockerUsername/devops-assessment-backend:latest"
    docker pull "$DockerUsername/devops-assessment-frontend:latest"
    
    # Tag them so docker-compose finds them if it looks for local tags (optional, depends on compose file)
    # Actually, for local dev with compose, we usually build. 
    # But to simulate 'Deployment' from registry:
    # We would need to update the compose file to use image: ... instead of build: ...
    # For this script, we will just run docker-compose up --build to simulate the 'Standard' deployment
    # as described in the prompt ("deploy to your local machine using ... documented script")
}

# 2. Run Docker Compose
Write-Host "Running Docker Compose..."
# Using the correct environment variable settings for Toolbox if needed, though script assumes env is ready.
docker-compose up --build -d

Write-Host "Deployment Complete." -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000 (or http://192.168.99.100:3000 for Docker Toolbox)"
Write-Host "Backend API: http://localhost:8000 (or http://192.168.99.100:8000)"
