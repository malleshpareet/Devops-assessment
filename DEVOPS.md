# DevOps Assessment Documentation

This document serves as the final report for the DevOps Assessment.

## 1. Setup Guide

### Part A: How to Run Locally

To run the application on your local machine using Docker Compose:

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/malleshpareet/Devops-assessment.git
    cd Devops-assessment
    ```

2.  **Run with Docker Compose**:
    We use a dedicated development compose file that builds images from source.
    ```bash
    docker-compose -f docker-compose.dev.yml up --build
    ```

3.  **Access the Application**:
    - **Frontend**: [http://localhost:3000](http://localhost:3000)
    - **Backend API**: [http://localhost:8000/api/hello/](http://localhost:8000/api/hello/)

### Part B: How to Run on the Server (AWS)

The production setup uses **AWS EC2**, **CodePipeline**, and **CodeBuild** for automated deployment.

#### 1. Infrastructure Provisioning (Terraform)
1.  Navigate to the `terraform/` directory.
2.  Run `terraform init` and `terraform apply`.
3.  This provisions the **EC2 instance** and **Security Groups**. Note the IP address output.

#### 2. Deployment Pipeline (CI/CD)
We use AWS CodePipeline. The workflow is fully automated:
1.  **Push to GitHub**: Developer pushes code to `main`.
2.  **AWS CodePipeline** triggers.
3.  **AWS CodeBuild** runs `buildspec.yml`:
    *   Logs into Docker Hub securely.
    *   Builds and Pushes Docker Images (`mallesh2210/devops-backend`, `mallesh2210/devops-frontend`).
    *   Uses `scp` to copy `docker-compose.yml` to the EC2 server.
    *   Uses `ssh` to execute deployment commands on EC2 (`docker-compose pull && up -d`).

#### 3. Accessing Production
Once the pipeline finishes, access the public IP of your EC2 instance:
- **URL**: `http://<EC2_PUBLIC_IP>:3000`

---

## 2. Troubleshooting Log

During the implementation, I encountered and solved the following significant challenges:

### Challenge 1: Frontend to Backend Communication (CORS vs Proxy)
**The Problem**: 
The React Frontend was unable to communicate with the Django Backend. 
- Initially, the frontend tried to connect to `localhost:8000`, which worked locally but failed on the server or for other users because `localhost` referred to the client's machine, not the server.
- Configuring the Backend IP explicitly involved Hardcoding IP addresses, which is brittle.

**The Solution**:
I implemented an **Nginx Reverse Proxy**.
1.  Updated `nginx.conf` in the Frontend container to intercept requests to `/api/`.
2.  Configured it to proxy these requests internally to the backend container (`http://backend:8000`).
    ```nginx
    location /api/ {
        proxy_pass http://backend:8000;
        ...
    }
    ```
3.  Updated the React `App.tsx` to use relative paths (`/api/hello/`) instead of absolute URLs. 
**Result**: The browser treats the API call as local to the same server, avoiding CORS issues and hardcoded IPs entirely.

### Challenge 2: Secure Deployment via CI/CD
**The Problem**: 
Deployment failed because the AWS CodeBuild environment tried to run `git pull` on the EC2 instance. 
- This failed with `exit status 128` (Permission denied) because the EC2 instance did not have SSH keys or tokens to access the private GitHub repository.

**The Solution**:
I refactored the deployment strategy to be "Push-based" rather than "Pull-based" regarding source code.
1.  Instead of pulling code on the server, I configured the CI/CD pipeline to **build Docker images** and push them to Docker Hub.
2.  I modified the deployment script to simply copy the `docker-compose.yml` file (using `scp`) and run `docker-compose pull`.
**Result**: The server no longer needs Git credentials. It only needs to pull public/authenticated images from Docker Hub, which is much more secure and robust.

### Challenge 3: GitHub Secret Scanning
**The Problem**:
While configuring the pipeline, a commit containing a Docker Personal Access Token was rejected by GitHub's Push Protection.

**The Solution**:
1.  I used `git reset` to rewind the history and remove the insecure commit.
2.  I configured **AWS System Manager Parameter Store** / CodeBuild Environment Variables to store the secrets (`DOCKER_USERNAME`, `DOCKER_PASSWORD`).
3.  I updated `buildspec.yml` to reference these environment variables instead of hardcoded values.
