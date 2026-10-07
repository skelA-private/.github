#!/usr/bin/env bash
# Synchronisiert labels.json in ein oder mehrere Repos.
# Nutzung: scripts/sync-labels.sh OWNER/REPO [OWNER/REPO ...]
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
labels="$here/labels.json"
[ "$#" -ge 1 ] || { echo "Nutzung: $0 OWNER/REPO [...]" >&2; exit 1; }
for repo in "$@"; do
  echo "Labels -> $repo"
  python3 - "$labels" <<'PY' | while IFS=$'\t' read -r name color desc; do
import json, sys
for l in json.load(open(sys.argv[1], encoding="utf-8")):
    print(f"{l['name']}\t{l['color']}\t{l['description']}")
PY
    gh label create "$name" --repo "$repo" --color "$color" --description "$desc" --force >/dev/null
  done
done
