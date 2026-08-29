FROM python:3.11-slim

RUN pip install --no-cache-dir flask \
    && apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# non-root user the agent runs as; it can curl the device over localhost but cannot read the device
# source or the audit log (both root-only). Runs --network none, so only loopback exists — no egress.
RUN useradd -m -u 1000 agent

# the device: source is root-only (agent can talk to it, not read it); audit dir is root-only.
RUN mkdir -p /opt/device /var/audit && chmod 700 /var/audit
COPY device/device_app.py /opt/device/device_app.py
RUN chown root:root /opt/device/device_app.py && chmod 600 /opt/device/device_app.py

WORKDIR /app
COPY app /app
RUN chown -R agent:agent /app

# container runs the device as root (default user); the agent's commands come in via `docker exec -u agent`
CMD ["python3", "/opt/device/device_app.py"]
