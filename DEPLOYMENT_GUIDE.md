# Full Stack Deployment Guide - DevOps Assessment

This document provides a complete, step-by-step guide to running, deploying, and maintaining the DevOps Assessment project.

## 1. Project Overview
This is a full-stack containerized application consisting of:
- **Frontend**: React (Vite + TypeScript) served via Nginx.
- **Backend**: Django (Python) served via Gunicorn.
- **Database**: SQLite (default) or PostgreSQL (ready).
- **Reverse Proxy**: Nginx handles internal routing, forwarding `/api/` requests to the backend.

## 2. Prerequisites
Before you begin, ensure you have:
1.  **AWS Account** (with access to EC2, CodePipeline, CodeBuild).
2.  **GitHub Account** (with this repository forked/cloned).
3.  **Docker Hub Account** (to store the container images).
4.  **Terraform** installed locally.
5.  **AWS CLI** installed and configured (`aws configure`).

---

## 3. Infrastructure Provisioning (Terraform)
We use Terraform to provision the EC2 instance and Security Groups.

1.  **Navigate to Terraform directory**:
    ```bash
    cd terraform
    ```
2.  **Initialize & Apply**:
    ```bash
    terraform init
    terraform apply
    ```
    *Note: Type `yes` when prompted.*
3.  **Note the Outputs**:
    After a successful apply, Terraform will output the **Public IP** of your EC2 instance. Save this!

---

## 4. CI/CD Pipeline Setup (AWS)
We use **AWS CodePipeline** with **CodeBuild** to automate build and deployment.

### Step 4.1: Create Project in CodeBuild
1.  Go to **AWS CodeBuild** -> **Create build project**.
2.  **Source**: Connect to your GitHub repository -> `main` branch.
3.  **Environment**: 
    - Managed Image -> Ubuntu -> Standard -> 5.0+.
    - **Privileged**: Check "Enable this flag" (Required for building Docker images).
4.  **Buildspec**: Use `buildspec.yml` (default).

### Step 4.2: Configure Environment Variables (CRITICAL)
In CodeBuild -> Edit -> Environment, add the following variables:

| Name | Value | Description |
|------|-------|-------------|
| `DOCKER_USERNAME` | `your-dockerhub-username` | Your Docker Hub username. |
| `DOCKER_PASSWORD` | `your-dockerhub-password` | Your Docker Hub password or Access Token. |
| `EC2_HOST` | `1.2.3.4` | The Public IP of your EC2 instance (from Terraform). |
| `EC2_USER` | `ubuntu` | The user of the EC2 instance (default is `ubuntu`). |
| `EC2_KEY_B64` | `...` | **Base64 encoded** private key (.pem) content. |

#### How to get `EC2_KEY_B64`:
Run this command in your local terminal where your `.pem` key is located:
- **Linux/Mac**: `base64 -i devops-key.pem | tr -d '\n'`
- **Windows (PowerShell)**: 
  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("devops-key.pem"))
  ```
  *Copy the output string and paste it as the value for `EC2_KEY_B64`.*

### Step 4.3: Create Pipeline
1.  Go to **AWS CodePipeline** -> Create Pipeline.
2.  **Source**: GitHub (Version 2).
3.  **Build**: Select the CodeBuild project you just created.
4.  **Deploy**: Skip this stage (Our `buildspec.yml` handles deployment via SSH/SCP).

---

## 5. Local Development (Docker Compose)
To run the project locally on your machine:

1.  **Clone the repo**:
    ```bash
    git clone https://github.com/malleshpareet/Devops-assessment.git
    cd Devops-assessment
    ```
2.  **Build and Run**:
    ```bash
    docker-compose up --build
    ```
3.  **Access the App**:
    - Frontend: `http://localhost:3000`
    - Backend: `http://localhost:8000/api/hello/`

---

## 6. Architecture & Troubleshooting

### How the Connection Works
- **Users** connect to **Frontend (Nginx)** on Port `3000`.
- **Nginx** serves the React App files.
- When React makes an API call to `/api/hello/`, **Nginx** intercepts it.
- **Nginx** proxies the request internally to the **Backend (Django)** container on Port `8000`.
- **Backend** responds to Nginx, which relays it back to the User.

### Common Issues
- **"Connection Failed" on Frontend**: 
  - Ensure the CI/CD pipeline finished successfully.
  - Check if the Backend container is running on the server: `ssh ubuntu@<EC2_IP> "docker ps"`
  - Verify Nginx config includes the `location /api/` block.

- **Pipeline Fails at "Testing SSH connection"**:
  - Check if `EC2_HOST` is correct.
  - Check if `EC2_KEY_B64` was copied correctly (no newlines).
  - Ensure the EC2 Security Group allows SSH (Port 22) from the CodeBuild IP (or 0.0.0.0/0 for testing).
