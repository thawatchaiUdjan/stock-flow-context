#!/usr/bin/env bash
# Writes the spec file for one dispatched worker and prints its path, for `orca orchestration worker-start --spec-file`.
# usage: scripts/worker-spec.sh <stock-flow-api|stock-flow-web> <ticket> <claude|codex> <autopilot|approval>
set -euo pipefail

repo=${1:?repo}; n=${2:?ticket}; agent=${3:-claude}; mode=${4:?selected work mode required: autopilot or approval}
case $mode in
  autopilot) decisions="The owner selected Autopilot for this task under ADR 0008; decisions are delegated to the coordinator within the ticket scope." ;;
  approval) decisions="The owner selected Approval workflow for this task under ADR 0008; the coordinator must obtain owner approval at the workflow gates." ;;
  *) echo "unknown work mode: $mode" >&2; exit 2 ;;
esac
case $agent in
  claude) model_col=3 ;;
  codex) model_col=4 ;;
  *) echo "unknown agent: $agent" >&2; exit 1 ;;
esac
case $repo in
  stock-flow-api) other=stock-flow-web ;;
  stock-flow-web) other=stock-flow-api ;;
  *) echo "unknown repo: $repo" >&2; exit 1 ;;
esac

# Absolute paths the worker can open from its worktree, in the form its tools expect.
native() { if command -v cygpath >/dev/null; then cygpath -w "$1"; else printf '%s\n' "$1"; fi; }
here=$(cd "$(dirname "$0")/.." && pwd)
review_model=$(awk -F'|' -v col="$model_col" '$2 ~ /^[[:space:]]*standard[[:space:]]*$/ { print $col; exit }' "$here/docs/workflow.md" | tr -d ' `\r')
[ -n "$review_model" ] || { echo "standard review model missing from docs/workflow.md" >&2; exit 1; }
review_settings="Use fresh review context and $review_model / medium where supported; report unsupported controls."
if [ "$agent" = codex ]; then
  review_settings="For Codex set fork_turns=\"none\", model=\"$review_model\", reasoning_effort=\"medium\" explicitly."
fi
record=$(native "$here")
sibling=$(native "${here%/*}/$other")

cmd='/implement'; [ "$agent" = codex ] && cmd='$implement'
dir=${WORKER_SPEC_DIR:-${TMPDIR:-/tmp}}
out=$dir/worker-$repo-$n.md

cat > "$out" <<EOF
$cmd #$n

You work ticket thawatchaiUdjan/$repo#$n. Follow *Working a dispatched ticket* in this repo's AGENTS.md.

- Paths: the record (stock-flow-context) is at $record. The other implementing repo is at $sibling. Never use ../ paths to reach them.
- Decisions: $decisions Work mode: $mode. Inherit this selection; do not ask the owner to select again. A question you would put to the coordinator still goes on the ticket first, then through \`orca orchestration ask\`.
- Sub-agents: this task asks for them. Run \`code-review\` with its two sub-agents (Standards and Spec), and start no others. In the pull request's Review section, write the line \`code-review: two sub-agents (Standards, Spec)\`, then the findings. The coordinator does not merge a pull request without that line.
- Review context: start each reviewer fresh. $review_settings Give reviewers the task, acceptance criteria/record links, base/head commits, changed files and relevant standards. They read the diff and necessary source. Follow-up review covers the changed diff and previous findings.
- Validation: rebase on origin/main, then pass the implementing repo's required local checks on the final head. Respect its local-fast / CI-only split. Run focused checks while editing; repeat final checks after code/base/dependency changes or a failure. Required remote checks must be green before the coordinator merges.
- Context: read targeted fields/file ranges; batch independent reads. Return counts/results for successful checks and detailed logs for failures. Before changing UI behavior, find and update affected expectations, including CI-only E2E, while preserving the repo's local-fast / CI-only split. Read the cost policy at $record/docs/agents/agent-costs.md for context handoffs, measurement and escalation; implementation and the two reviewers retain their assigned tiers, and the standalone presentation trial adds no audit agent here.
- Evidence: report effective worker/reviewer model and effort, check results, rework/rebase rounds and available per-thread usage (input, cached input, output, reasoning, requests) on the PR. Missing usage is unknown with a reason, never zero; retain raw transcripts locally.
- Chat: nobody reads this chat. Write no summaries or explanations in it, and work in English. What matters goes on the ticket, the pull request and \`worker_done\`.
- When done, report \`worker_done\` with the pull request's link.
EOF
native "$out"
