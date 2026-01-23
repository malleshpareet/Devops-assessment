# Stage 1: Build
FROM python:3.10-slim as builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .

# Install dependencies in low-resource mode (no pip upgrade, no threads)
RUN pip install -r requirements.txt --no-cache-dir --progress-bar off

# Stage 2: Runtime
FROM python:3.10-slim

WORKDIR /app

# Create non-root user
RUN useradd -m -u 1000 appuser

# Copy installed packages from builder
COPY --from=builder /usr/local /usr/local

# Copy project files
COPY . .

# Change ownership
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

# Optimized gunicorn for Docker Toolbox
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "1", "--timeout", "120"]
