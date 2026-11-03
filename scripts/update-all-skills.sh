#!/usr/bin/env bash
# Refreshes the agent skills of all three repos, so they never drift onto
# different versions.
#
# Each repo is refreshed by its own scripts/install-skills.sh, which owns that
# repo's skill list. Nothing is committed: review and commit each repo's change
# in that repo, on a branch, like any other change.
set -uo pipefail

cd "$(dirname "$0")/../.."

# Rename if the repos are renamed. They must be cloned side by side.
REPOS=(stock-flow-context stock-flow-api stock-flow-web)

failed=0
for repo in "${REPOS[@]}"; do
  echo "== $repo"
  if [ ! -x "$repo/scripts/install-skills.sh" ]; then
    echo "update-all-skills: $repo/scripts/install-skills.sh not found; is $repo cloned next to this repo?" >&2
    failed=1
    continue
  fi
  if ! (cd "$repo" && ./scripts/install-skills.sh > /dev/null); then
    echo "update-all-skills: $repo failed; re-run its scripts/install-skills.sh to see why" >&2
    failed=1
    continue
  fi
  # Report what changed on disk, not what the installer said.
  changes="$(git -C "$repo" status --short -- skills-lock.json .agents .claude)"
  if [ -z "$changes" ]; then
    echo "up to date"
  else
    echo "$changes"
  fi
done

exit "$failed"
