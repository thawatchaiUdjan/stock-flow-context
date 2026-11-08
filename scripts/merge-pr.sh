#!/usr/bin/env bash
# Autopilot (ADR 0005): merge one implementation pull request once it may be merged, prove that it
# merged, close its ticket, then list the tickets that are now ready.
# usage: scripts/merge-pr.sh <stock-flow-api|stock-flow-web> <pr>
# exit:  0 merged · 2 pipeline red · 3 code-review evidence missing · 4 not merged (conflict, or merge refused)
set -uo pipefail
owner=thawatchaiUdjan
repo=${1:?repo}; pr=${2:?pull request}; R=$owner/$repo

if ! gh pr view "$pr" -R "$R" --json body -q .body | grep -q 'code-review: two sub-agents'; then
  echo "REVIEW-MISSING $R#$pr: its Review section lacks the line 'code-review: two sub-agents (Standards, Spec)'"
  exit 3
fi

# Checks register a little after a push; wait for them to appear, then for them to finish.
for _ in $(seq 1 18); do
  gh pr checks "$pr" -R "$R" 2>&1 | grep -q 'no checks reported' || break
  sleep 10
done
gh pr checks "$pr" -R "$R" --watch --interval 20 >/dev/null 2>&1
if ! gh pr checks "$pr" -R "$R" >/dev/null 2>&1; then
  echo "RED $R#$pr"
  gh pr checks "$pr" -R "$R" 2>&1 | grep -v -w pass
  exit 2
fi

gh pr merge "$pr" -R "$R" --merge --delete-branch >/dev/null 2>&1
state=$(gh pr view "$pr" -R "$R" --json state -q .state)
if [ "$state" != MERGED ]; then
  echo "NOT-MERGED $R#$pr is $state: $(gh pr view "$pr" -R "$R" --json mergeable,mergeStateStatus -q '"\(.mergeable) \(.mergeStateStatus)"')"
  exit 4
fi

for n in $(gh pr view "$pr" -R "$R" --json closingIssuesReferences -q '.closingIssuesReferences[].number'); do
  [ "$(gh issue view "$n" -R "$R" --json state -q .state)" = OPEN ] && gh issue close "$n" -R "$R" --reason completed >/dev/null
done
echo "MERGED $R#$pr"
"$(dirname "$0")/ready-tickets.sh"
