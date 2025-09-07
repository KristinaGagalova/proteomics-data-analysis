#!/usr/bin/env bash
# Make use of a machine with at least 24G of memory
set -euo pipefail

mkdir -p qc

# 1) per-file qcML
for f in *.mzML; do
  base="${f%.mzML}"
  echo "[QCCalculator] $f -> qc/${base}.qcML"
  QCCalculator -in "$f" -out "qc/${base}.qcML"
done

# 2) merge into a single set (optional but handy)
echo "[QCMerger] qc/*.qcML -> qc/all_runs.qcML"
QCMerger -in qc/*.qcML -out qc/all_runs.qcML -setname AllRuns

# 3) export selected metrics
# NOTE: adjust mapping.csv to match the qp CVs you want (see examples in share/OpenMS)
echo "[QCExporter] -> qc/metrics.csv"
QCExporter -in qc/all_runs.qcML -mapping mapping.csv -out_csv qc/metrics.csv

echo "Done. See qc/metrics.csv"
