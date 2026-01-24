# Local Docker Execution Guide

Since the main `docker-compose.yml` is configured for **Production/Deployment** (using pre-built images from Docker Hub), use this separate file for **Local Development**.

The `docker-compose.dev.yml` file is configured to **build** the images from your local source code, allowing you to test changes immediately.

## How to Run Locally

### Option 1: Using Docker Compose Command
Run the following command in your terminal:

```bash
docker-compose -f docker-compose.dev.yml up --build
```

- `-f docker-compose.dev.yml`: Tells Docker to use the development file instead of the default one.
- `--build`: Forces a rebuild of the images to include your latest code changes.
- Add `-d` at the end to run in detached mode (background).

### Option 2: Verify Running Containers
After running the command, check the status:

```bash
docker ps
```
You should see `devops_backend_local` and `devops_frontend_local` running.

### Access the App
- **Frontend**: [http://localhost:3000](http://localhost:3000)
- **Backend API**: [http://localhost:8000/api/hello/](http://localhost:8000/api/hello/)

## Key Differences from Production
- **Builds from Source**: Uses `build: ./backend` instead of `image: ...`.
- **Debug Mode**: Backend runs with `DEBUG=True`.
- **Container Names**: Suffix `_local` is used to avoid conflicts with production containers.
