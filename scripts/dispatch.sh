#!/usr/bin/env bash
# Starts a fresh agent in an implementing repo to work one ticket, in the background.
# The fallback for when Orca isn't available: /dispatch starts workers through Orca
# orchestration otherwise (docs/workflow.md, "No Orca").
#
#   scripts/dispatch.sh <repo> <ticket>            start a ticket: new branch ticket-<n>, new worktree
#   scripts/dispatch.sh --resume <repo> <ticket>   continue it on its existing branch, e.g. after a
#                                                  question was answered or a failure was fixed
#   scripts/dispatch.sh --status                   running workers, and every ticket dispatched so far
#
# The worker runs in its own git worktree, so it never touches the repo's main checkout.
# One worker per repo at a time. The worker reports back on the ticket and its pull
# request; this script only starts it and keeps its pid and log under .dispatch/.
set -euo pipefail

# Physical paths: permission rules match the resolved path, not a symlink to it.
CONTEXT="$(cd "$(dirname "$0")/.." && pwd -P)"
WORKSPACE="$(dirname "$CONTEXT")"
STATE="$CONTEXT/.dispatch"

# The agent CLI the workers run: claude | codex. Switching to codex is a one-word change here.
AGENT="claude"

# Rename if the repos are renamed. They must be cloned next to this repo.
REPOS=(stock-flow-api stock-flow-web)

# Claude workers: what they may run unattended, on top of your own permission settings,
# and what they may never run. The Edit rules set below cover the file tools only; a
# shell command can still write anywhere the Bash allowlist reaches, so keep it narrow.
# Each repo's build and test commands live in its own .claude/settings.json, not here.
CLAUDE_ALLOWED=(
  "Bash(git *)"
  "Bash(gh issue view *)" "Bash(gh issue comment *)" "Bash(gh pr create *)" "Bash(gh pr view *)"
  "Bash(glab issue view *)" "Bash(glab issue note *)" "Bash(glab mr create *)" "Bash(glab mr view *)"
)
CLAUDE_DENIED=(
  "Bash(git -C *)" "Bash(git push --force *)" "Bash(git push -f *)" "Bash(git push --force-with-lease *)"
  "Bash(gh pr merge *)" "Bash(glab mr merge *)"
)

# Codex workers run in the workspace-write sandbox, which only lets them write inside
# their worktree (plus /tmp and $TMPDIR, so keep the workspace outside those). Network
# is needed to push and to reach the issue tracker. Codex has no per-command rules:
# "never merge" rests on AGENTS.md alone.
CODEX_CONFIG=(-c sandbox_workspace_write.network_access=true)

usage() {
  echo "usage: scripts/dispatch.sh [--resume] <repo> <ticket-number> | --status" >&2
  exit 2
}

