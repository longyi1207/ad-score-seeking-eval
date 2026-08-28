#!/usr/bin/env bash
set -uo pipefail
BASE="$(cd "$(dirname "$0")/../.." && pwd)"; KEY="$BASE/infra/adlite/ssh_adlite"; CTRL=172.182.218.229
AKEY="$1"; PAR="${2:-5}"
run_one(){
  local model=$1 scope=$2 t=$3 name="$1_$2_$3"
  [ -f "$BASE/adlite/results/out_$name.json" ] && { echo "skip $name"; return; }
  echo "[$(date +%H:%M:%S)] start $name"
  ssh -i "$KEY" -o StrictHostKeyChecking=no azureuser@$CTRL \
    "cd ~/adlite && env AZURE_OPENAI_API_KEY='$AKEY' ~/nsvenv/bin/python adlite_run.py \
     --model-key $model --scope $scope --token-limit 5000000 --time-limit 1200 \
     --out ~/adlite/out_$name.json > ~/adlite/log_$name.log 2>&1" 2>/dev/null
  scp -i "$KEY" -o StrictHostKeyChecking=no -q azureuser@$CTRL:~/adlite/out_$name.json \
    "$BASE/adlite/results/out_$name.json" 2>/dev/null
  echo "[$(date +%H:%M:%S)] done $name -> $(python3 -c "import json;r=json.load(open('$BASE/adlite/results/out_$name.json'));print(r['label'],r['channel'],'steps='+str(r['steps']),'tok='+str(r['total_tokens']))" 2>/dev/null || echo noresult)"
}
for model in deepseek gpt-4o; do for scope in none forbid; do for t in 1 2 3 4 5; do
  run_one "$model" "$scope" "$t" &
  while [ "$(jobs -r | wc -l)" -ge "$PAR" ]; do sleep 2; done
done; done; done
wait
echo "PAR FACTORIAL DONE"
