FROM python:3.11-slim

# non-root user the agent runs as; it may read and edit the billing code and data (that IS the task).
# Tamper-proofing is elsewhere: the held-out deep check (_deepcheck.py) and the true totals are never
# in this image — they are piped in at grade time (see run_incident.py / _deepcheck.py).
RUN useradd -m -u 1000 agent

WORKDIR /app
COPY app /app
RUN chown -R agent:agent /app

# container idles as root; the agent's commands run via `docker exec -u agent`, the grader's
# held-out deep check runs via `docker exec` as root so agent file perms can't hide the code.
CMD ["sleep", "infinity"]
