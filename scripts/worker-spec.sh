#!/usr/bin/env bash
# Writes the spec file for one dispatched worker and prints its path, for `orca orchestration worker-start --spec-file`.
# usage: scripts/worker-spec.sh <stock-flow-api|stock-flow-web> <ticket> [claude|codex]
set -euo pipefail

repo=${1:?repo}; n=${2:?ticket}; agent=${3:-claude}
case $repo in
  stock-flow-api) other=stock-flow-web ;;
  stock-flow-web) other=stock-flow-api ;;
  *) echo "unknown repo: $repo" >&2; exit 1 ;;
esac

# Absolute paths the worker can open from its worktree, in the form its tools expect.
native() { if command -v cygpath >/dev/null; then cygpath -w "$1"; else printf '%s\n' "$1"; fi; }
here=$(cd "$(dirname "$0")/.." && pwd)
record=$(native "$here")
sibling=$(native "${here%/*}/$other")

cmd='/implement'; [ "$agent" = codex ] && cmd='$implement'
dir=${WORKER_SPEC_DIR:-${TMPDIR:-/tmp}}
out=$dir/worker-$repo-$n.md

cat > "$out" <<EOF
$cmd #$n

You work ticket thawatchaiUdjan/$repo#$n. Follow *Working a dispatched ticket* in this repo's AGENTS.md.

- Paths: the record (stock-flow-context) is at $record. The other implementing repo is at $sibling. Never use ../ paths to reach them.
- Decisions: the record is under ADR 0005 (autopilot), so the requirements owner's decisions are delegated to the coordinator. A question you would put to the coordinator still goes on the ticket first, then through \`orca orchestration ask\`.
- Sub-agents: this task asks for them. Run \`code-review\` with its two sub-agents (Standards and Spec), and start no others. In the pull request's Review section, write the line \`code-review: two sub-agents (Standards, Spec)\`, then the findings. The coordinator does not merge a pull request without that line.
- Before the pull request: rebase on origin/main, then run the repo's full CI command set and make it pass. The coordinator merges on a green pipeline, with no human review.
- Tokens: find code with \`grep -n\` and read line ranges, not whole large files; read each file once; look at a screenshot once, at the smallest width that shows the point; batch related commands into one call.
- Chat: nobody reads this chat. Write no summaries or explanations in it, and work in English. What matters goes on the ticket, the pull request and \`worker_done\`.
- When done, report \`worker_done\` with the pull request's link.
EOF
native "$out"
