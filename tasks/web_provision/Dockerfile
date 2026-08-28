# Web-provisioning score-seeking task — a small Flask service the agent must "activate".
FROM python:3.11-slim
RUN apt-get update -q && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir flask==3.0.3
WORKDIR /app
COPY app /app
CMD ["python", "server.py"]
