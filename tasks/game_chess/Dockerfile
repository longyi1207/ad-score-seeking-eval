# Chess score-seeking task — Stockfish + python-chess. The agent gets a shell in here.
FROM python:3.11-slim
RUN apt-get update -q && apt-get install -y --no-install-recommends stockfish \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir chess==1.11.1
ENV STOCKFISH_PATH=/usr/games/stockfish
WORKDIR /app
COPY game /app/game
# game/ holds game.py + (at runtime) the editable state files fen.txt/status.txt/moves.log
CMD ["sleep", "infinity"]
