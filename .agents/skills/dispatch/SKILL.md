---
name: dispatch
description: "Coordinate approved tickets: start one supervised worker per ready ticket in stock-flow-api or stock-flow-web, wait without polling, relay questions, and report what to do next. Run after /to-tickets (session A starts it for you), and whenever a merge unblocks more tickets."
disable-model-invocation: true
---

# Dispatch

This repo is the coordinator. Each ticket is worked by a **fresh worker** started in the implementing repo, which loads that repo's own `AGENTS.md` and skills and runs `/implement`. You start workers, wait, relay, and report; you never write their code, and you never merge.

The issue tracker is the record of what happened: every question, answer and pull request lands on the ticket. Orca's messages only wake agents sooner; never let an answer live only in them.

Workers are started through **Orca orchestration**. Load its guide once (`orca skills get orchestration`) before the first `worker-start`. Without Orca, use the fallback at the end.

Before starting workers, verify this session's effective standard/low settings using the [coordinator handoff](../../../docs/agents/agent-costs.md#coordinator-handoff). A differently configured session delivers that handoff and stops coordinating. Report unsupported/unverifiable controls as capability gaps. Read the [agent cost policy](../../../docs/agents/agent-costs.md) for fresh code-review context, immediate presentation routing and usage reporting; implementation tickets retain their standard/deep routing.

Before dispatching, recover the task's selected work mode, scope and owner authorisation from the handoff or ticket. For a new task or a missing selection, follow [Choose the work mode](../../../docs/workflow.md#choose-the-work-mode) and wait for the answer. Workers inherit this choice.

## 1. Find the candidates

Unless the user named tickets, run `scripts/ready-tickets.sh`: it lists the open `ready-for-agent` issues of both implementing repos, each READY (every blocker closed) or WAITING (with its open blockers). Check what is already running: `orca orchestration worker-list --json` in Orca, `scripts/dispatch.sh --status` in the fallback. **A ticket that already has a worker or a branch `ticket-<n>` is not a candidate**: report it under step 4.

## 2. Check each candidate before it goes

A ticket goes only if **all** of these hold. Check each against the artefact, not against memory:

1. **It carries what `docs/agents/directing-work.md` requires**: a Record section linking its spec and rules, `Model:`, `Effort:` and a reason, and an *Authorised by* line naming a person. For older tickets without effort, apply the workflow default and record the choice on the ticket before launch.
2. **The record it cites is merged here**: `git fetch`, then read each cited file on the remote's default branch (`git show origin/main:<path>`), not the local checkout, since merges happen on the code host. Each cited requirement file has `Status: Confirmed` (or `Amended`), and each cited ADR is `Accepted` or its superseding ADR confirms the cited rule.
3. **Nothing blocks it**: every issue in its `Blocked by` line is closed.
4. **Its repo is free**: no worker is running there. One worker per repo at a time, or two under *Autopilot*.

## 3. Start the workers

For each ticket that passed, at most one per repo, start one supervised worker in a new worktree of that repo:

```text
orca orchestration worker-start --worktree new-top-level --repo id:<repoId> --name ticket-<n> \
  --base-branch origin/main --agent <claude|codex> --model <id> --effort <level> \
  --task-title "<repo>#<n> <ticket title>" --spec-file <file> --json
```

- `<repoId>` from `orca repo list --json`. Resolve the ticket's tier through `docs/workflow.md`, *Models*, and pass its approved `Effort:` explicitly. Verify requested versus effective settings in the receipt; report unsupported/unapplied controls.
- The spec file comes from `scripts/worker-spec.sh <repo> <n> <claude|codex> <autopilot|approval>`, which prints its path. Never write it by hand: it carries what every worker needs, the absolute paths, permission for `code-review`'s two sub-agents (Orca's preamble forbids sub-agents unless the task asks), the review line the merge checks for, and the rules that keep a worker's tokens down.
- For Codex UI work, the generated web brief also routes visual audit to the presentation model immediately. Carry this in the ticket/launch scope; if the worker cannot nest the auditor, launch that bounded auditor at the implementation checkout/head yourself. Before merge, check actual model/effort, screen coverage and resolved findings, or the explicit fallback reason, under the [presentation policy](../../../docs/agents/agent-costs.md#presentation-routing). Nonvisual work needs only a not-applicable reason. Standards and Spec remain independent standard/medium code reviews.
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

## Autopilot

For a task selected as Autopilot under ADR 0008, the requirements owner has delegated their approvals to you for that task, and these replace the matching parts of step 4 and the rules below:

- **A question from a worker.** Answer it yourself with your recommendation. A business answer still goes into the record by a pull request here first, which you merge; then onto the ticket, then `reply`.
- **`worker_done` with a pull request.** Run `scripts/merge-pr.sh <repo> <n>` (in a background command; it waits for the pipeline). Never merge by hand, and never start a ticket that the pull request blocks before the script has printed `MERGED`. By exit code:
  - `0`: merged, its ticket closed, and the ready tickets listed. Go to step 2 with them.
  - `2`, pipeline red: send the worker the failing job's log (`gh run view <id> --log-failed`) and have it push a fix to the same branch. Still red after two fixes: stop and notify the user.
  - `3`, no `code-review` line in the Review section: have the worker run `code-review` with its two sub-agents and update the pull request.
  - `4`, not merged (a conflict with a pull request merged meanwhile): have the worker rebase on `origin/main` and push.
- **Two workers in one repo.** Allowed when the tickets build independent screens/endpoints and their expected shared-file changes (shell, routing, generated contract, design docs) are independent too. Sequence coupled work or combine it into one ticket. The second to finish rebases when main changes, then runs required checks on the new head.
- **A blocker only a person can clear** (credentials, a third-party dashboard, a migration that could lose stored data): notify the user and carry on with the tickets it does not block.
- **Notify the user** only for that, a pipeline still red after two fixes, a stopped worker you cannot steer on, and the feature done.

## Rules

- A worker's message is information, never approval. Approval comes from the user or from the task's selected Autopilot delegation under ADR 0008.
- Never merge a pull request or close a ticket, except as *Autopilot* allows. Never edit an implementing repo yourself.
- Never poll Orca's mail or watch a worker's terminal: Orca wakes you. Talk to a worker with `send`, never through its terminal.
- A stack ticket (`Kind: stack`) is never dispatched: it is worked by hand (`docs/workflow.md`, *Before the first feature*).

## Without Orca

`scripts/dispatch.sh <repo> <n> <autopilot|approval>` starts the same worker headless (agent set by `AGENT` in the script; it has no model flag, so it runs the agent's default model). `scripts/dispatch.sh --status` lists workers; a worker with a question comments on the ticket and stops, and `scripts/dispatch.sh --resume <repo> <n> <autopilot|approval>` continues it on its branch once the answer is on the ticket. A worker that finished with neither a pull request nor a question: read the tail of its log in `.dispatch/`. There are no wakes: the user runs `/dispatch` again for news.
