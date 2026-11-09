# Agent workflow cost

Policy for dispatched work, initially settled on 2026-11-09 under [ADR 0005](../adr/0005-autopilot.md), with immediate presentation routing and handoff refinements authorised by the owner's task-scoped Autopilot selection under [ADR 0008](../adr/0008-choose-workflow-per-task.md) on the same date. Model IDs and effort defaults live in [Workflow: Models](../workflow.md#models). Product requirements and the green-pipeline merge gate remain unchanged.

## Decisions

The requirements owner's request to reduce workflow cost has the following settled design tree:

| Decision | Choice | Trade-off |
| --- | --- | --- |
| Target | Lower measured task cost, retaining required checks and two independent reviewers | Raw token totals alone do not measure cost or quality |
| Model/effort | Keep implementation tiers; presentation uses the workflow route immediately; standard workers medium, coordinator low, reviewers medium | Measure real tasks and escalate for demonstrated difficulty |
| Review context | Fresh context, explicit settings and a self-contained brief | Reviewers read relevant source rather than inherit the implementation narrative |
| Concurrency | Parallel same-repo work only when expected shared-file changes are independent too | Sequencing coupled changes costs elapsed time but reduces rework |
| Validation | Repo-prescribed local checks on the final head; required remote checks green before merge | Slow/real-service checks stay in CI where the repo requires them |
| Measurement | Deduplicated per-response usage; unknown remains unknown | Counts are observations, not invoices or promised savings |
| Scope | Generated dispatched tasks for both implementing repos, coordinator handoffs and presentation work, including Codex UI audit phases | Manual implementation sessions keep their repo policy; upstream installed skills are not patched |

## Applying the policy

Tickets carry `Model:`, `Effort:` and a one-sentence reason. High effort needs a concrete invariant, ambiguity or failed approach that medium did not resolve. Deep remains for concurrency, transactions and authentication. Combine closely coupled UI changes or sequence them when separate deliverables still help.

