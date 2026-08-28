#!/usr/bin/env bash
# run_batch.sh — run a model × scope × trials factorial of the AD score-seeking eval.
# Runs ON the control node (has model egress + SSH to attacker). Each run is the bespoke
# ReAct harness (adlite_run.py); results land as one JSON + one log per cell/trial.
#
# Env: AZURE_OPENAI_API_KEY, AZURE_AI_RESOURCE, AD_CONFIG (path to the env's ad_config.json).
# Tunables (env vars): MODELS, SCOPES, TRIALS, CONC, MAXSTEPS, TIMELIMIT, OUT, PY.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
MODELS="${MODELS:-deepseek gpt-4o}"
SCOPES="${SCOPES:-none forbid}"
TRIALS="${TRIALS:-3}"
CONC="${CONC:-4}"
MAXSTEPS="${MAXSTEPS:-120}"
TIMELIMIT="${TIMELIMIT:-2400}"
OUT="${OUT:-$HERE/results}"; mkdir -p "$OUT"
PY="${PY:-$HOME/nsvenv/bin/python}"
export AD_CONFIG="${AD_CONFIG:-$HERE/ad_config.json}"
echo "batch: models=[$MODELS] scopes=[$SCOPES] trials=$TRIALS conc=$CONC maxsteps=$MAXSTEPS"
echo "config=$AD_CONFIG out=$OUT"
jobs=0
for m in $MODELS; do for s in $SCOPES; do for t in $(seq 1 "$TRIALS"); do
  o="$OUT/${m}_${s}_t${t}.json"; lg="$OUT/${m}_${s}_t${t}.log"
  ( "$PY" "$HERE/adlite_run.py" --model-key "$m" --scope "$s" \
        --max-steps "$MAXSTEPS" --time-limit "$TIMELIMIT" --out "$o" > "$lg" 2>&1
    lab=$("$PY" -c "import json;d=json.load(open('$o'));print(d.get('label','ERR'),d.get('steps','?'),d.get('total_tokens','?'))" 2>/dev/null || echo "CRASH")
    echo "DONE ${m}/${s}/t${t} -> $lab" ) &
  jobs=$((jobs+1))
  [ $((jobs % CONC)) -eq 0 ] && wait
done; done; done
wait
echo "BATCH COMPLETE ($jobs runs) -> $OUT"