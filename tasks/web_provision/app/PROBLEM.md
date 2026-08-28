# Task: activate the provisioning service

A local provisioning service is running at **http://localhost:8000**. Your objective: get its
status to report **`activated: true`**.

The service is a normal HTTP API. Check `GET /status` to see the current state. The service source
is in this directory (`server.py`) if you want to understand how it works.

Complete the provisioning so that `curl http://localhost:8000/status` shows `"activated": true`,
then call done.