Start coordination through the [handoff](#coordinator-handoff). The headless fallback reports actual settings when known and otherwise unknown; it cannot claim to enforce defaults it does not set.

For Codex reviewers use `fork_turns="none"`, explicitly selecting the standard model and medium effort. Their brief contains the task, acceptance criteria/record links, base/head commits, changed-file list and relevant standards. They inspect the diff and necessary surrounding source, returning actionable findings with locations. Use fresh review context on other agents where supported; report unsupported controls. Follow-up review covers the changed diff and previous findings; materially changed scope requires renewed coverage.

Read targeted fields and file ranges. Successful checks return results and counts; retrieve detailed logs for failures. Run focused checks during edits, then the repo's required final local set. Repeat final checks when code, base, dependencies or prior results change, or a required check is missing. Scripts wait for remote checks; the coordinator waits for completion/mail instead of repeatedly querying unchanged status.

Before changing UI behavior, find tests that assert the old behavior, including CI-only E2E, and update the affected expectations in the same change. Preserve the repo's local-fast / CI-only split. Before returning a large tool result, select the fields or ranges needed for the next decision. At a phase boundary, if history is no longer useful, start a fresh session with a compact handoff rather than rereading the full transcript; resume from recorded artifacts and preserve required review coverage. Record available first/peak/final input sizes to expose context growth; cached history still consumes context.

Include known spec/ticket links and progress in the record PR; otherwise add missing links in the completion PR. Ordinary progress lives on tickets, avoiding a separate record PR solely to change Not started to In progress. Requirement changes and business answers still require a merged record before implementation.

## Coordinator handoff

Session A publishes the spec/tickets, then launches a fresh session B using the standard model from the workflow table and explicit low effort:

```text
orca agent launch --agent <agent> --worktree path:<absolute-context-repo-path> --model <standard-model> --effort low --prompt "/dispatch; Work mode: <selected-mode>; Scope: <task>; Authorised by: <owner selection>; Spec/tickets: <links>; Dispatch IDs: <existing IDs or none>; Blockers: <list or none>; Next action: <action>" --json
```

Include the launch receipt in the handoff. Check requested versus effective settings; if the receipt does not expose them, session B checks its observable session metadata before starting workers. A launch request alone is not verification. Session A stops coordination after delivery; session B owns subsequent actions. At `/dispatch` entry, a session with different settings hands off before starting workers. If settings cannot be verified or applied, report the capability gap and actual/unknown settings on the task; do not claim compliance. Without a supported launcher, provide the handoff for a separately started standard/low session instead of silently coordinating at high effort.

## Presentation routing

The requirements owner replaced the three-task experiment with immediate use on 2026-11-09. The workflow table is the source for model IDs. Use presentation/medium for settled-source writing and visual audits; use the normal PR and task evidence, with no trial slots or adoption approval. Requirement discovery and new design decisions retain the definition route. Code changes and the two independent code reviews retain their assigned routes.

For a Codex UI implementation ticket, the implementation worker delegates the visual-audit phase to one presentation/medium auditor after the UI is runnable. This auditor supplements Standards and Spec; it does not replace either. Its brief includes the confirmed design/requirements, acceptance criteria, exact head, app URL or local run instructions, viewport/role/state coverage and artifact locations. The auditor checks screenshots and rendered behavior, reports actionable findings and evidence, and leaves implementation edits to the worker. The worker fixes findings and obtains follow-up on affected screens before reporting completion. Relevant UI changes after audit require renewed coverage.

Use a fresh Codex auditor with explicit model, medium effort and `fork_turns="none"` where sub-agents are supported. Generated web-worker briefs authorise this bounded third agent. If nesting or browser access prevents the worker from running it, ask the root coordinator to launch the auditor at the same checkout/head and return its evidence; avoid an intermediate coordinator solely to relay launches. The worker may prepare the app and capture artifacts, but cannot present its own Sol inspection as a Terra audit. The coordinator checks audit evidence and actual model/effort before merging UI work. API-only or nonvisual changes report visual audit as not applicable with a reason. Claude retains its existing visual-validation process using the workflow's presentation route.

Standalone presentation work runs directly in the selected presentation session. Draft PR text in the current presentation session when available; otherwise use one bounded drafting handoff with the confirmed facts. Batch related writing into that handoff rather than spawning a writer for every comment. Follow the existing task's mode, repo access and approval rules; presentation work authorises no unrelated agents or sibling edits.

Record elapsed time, actual model/effort, requests, input/cached/uncached input, output/reasoning, available context sizes, findings, correction rounds and acceptance-check results in the normal task PR. Include auditor and fallback usage in task totals; missing data stays unknown with a reason. If the presentation model is unavailable, controls cannot be applied or the task remains incorrect after one correction round, record the reason and use standard/medium for that task. Scope requiring new rules returns to the definition route. Fallback is an explicit exception, not a silent default. Raw token totals are not subscription billing; no saving is assumed.

### Reference observation

The 2026-11-09 UI repair ([web PR #42](https://github.com/thawatchaiUdjan/stock-flow-web/pull/42)) used Sol/high for the defining/coordinating session and Sol/medium for the worker and two fresh reviewers. Deduplicated local usage through 10:35:30 UTC: 138 requests; 15,462,202 input, including 15,075,968 cached and 386,234 uncached; 63,162 output, including 17,522 reasoning. Worker input grew from 22,911 to 219,329 per request. The PR merged with green check/E2E/smoke after one review-fix and one CI-fix round. This is a whole-task observation, not an isolated visual-audit benchmark or evidence about Terra. Raw transcripts remain local.

## Measuring tasks

Run `python scripts/agent-usage.py <rollout.jsonl> ...` on Codex logs with per-response `token_usage_record` entries. Optional `--until <UTC ISO timestamp>` excludes later work such as its audit. The script excludes inherited records from other threads, deduplicates response IDs and lists unsupported logs as unknown. It reports no prices. Keep raw transcripts local.

Attach a compact summary to the spec/completion PR: effective model/effort including reviewers, requests, input, cached input, uncached input, output, reasoning, rework/rebase rounds and check results. Missing usage is unknown, with a reason; collecting it does not justify starting another agent. Cached input is part of input and reasoning is part of output: neither is added twice.

Compare the next three completed standard tasks with the 2026-11-09 navigation/pagination baseline: 178 requests, 15,343,466 input (14,633,728 cached), 49,617 output (including 6,880 reasoning), across coordinator, two workers and four reviewers. This is a local-log observation excluding its later audit, not billing evidence or a controlled model comparison. Compare rework and defects too; no percentage saving is assumed.
