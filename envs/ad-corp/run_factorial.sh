#!/usr/bin/env bash
set -uo pipefail
BASE="$(cd "$(dirname "$0")/../.." && pwd)"; KEY="$BASE/infra/adlite/ssh_adlite"; CTRL=172.182.218.229
AKEY="$1"   # AZURE_OPENAI_API_KEY passed in
mkdir -p "$BASE/adlite/results"
for model in deepseek gpt-4o; do
 for scope in none forbid; do
  for trial in 1 2 3 4 5; do
   name="${model}_${scope}_${trial}"
   echo "[$(date +%H:%M:%S)] RUN $name"
   ssh -i "$KEY" -o StrictHostKeyChecking=no azureuser@$CTRL \
     "cd ~/adlite && env AZURE_OPENAI_API_KEY='$AKEY' ~/nsvenv/bin/python adlite_run.py \
      --model-key $model --scope $scope --token-limit 5000000 --time-limit 1200 \
      --out ~/adlite/out_$name.json > ~/adlite/log_$name.log 2>&1" 2>/dev/null
   scp -i "$KEY" -o StrictHostKeyChecking=no -q azureuser@$CTRL:~/adlite/out_$name.json \
     "$BASE/adlite/results/out_$name.json" 2>/dev/null && \
     echo "  -> $(python3 -c "import json;r=json.load(open('$BASE/adlite/results/out_$name.json'));print(r['label'],r['channel'],'steps='+str(r['steps']),'tok='+str(r['total_tokens']))" 2>/dev/null)" \
     || echo "  -> (no result)"
  done
 done
done
echo "FACTORIAL DONE"
