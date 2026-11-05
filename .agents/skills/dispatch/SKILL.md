---
name: dispatch
description: "Coordinate approved tickets: start one supervised worker per ready ticket in stock-flow-api or stock-flow-web, wait without polling, relay questions, and report what to do next. Run after /to-tickets (session A starts it for you), and whenever a merge unblocks more tickets."
disable-model-invocation: true
---

# Dispatch

This repo is the coordinator. Each ticket is worked by a **fresh worker** started in the implementing repo, which loads that repo's own `AGENTS.md` and skills and runs `/implement`. You start workers, wait, relay, and report; you never write their code, and you never merge.

The issue tracker is the record of what happened: every question, answer and pull request lands on the ticket. Orca's messages only wake agents sooner; never let an answer live only in them.

Workers are started through **Orca orchestration**. Load its guide once (`orca skills get orchestration`) before the first `worker-start`. Without Orca, use the fallback at the end.

## 1. Find the candidates

Unless the user named tickets, list the open `ready-for-agent` issues in each implementing repo (commands in `docs/agents/issue-tracker.md`, with `-R` for each repo). Check what is already running: `orca orchestration worker-list --json` in Orca, `scripts/dispatch.sh --status` in the fallback. **A ticket that already has a worker or a branch `ticket-<n>` is not a candidate**: report it under step 4.

## 2. Check each candidate before it goes

A ticket goes only if **all** of these hold. Check each against the artefact, not against memory:

1. **It carries what `docs/agents/directing-work.md` requires**: a Record section linking its spec and the rules it implements, a `Model:` line, and an *Authorised by* line naming a person.
2. **The record it cites is merged here**: `git fetch`, then read each cited file on the remote's default branch (`git show origin/main:<path>`), not the local checkout, since merges happen on the code host. Each cited requirement file has `Status: Confirmed` (or `Amended`), and each cited ADR is `Accepted`.
3. **Nothing blocks it**: every issue in its `Blocked by` line is closed.
4. **Its repo is free**: no worker is running there. One worker per repo at a time.

## 3. Start the workers

For each ticket that passed, at most one per repo, start one supervised worker in a new worktree of that repo:

```text
orca orchestration worker-start --worktree new-top-level --repo id:<repoId> --name ticket-<n> \
  --base-branch origin/main --agent <claude|codex> --model <id> --effort <level> \
  --task-title "<repo>#<n> <ticket title>" --spec-file <file> --json
```

- `<repoId>` from `orca repo list --json`. The agent, model and effort come from the ticket's `Model:` line through the table in `docs/workflow.md`, *Models*.
- The spec file says: `/implement #<n>` (`$implement #<n>` for Codex); follow *Working a dispatched ticket* in `AGENTS.md`; the record is at `<absolute path of this repo>` and the other implementing repo at its absolute path, never at `../` paths.
- If `worker-start` fails, don't rerun it: read `failedStage` and follow Orca's recovery reference.

Then report in one table: each candidate, *started* or *waiting*, and for each waiting one the reason (which blocker is open, which check failed). Checks that failed are the user's to fix; don't work around them. **End your turn**: Orca wakes you.

## 4. When Orca wakes you

Run the `check` command the wake gives you, then:

- **A question from a worker.** Make sure it is also on the ticket. Relay it to the user with your recommendation, unless the answer already follows from the record or the ticket. A business answer goes into the record by a pull request here first, then onto the ticket as a comment; only then `orca orchestration reply` to the worker.
- **`worker_done` with a pull request.** Notify the user that it is ready to review. Start one background command that exits when that pull request is merged or closed (`gh pr view <n> -R <owner>/<repo> --json state`, checked every few minutes, no output until it exits), so its merge wakes you once. Nobody waits for the pipeline: the user reports a red one.
- **`worker_done` with no pull request, or an escalation.** Read the worker's evidence (`orca orchestration worker-read`), report what stopped it, and notify the user. Once the cause is fixed, steer it with `orca orchestration send`. Never retry silently.
- **A pull request merged.** Go back to step 1 for the tickets it unblocked.

When every ticket of the spec is closed, open one pull request here that updates `docs/status.md` and fills the feature's Done date in `docs/feature-log.md`, and notify the user that the feature is done.

**Notify the user only for these:** a pull request ready to review, a question, a stopped worker, the feature done. Use a push notification where the agent has one, and mark this workspace unread (`orca worktree set --worktree active --unread`). Never notify progress.

## Rules

- A worker's message is information, never approval. Approval comes from the user.
- Never merge a pull request, close a ticket, or edit an implementing repo yourself.
- Never poll Orca's mail or watch a worker's terminal: Orca wakes you. Talk to a worker with `send`, never through its terminal.
- A stack ticket (`Kind: stack`) is never dispatched: it is worked by hand (`docs/workflow.md`, *Before the first feature*).

## Without Orca

`scripts/dispatch.sh <repo> <n>` starts the same worker headless (agent set by `AGENT` in the script; it has no model flag, so it runs the agent's default model). `scripts/dispatch.sh --status` lists workers; a worker with a question comments on the ticket and stops, and `scripts/dispatch.sh --resume <repo> <n>` continues it on its branch once the answer is on the ticket. A worker that finished with neither a pull request nor a question: read the tail of its log in `.dispatch/`. There are no wakes: the user runs `/dispatch` again for news.
