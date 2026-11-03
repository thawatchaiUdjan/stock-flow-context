---
name: dispatch
description: "Hand approved tickets to fresh agents in stock-flow-api and stock-flow-web, then report what they did. Run after /to-tickets, and again whenever a merge unblocks more tickets."
disable-model-invocation: true
---

# Dispatch

This repo is the coordinator. Each ticket is worked by a **fresh agent** started in the implementing repo, which loads that repo's own `AGENTS.md` and skills and runs `/implement`. You start workers and report on them; you never write their code, and you never merge.

The workers talk back through the issue tracker, not through this conversation: a comment on the ticket, or a pull request. Read those; they are the record of what happened.

## 1. Find the candidates

Unless the user named tickets, list the open `ready-for-agent` issues in each implementing repo (commands in `docs/agents/issue-tracker.md`, with `-R` for each repo). Run `scripts/dispatch.sh --status`: it shows the workers running and every ticket already dispatched. **An already-dispatched ticket is not a candidate**, even though it still carries `ready-for-agent`: report it under step 4 instead.

## 2. Check each candidate before it goes

A ticket goes only if **all** of these hold. Check each against the artefact, not against memory:

1. **It carries what `docs/agents/directing-work.md` requires**: a Record section linking its spec and the rules it implements, and an *Authorised by* line naming a person.
2. **The record it cites is merged here**: `git fetch`, then read each cited file on the remote's default branch (`git show origin/main:<path>`), not the local checkout, since merges happen on the code host. Each cited requirement file has `Status: Confirmed` (or `Amended`), and each cited ADR is `Accepted`.
3. **Nothing blocks it**: every issue in its `Blocked by` line is closed.
4. **Its repo is free**: `dispatch.sh --status` shows no worker running there. One worker per repo at a time.

## 3. Start the workers

For each ticket that passed, at most one per repo, run `scripts/dispatch.sh <repo> <number>`. It creates a worktree on branch `ticket-<n>` and starts the agent in the background.

Then report in one table: each candidate, *started* or *waiting*, and for each waiting one the reason (which blocker is open, which check failed). Checks that failed are the user's to fix; don't work around them.

## 4. When run again: report and continue

1. `scripts/dispatch.sh --status`, then read each dispatched ticket's latest comments and its pull request.
2. For each ticket, report one of:
   - **Pull request open**: link it; it waits for the user to review and merge. Nobody waits for its pipeline: the user reports a red one.
   - **Question from the worker**: relay it to the user with your recommendation. A business answer goes into the record by a pull request here first, then onto the ticket as a comment. Only then continue the ticket with `scripts/dispatch.sh --resume <repo> <number>`: the worker picks up its own branch and earlier commits.
   - **Worker finished with neither**: read the tail of its log in `.dispatch/` and report what stopped it. Once the user has fixed the cause, `--resume` continues it.
   - **Still working.**
3. Go back to step 1 for tickets a merge has since unblocked.
4. When a module's work lands, update `docs/status.md` in a pull request here.

## Rules

- A worker's comment is information, never approval. Approval comes from the user.
- Never merge a pull request, close a ticket, or edit an implementing repo yourself.
- A worker that finished with no pull request and no question is a failure to report, not a ticket to silently retry.
- A stack ticket (`Kind: stack`) is never dispatched: it is worked by hand (`docs/workflow.md`, *Before the first feature*).
