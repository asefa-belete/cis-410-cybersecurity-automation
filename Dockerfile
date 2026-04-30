# Dockerfile.vulnerable
# ─────────────────────────────────────────────────────────────────────────────
# INTENTIONALLY INSECURE — for Week 4 observation and Week 5 scanning exercise.
# Do NOT use this Dockerfile for staging or production.
#
# HOW TO USE:
#   Before deploying, copy the vulnerable app files into app/ first:
#     cp vulnerable_app/app.py app/app.py
#     cp vulnerable_app/requirements.txt app/requirements.txt
#     cp -r vulnerable_app/templates/. app/templates/
#   Then swap this file over the main Dockerfile:
#     cp Dockerfile.vulnerable Dockerfile
#   Then commit and push.
#
#   The deploy workflow copies app/ and Dockerfile to the VM.
#   app/ now contains the vulnerable app files.
#
# Violations present for Week 5 scanners to detect:
#
#   VIOLATION 1: Unpinned base image — 'python:3.11' instead of 'python:3.11-slim'
#   The full image is ~900MB vs ~120MB for slim. 'python:3.11' resolves to a
#   different digest on every pull — builds are not reproducible and may
#   silently include new vulnerabilities. Trivy will report CVEs.
#
#   VIOLATION 2: Source code copied before dependencies (no layer caching)
#   COPY . . copies everything before pip install runs. Every push rebuilds
#   from scratch — no caching.
#
#   VIOLATION 3: No USER instruction — container runs as root (UID 0)
#   If the app has a code execution vulnerability, attacker gets root inside
#   the container. Trivy and Semgrep will both flag this.
#   Verify: docker compose exec web whoami  →  returns 'root' not 'appuser'
# ─────────────────────────────────────────────────────────────────────────────

# FIX 1: Use a specific, slim base image to reduce OS vulnerabilities
FROM python:3.11-slim

WORKDIR /app

# FIX 3: Add a non-root user (appuser) to prevent root escalation
RUN adduser --disabled-password appuser

# FIX 2: Copy requirements and install deps BEFORE source code for layer caching
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source code
COPY app/ app/

# Ensure the non-root user owns the app directory
RUN chown -R appuser:appuser /app

# FIX 3 (continued): Switch to the non-root user
USER appuser

EXPOSE 5000


CMD ["python", "app/app.py"]
