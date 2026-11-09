# Workflow

How a feature goes from an idea to merged code. Lost? Ask the agent here **"what's next?"**: it works out where you are from the record, the open issues and the running workers, and answers from this page.

First-time setup of a project: [README](../README.md#first-time-setup).

## Before the first feature: choose the stack

Once per project. The stack is decided here, where both repos can be seen at once, and recorded in each implementing repo, where technical decisions live.

| # | You type | You do | The agent does | Next |
| --- | --- | --- | --- | --- |
| S1 | Start the session with `--add-dir ../stock-flow-api --add-dir ../stock-flow-web`, then "grill the stack" | Answer each round; say what the system must support (users, realtime, offline, integrations, hosting budget) | Interviews you with `grilling`, which writes nothing here, and looks facts up with `research`. Settles the shared decisions (API style and contract format, authentication, hosting) and each repo's own, then drafts one stack ticket per repo ([format](agents/directing-work.md#stack-tickets)) | S2 |
| S2 | "publish the stack tickets" | **Approve them** ✋ | Creates one in each implementing repo, without `ready-for-agent` | S3 |
| S3 | In each implementing repo, `stock-flow-api` first since the web client is generated from its contract, a session started with `--add-dir ../stock-flow-context`: "work ticket #<n>" | **Review and merge its pull request** ✋ | Writes one ADR per decision, scaffolds the app so every command in its *Stack and commands* table runs, fills that table and `CODING_STANDARDS.md`, opens the pull request | S4 |
| S4 | "update dispatch for the stack" | **Review and merge them** ✋ | Opens a pull request in each implementing repo that writes `.claude/settings.json`: `permissions.allow` gets that repo's build and test commands plus the git and issue-tracker commands in `CLAUDE_ALLOWED` (`scripts/dispatch.sh`), `permissions.deny` the merge and force-push commands in `CLAUDE_DENIED`. Workers started by Orca and by `dispatch.sh` both read it | S5 |
| S5 | In `stock-flow-web`: "plan the design" | Answer what the product is and who it is for; **review and merge its pull request** ✋ | Drafts the tokens with `ui-ux-pro-max`, has `frontend-design` review them against generic defaults and write the voice (and `prototype` compare candidates, if asked), then writes `docs/design.md` there, which every screen follows. A Figma file or brand guide, when there is one, is the source instead: export it first (`stock-flow-web`'s `docs/design/README.md`), then say "plan the design from Figma" there | 1 |

Stack tickets are worked by hand, not dispatched: a worker may run only the commands its repo's `.claude/settings.json` allows, and those exist only after S4.

What you said the system must support is input to the stack, not yet a requirement: carry it into the first feature's grill, where it becomes rules.

## Choose the work mode

Before work on a new task starts, the agent asks: **"Use Autopilot (default), or Approval workflow?"** It waits for the requirements owner's answer; the default is the recommended/preselected choice, not permission to proceed without an answer. Naming a mode in the request selects it directly. Read-only questions need no selection.

The choice lasts for the whole task, across sessions, tickets and workers. Continuations inherit it; a new task gets a new question. Include `Work mode: autopilot` or `Work mode: approval`, the task scope and the owner's selection in ticket authorisation and coordinator/worker handoffs. If a resumed session cannot find the choice, ask before further work. The owner can switch modes explicitly during a task; apply the new mode to remaining work.

[ADR 0008](adr/0008-choose-workflow-per-task.md) supersedes the standing delegation in ADR 0005. Decisions live in requirements, ADRs and pull requests; there is no separate review queue or review checklist to maintain.

## Autopilot

For a task selected as Autopilot, the agent takes its own recommended answers, merges the record pull request, publishes the spec and tickets, coordinates workers and merges each implementation pull request after the required reviews and a green pipeline. Keep each module to the smallest version that does its job. Change a confirmed decision with `/grill-with-docs`.

The api contract for the whole feature is merged first, as one ticket, so subsequent api and web tickets can run in parallel ([issue-tracker](agents/issue-tracker.md#tickets-when-a-slice-crosses-repos)). `scripts/worker-spec.sh` writes each worker's prompt, `scripts/merge-pr.sh` requires a green pipeline and `code-review` evidence and proves the merge, and `scripts/ready-tickets.sh` lists what can start next.

Once the spec and tickets are published, start the standard/low coordinator as in step 4, passing the selected mode, scope and authorisation in its prompt. Verify the effective model and effort before it dispatches; the defining session hands over and stops coordinating. It merges, starts workers and wakes when Orca wakes it. A question it cannot answer from the record goes back to a deep session.

Stop for credentials, a third-party dashboard, a pipeline still red after two fixes, or a change that could lose stored data. Report blockers and excluded scope in the pull request and task summary. **Approval workflow** uses the owner questions and approval gates below.

## Every feature

After choosing the work mode, a feature runs in two sessions here, plus the workers the second one starts. You type one command, `/grill-with-docs`; in Approval workflow you then answer questions and pass the three ✋ gates: the record, the breakdown, and each pull request.

**Session A: define the work.** A session here on the *deep* model (see [Models](#models)), with you present.

| # | You type | You do | The agent does | Next |
| --- | --- | --- | --- | --- |
| 1 | `/grill-with-docs <the idea>` | Answer each round of questions; "yes" accepts the recommended answer | Adds the feature to the [feature log](feature-log.md) with today's date, asks, and writes the requirement, glossary terms and any ADR as answers land | 2 |
| 2 | "open the record PR" | **Review and merge it** ✋: merging confirms the record | Sets each settled module to `Status: Confirmed` and each new ADR to `Accepted`, runs `scripts/check-links.sh`, updates [status](status.md), opens the pull request with its template filled | 2b or 3 |
| 2b | Optional, when the feature's screens are drawn in Figma: export them, then in `stock-flow-web` "add the frames for <feature>" | **Review and merge it** ✋ | Adds each frame to *Screens* in `stock-flow-web`'s `docs/design.md`, so the spec and web tickets can name it | 3 |
| 3 | `/to-spec` | Confirm the proposed test seams | Writes the spec as an issue in this repo, then goes straight on to step 4 | 4 |
| 4 | Nothing | **Approve the breakdown** ✋, which authorises the build | Runs `/to-tickets`: proposes slices, then publishes one ticket per repo per slice, each with its `Model:` line. Then starts session B using the [coordinator handoff](agents/agent-costs.md#coordinator-handoff), verifies its effective settings and stops coordinating in session A | 5 |

**Session B: coordinate.** Started by session A in Orca, on the *standard* model at low effort. It runs [`dispatch`](../.agents/skills/dispatch/SKILL.md).

| # | You type | You do | The agent does | Next |
| --- | --- | --- | --- | --- |
| 5 | Nothing | Nothing | Checks each ticket is ready, starts one supervised worker per ready ticket in its repo, reports who started and who waits, then waits without spending tokens | 6 |
| 6 | Nothing; it notifies you | Answer workers' questions; **review and merge their pull requests** ✋ (no need to wait for the pipeline) | Wakes on a worker's question, a finished worker or a merge; relays, reports, and starts what a merge has unblocked | repeat 6 until every ticket is closed |

When the last ticket closes, session B updates [status](status.md) and fills the feature's Done date in the [feature log](feature-log.md), in a final pull request here, and tells you the feature is done. It notifies you only then, for a pull request to review, for a question, and for a stopped worker.

Along the way you also confirm the test seams (step 3) and give the go-ahead for any fix ticket.

### When to start a new session

Everything a session needs is in the record and the issue tracker, so a new session loses nothing. Start one when:

- the step needs a different model (session A to session B does this for you);
- you return after a long break and the previous working context is no longer useful; inspect recorded cache usage rather than assuming a fixed expiry;
- the session has grown long: every turn re-sends all of it.

## Models

A ticket names a tier, never a model: `Model: standard` or `Model: deep` ([directing-work](agents/directing-work.md#what-every-ticket-carries)). This table turns a tier into the model each agent runs, so a new model release changes only this table.

| Tier | Claude | Codex |
| --- | --- | --- |
| deep | `claude-opus-5-5` | `gpt-6-astra` |
| standard | `claude-sonnet-5-5` | `gpt-6.1-sol` |
| light | `claude-haiku-5-5` | `gpt-6-luna` |

| Step | Route · effort |
| --- | --- |
| `/grill-with-docs`, `/to-spec`, "plan the design" | deep · high |
| `/to-tickets` | deep · medium |
| Draft settled record text or PR descriptions; add Figma frames; standalone visual audit | presentation · medium (Codex trial below) |
| Extract, format or summarise fixed-source information | light · high |
| Session B, the coordinator | standard · low |
| Worker on a `Model: standard` ticket | standard · medium |
| Worker on a `Model: deep` ticket | deep · high |
| `code-review`'s sub-agents, a fix ticket for a red pipeline | standard · medium |

### Codex presentation trial

For the next three eligible tasks, use `gpt-6.1-terra` at medium effort for writing from confirmed decisions or a standalone screenshot/design/browser audit. This is a role-specific trial, not an implementation ticket tier. Claude keeps standard/medium for these tasks. Use Terra/low only for a short rewrite with explicit acceptance criteria; record the reason. Keep requirement decisions, design direction, implementation and both required code reviewers on the tiers above. A worker's visual checks remain part of its implementation; this trial does not add an audit agent to each ticket.

Follow the [trial register and evaluation](agents/agent-costs.md#terra-trial) before selecting a trial task. After three tasks, use standard/medium for this role until the recorded evaluation decides whether to adopt Terra. Availability and usable effort controls must be verified in the client; the official [model guidance](https://learn.chatgpt.com/docs/models) identifies Terra with writing, visual understanding and computer use. Codex CLI requires version 0.159.0 or later for Terra.

Pin model and effort for workers and trial sessions. Interactive sessions may use an automatic picker outside these roles; report actual settings when measuring them.

Tickets specify `Effort:` and a short reason as well as `Model:`. High effort needs a concrete invariant, unresolved ambiguity or failed medium-effort approach. Verify effective settings in the launch receipt. The [agent cost policy](agents/agent-costs.md) covers fresh reviewer context, coordinator handoff, shared-file concurrency, validation and usage measurement. These controls apply to dispatched work; unverified headless settings are reported as unknown.

## Sometimes

| Situation | What to do |
| --- | --- |
| A confirmed rule changes | `/grill-with-docs`; the change becomes a new ADR that amends the rule. Then step 2 onwards |
| Only someone else can answer | `/to-questionnaire`; it lands in [questionnaires](questionnaires/README.md). File the answers into the record, then carry on |
| A fact can be looked up | Ask for it; the agent uses `research` and writes to [research](research/README.md) |
| A worker asked a question | Answer it in session B. A business answer goes into the record by a pull request first; then session B replies to the worker, which carries on on its own branch |
| A worker stopped with no PR and no question | Session B notifies you with the worker's output. Once the cause is fixed, it steers the worker on. To start the ticket over instead, remove its worktree and branch `ticket-<n>` in that repo first |
| No Orca (another ADE, or a plain terminal) | Run `/dispatch` in a session here: it falls back to `scripts/dispatch.sh`, which starts headless workers. Nothing wakes the coordinator then, so run `/dispatch` again whenever you want news. The rules and the gates are the same |
| You see a red pipeline | Tell the agent here, e.g. "api PR #3 is red". It reads the failing job and, with your go-ahead, opens a fix ticket in that repo and `/dispatch`es it like any other. If the pull request isn't merged yet, the fix can go on its branch instead: fix it in a session in that repo |
| The design changes in Figma | Re-export what changed, then in `stock-flow-web` "update the design from Figma". What each kind of change leads to: `stock-flow-web`'s `docs/design/README.md`, *When the design changes* |
| Update the agent skills | Say "update skills". The agent runs `scripts/update-all-skills.sh` for all three repos and shows each diff; commit each in its repo |
