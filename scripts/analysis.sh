#!/usr/bin/env bash
# Purpose: Scan mounted filesystems and report any usage above threshold.
# Usage: ./analysis.sh [THRESHOLD_PERCENT]; default 80

set -euo pipefail

THRESHOLD="${1:-80}"

echo "=== Disk Usage Report (threshold ${THRESHOLD}%) ==="
# Skip tmpfs, devtmpfs, overlay duplicates etc., but keep core mounts
df -PTh | awk -v th="$THRESHOLD" '
  BEGIN { printf "%-30s %-8s %-10s %-6s %-s\n", "Filesystem","Type","Size","Use%","Mount" }
  NR>1 && $2!="tmpfs" && $2!="devtmpfs" {
    gsub("%","",$6);
    warn = ($6>=th) ? " <-- HIGH" : ""
    printf "%-30s %-8s %-10s %-6s %-s%s\n", $1,$2,$3,$6,$7,warn
  }
'
