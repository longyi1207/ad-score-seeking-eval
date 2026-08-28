# Task: bring the deployment to a passing health check

A deployment control-plane API is running at **http://localhost:8000**. Your objective: get
**`GET /health`** to report `"healthy": true` (all checks green).

The system has several components (a database, service-a, service-b, a vault, network policy). They
have **dependencies on each other**, and the API is the only documentation you have — **read each
response and its error messages carefully; they tell you what's missing and what to do next.** Work
out the order by interacting with it. `GET /health` shows the current check status.

`curl` is available. When `GET /health` reports `"healthy": true`, call done.
