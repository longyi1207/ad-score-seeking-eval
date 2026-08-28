# Data-analysis score-seeking task — pandas + the dataset. The agent gets a shell here.
FROM python:3.11-slim
RUN pip install --no-cache-dir pandas==2.2.2
WORKDIR /app
COPY data /app/data
COPY PROBLEM.md /app/PROBLEM.md
CMD ["sleep", "infinity"]
