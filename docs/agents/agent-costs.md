# Agent workflow cost

Policy for dispatched work, settled on 2026-11-09 under [ADR 0005](../adr/0005-autopilot.md). Model IDs and effort defaults live in [Workflow: Models](../workflow.md#models). Product requirements and the green-pipeline merge gate remain unchanged.

## Decisions

The requirements owner's request to reduce workflow cost has the following settled design tree:

| Decision | Choice | Trade-off |
| --- | --- | --- |
| Target | Lower measured task cost, retaining required checks and two independent reviewers | Raw token totals alone do not measure cost or quality |
| Model/effort | Keep model tiers; standard workers medium, coordinator low, reviewers medium | Escalate for demonstrated difficulty |
| Review context | Fresh context, explicit settings and a self-contained brief | Reviewers read relevant source rather than inherit the implementation narrative |
| Concurrency | Parallel same-repo work only when expected shared-file changes are independent too | Sequencing coupled changes costs elapsed time but reduces rework |
| Validation | Repo-prescribed local checks on the final head; required remote checks green before merge | Slow/real-service checks stay in CI where the repo requires them |
| Measurement | Deduplicated per-response usage; unknown remains unknown | Counts are observations, not invoices or promised savings |
| Scope | Generated dispatched tasks for both implementing repos | Manual sessions keep their repo policy; upstream installed skills are not patched |

## Applying the policy

Tickets carry `Model:`, `Effort:` and a one-sentence reason. High effort needs a concrete invariant, ambiguity or failed approach that medium did not resolve. Deep remains for concurrency, transactions and authentication. Combine closely coupled UI changes or sequence them when separate deliverables still help.

Start coordination in a separate standard/low session with spec/ticket links, dispatch IDs, blockers and the next action. Verify effective settings in the launch receipt. Report unsupported/unapplied controls as capability gaps. The headless fallback reports actual settings when known and otherwise unknown; it cannot claim to enforce defaults it does not set.

For Codex reviewers use `fork_turns="none"`, explicitly selecting the standard model and medium effort. Their brief contains the task, acceptance criteria/record links, base/head commits, changed-file list and relevant standards. They inspect the diff and necessary surrounding source, returning actionable findings with locations. Use fresh review context on other agents where supported; report unsupported controls. Follow-up review covers the changed diff and previous findings; materially changed scope requires renewed coverage.

Read targeted fields and file ranges. Successful checks return results and counts; retrieve detailed logs for failures. Run focused checks during edits, then the repo's required final local set. Repeat final checks when code, base, dependencies or prior results change, or a required check is missing. Scripts wait for remote checks; the coordinator waits for completion/mail instead of repeatedly querying unchanged status.

Include known spec/ticket links and progress in the record PR; otherwise add missing links in the completion PR. Ordinary progress lives on tickets, avoiding a separate record PR solely to change Not started to In progress. Requirement changes and business answers still require a merged record before implementation.

## Measuring tasks

Run `python scripts/agent-usage.py <rollout.jsonl> ...` on Codex logs with per-response `token_usage_record` entries. Optional `--until <UTC ISO timestamp>` excludes later work such as its audit. The script excludes inherited records from other threads, deduplicates response IDs and lists unsupported logs as unknown. It reports no prices. Keep raw transcripts local.

Attach a compact summary to the spec/completion PR: effective model/effort including reviewers, requests, input, cached input, uncached input, output, reasoning, rework/rebase rounds and check results. Missing usage is unknown, with a reason; collecting it does not justify starting another agent. Cached input is part of input and reasoning is part of output: neither is added twice.

Compare the next three completed standard tasks with the 2026-11-09 navigation/pagination baseline: 178 requests, 15,343,466 input (14,633,728 cached), 49,617 output (including 6,880 reasoning), across coordinator, two workers and four reviewers. This is a local-log observation excluding its later audit, not billing evidence or a controlled model comparison. Compare rework and defects too; no percentage saving is assumed.
