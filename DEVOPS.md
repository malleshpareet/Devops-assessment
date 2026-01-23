# DevOps Assessment - Full Stack Deployment

This repository contains the containerized "Hello World" full-stack application (Django + React), orchestrated with Docker Compose.

## Prerequisites
- Docker & Docker Compose installed.

## Project Structure
- `backend/`: Django REST API
- `frontend/`: React (Vite + TypeScript)
- `docker-compose.yml`: Orchestration file
- `DEVOPS.md`: This documentation

## Setup Guide (Local)

1.  **Build and Run with Docker Compose**
    Run the following command in the root directory:
    ```bash
    docker-compose up --build
    ```

    This will:
    - Build the Backend image (Django + Gunicorn).
    - Build the Frontend image (React + Nginx).
    - Start both services.

2.  **Access the Application**
    - **Frontend**: Open [http://localhost:3000](http://localhost:3000) in your browser.
    - **Backend API**: Accessible at [http://localhost:8000/api/hello/](http://localhost:8000/api/hello/).

## Configuration which was implemented
- **Backend**:
    - Runs as a non-root user (`appuser`).
    - Uses `gunicorn` for production-grade serving.
    - Configuration (DEBUG, SECRET_KEY, ALLOWED_HOSTS) is managed via Environment Variables in `docker-compose.yml`.
- **Frontend**:
    - Multi-stage build (Node build -> Nginx serve).
    - Runs as non-root user (using `nginxinc/nginx-unprivileged:alpine`).
    - `VITE_API_URL` is baked in at build time via `docker-compose` args.

## Troubleshooting Log

### Challenge: Environment Variables in Static Frontend
**Issue**: React (Vite) is a static frontend, so environment variables like `API_URL` are strictly build-time, but we needed to configure it via Docker Compose.
**Solution**: 
- Added `ARG VITE_API_URL` to `frontend/Dockerfile`.
- Passed the value `http://localhost:8000` via `args` in `docker-compose.yml`.
- Updated `App.tsx` to use `import.meta.env.VITE_API_URL` with a fallback.

### Challenge: Non-Root User for Nginx
**Issue**: Standard Nginx requires root to bind to port 80.
**Solution**: Used `nginxinc/nginx-unprivileged` image which listens on port 8080 by default and runs as a non-root user. Mapped port 3000 (host) to 8080 (container).

## Phase 2: CI/CD Pipeline & Deployment

### CI/CD Workflow
A GitHub Actions workflow is set up in `.github/workflows/ci-cd.yml` which triggers on every push to the `main` branch.

**Steps:**
1.  **Checkout Code**: Pulls the latest code.
2.  **Login to Docker Hub**: Authenticates using GitHub Secrets (`DOCKER_USERNAME`, `DOCKER_PASSWORD`).
3.  **Build and Push**: Builds optimized Docker images for Frontend and Backend and pushes them to Docker Hub.

**Required GitHub Secrets:**
To enable the pipeline, add these repository secrets in GitHub (Settings > Secrets and variables > Actions):
- `DOCKER_USERNAME`: Your Docker Hub username.
- `DOCKER_PASSWORD`: Your Docker Hub access token (preferred) or password.

### Deployment Script (Standard)
A PowerShell deployment script `deploy.ps1` is provided to automate local deployment.

**Capabilities:**
- Checks for `docker-compose`.
- Pulls the latest images from Docker Hub (if `DOCKER_USERNAME` is provided).
- Starts the application using strict Docker Compose configuration.

**How to Run:**
```powershell
# Run locally (uses local build if no username supplied, or pulls if Env Var is set)
.\deploy.ps1

# To forcefully pull from Docker Hub:
.\deploy.ps1 -DockerUsername "your-docker-username"
```

## Phase 3: Infrastructure as Code (Terraform)
A Terraform configuration is provided in the `terraform/` directory to provision an AWS EC2 instance with the required security configuration.

### Resources Provisioned
- **VPC & Networking**: Dedicated VPC, Public Subnet, Internet Gateway, and Route Table.
- **Security Group**: Firewall rules strictly allowing:
    - **Port 22 (SSH)**: For remote access.
    - **Port 80 (HTTP)**: For web traffic.
    - **Port 443 (HTTPS)**: For secure web traffic.
- **EC2 Instance**: Ubuntu 22.04 LTS (`t2.micro` - Free Tier) with Docker pre-installed via User Data script.

### How to Deploy (AWS)
**Prerequisites**: Terraform installed and AWS Credentials configured (`aws configure`).

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the execution plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```
   *Note: Ensure you Update `variables.tf` with your actual EC2 Key Pair name before applying.*
