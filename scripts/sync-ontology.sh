#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copy the ontology from the cloud repository, where its source lives (the
# cloud's build and backend need it there), into ontology/ for the docs.
#
#   scripts/sync-ontology.sh [--check] [<cloud checkout>]
#
# The cloud checkout defaults to ../mediathek-digitalhome-cloud beside this
# repository, or $CLOUD_DIR. --check copies nothing and exits 1 when they differ.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
check=0
if [[ "${1:-}" == "--check" ]]; then check=1; shift; fi
cloud="${1:-${CLOUD_DIR:-$here/../mediathek-digitalhome-cloud}}"
src="$cloud/packages/ontology"
if [[ ! -d "$src/tbox" ]]; then
  echo "no ontology at $src (pass the cloud checkout, or set CLOUD_DIR)" >&2
  exit 2
fi
files=(tbox/mediathek.ttl tbox/mediathek-concepts.ttl shapes/mediathek-shapes.ttl concepts.json)
differ=0
for f in "${files[@]}"; do
  if ! cmp -s "$src/$f" "$here/ontology/$f"; then
    differ=1
    if (( check )); then echo "differs: ontology/$f" >&2; else mkdir -p "$(dirname "$here/ontology/$f")"; cp "$src/$f" "$here/ontology/$f"; echo "copied ontology/$f"; fi
  fi
done
if (( check )); then
  (( differ )) && { echo "run scripts/sync-ontology.sh to copy the cloud's ontology" >&2; exit 1; }
  echo "ontology matches $src"
elif (( ! differ )); then
  echo "ontology already matches $src"
fi
