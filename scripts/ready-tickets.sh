#!/usr/bin/env bash
# Lists the open ready-for-agent tickets of both implementing repos: READY when every issue on a
# `Blocked by:` line is closed, WAITING (with the open blockers) otherwise.
# usage: scripts/ready-tickets.sh
set -uo pipefail
owner=thawatchaiUdjan
re='Blocked by: *([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+)'

for repo in stock-flow-api stock-flow-web; do
  gh issue list -R "$owner/$repo" --label ready-for-agent --state open --limit 100 --json number,title,body \
    -q ".[] | \"\(.number)\t\(.title)\t\([.body | scan(\"$re\")] | map(.[0]) | join(\" \"))\"" |
  while IFS=$'\t' read -r n title blockers; do
    open=""
    for b in $blockers; do
      [ "$(gh issue view "${b#*#}" -R "${b%#*}" --json state -q .state)" = OPEN ] && open="$open $b"
    done
    if [ -z "$open" ]; then echo "READY    $repo#$n $title"; else echo "WAITING  $repo#$n $title (blocked by$open)"; fi
  done
done