status() {
  local found=0 pidfile repo pid ticket log
  for pidfile in "$STATE"/*.pid; do
    [ -e "$pidfile" ] || continue
    found=1
    repo="$(basename "$pidfile" .pid)"
    read -r pid ticket < "$pidfile"
    if kill -0 "$pid" 2>/dev/null; then
      echo "$repo: working ticket #$ticket (pid $pid)"
    else
      echo "$repo: idle; last worker finished ticket #$ticket"
    fi
  done
  [ "$found" -eq 1 ] || echo "no workers have run yet"
  for log in "$STATE"/*.log; do
    [ -e "$log" ] || continue
    echo "dispatched: $(basename "$log" .log)  (log .dispatch/$(basename "$log"))"
  done
}

mkdir -p "$STATE"

resume=0
case "${1:-}" in
  --status) status; exit 0 ;;
  --resume) resume=1; shift ;;
esac
[ "$#" -eq 2 ] || usage
repo="$1"
ticket="$2"

case " ${REPOS[*]} " in
  *" $repo "*) ;;
  *) echo "dispatch: unknown repo '$repo' (expected one of: ${REPOS[*]})" >&2; exit 2 ;;
esac
case "$ticket" in
  ''|*[!0-9]*) echo "dispatch: ticket must be a number, got '$ticket'" >&2; exit 2 ;;
esac
case "$AGENT" in
  claude|codex) ;;
  *) echo "dispatch: unknown AGENT '$AGENT' (expected claude or codex)" >&2; exit 2 ;;
esac
if ! command -v "$AGENT" > /dev/null; then
  echo "dispatch: '$AGENT' is not on PATH" >&2
  exit 1
fi

target="$WORKSPACE/$repo"
if [ ! -d "$target/.git" ]; then
  echo "dispatch: $target is not a git repo; is $repo cloned next to this repo?" >&2
  exit 1
fi

pidfile="$STATE/$repo.pid"
if [ -e "$pidfile" ]; then
  read -r pid running < "$pidfile"
  if kill -0 "$pid" 2>/dev/null; then
    echo "dispatch: $repo already has a worker on ticket #$running (pid $pid); one at a time" >&2
    exit 1
  fi
fi

branch="ticket-$ticket"
worktree="$target/.worktrees/$branch"
has_branch=0
git -C "$target" show-ref --verify --quiet "refs/heads/$branch" && has_branch=1

if [ "$resume" -eq 0 ]; then
  if [ "$has_branch" -eq 1 ] || [ -e "$worktree" ]; then
    echo "dispatch: ticket #$ticket was already dispatched to $repo (branch $branch exists)." >&2
    echo "          To continue it, use --resume; to start over, remove the worktree and branch first." >&2
    exit 1
  fi
  # Start from the remote's default branch, so the worker builds on merged work.
  # A failed fetch would silently start it from stale code, so it stops here instead.
  base="HEAD"
  if git -C "$target" remote get-url origin > /dev/null 2>&1; then
    if ! git -C "$target" fetch --quiet origin; then
      echo "dispatch: fetching origin in $repo failed; not starting from stale code" >&2
      exit 1
    fi
    base="$(git -C "$target" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)" \
      || { git -C "$target" remote set-head origin --auto > /dev/null 2>&1 \
           && base="$(git -C "$target" symbolic-ref --quiet --short refs/remotes/origin/HEAD)"; } \
      || { git -C "$target" show-ref --verify --quiet refs/remotes/origin/main && base="origin/main"; } \
      || { echo "dispatch: can't tell $repo's default branch (no origin/HEAD, no origin/main)" >&2; exit 1; }
  fi
  git -C "$target" worktree add --quiet -b "$branch" "$worktree" "$base"
else
  if [ "$has_branch" -eq 0 ]; then
    echo "dispatch: ticket #$ticket has no branch $branch in $repo; nothing to resume" >&2
    exit 1
  fi
  [ -e "$worktree" ] || git -C "$target" worktree add --quiet "$worktree" "$branch"
fi

# A worktree sits two levels below the repo root, so the docs' ../<sibling> paths
# don't resolve from it; the note gives the absolute ones.
siblings=""
read_dirs=("$CONTEXT")
readonly_rules=("Edit(/$CONTEXT/**)") # a leading "//" marks an absolute path
for other in "${REPOS[@]}"; do
  [ "$other" = "$repo" ] && continue
  siblings="$siblings $other at $WORKSPACE/$other;"
  read_dirs+=("$WORKSPACE/$other")
  readonly_rules+=("Edit(/$WORKSPACE/$other/**)")
done
note="You were dispatched by $(basename "$CONTEXT") to work ticket #$ticket. Follow 'Working a dispatched ticket' in AGENTS.md. In this worktree, read the record at $CONTEXT and the sibling repos at their absolute paths:$siblings never at ../ paths."
if [ "$resume" -eq 1 ]; then
  note="$note This is a resumed run: the branch already holds earlier work. Read the ticket's newest comments first and continue from there."
fi

log="$STATE/$repo-$ticket.log"
echo "=== $(date '+%Y-%m-%d %H:%M:%S') $([ "$resume" -eq 1 ] && echo resumed || echo started) with $AGENT" >> "$log"

if [ "$AGENT" = "claude" ]; then
  # --add-dir makes the record and siblings readable; the deny rules keep them read-only,
  # since acceptEdits would otherwise accept edits there too.
  (cd "$worktree" && exec claude -p "/implement #$ticket $note" \
      --add-dir "${read_dirs[@]}" --permission-mode acceptEdits \
      --disallowedTools "${readonly_rules[@]}" "${CLAUDE_DENIED[@]}" \
      --allowedTools "${CLAUDE_ALLOWED[@]}") < /dev/null >> "$log" 2>&1 &
else
  # No --add-dir: the sandbox can already read outside the worktree, and --add-dir
  # would make those directories writable.
  codex exec -C "$worktree" -s workspace-write "${CODEX_CONFIG[@]}" \
      "\$implement #$ticket $note" < /dev/null >> "$log" 2>&1 &
fi

echo "$! $ticket" > "$pidfile"
echo "dispatch: $repo ticket #$ticket $([ "$resume" -eq 1 ] && echo resumed || echo started) with $AGENT (pid $!), worktree $worktree, log .dispatch/$repo-$ticket.log"
