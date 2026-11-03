# Workflow

How a feature goes from an idea to merged code. Lost? Ask the agent here **"what's next?"**: it works out where you are from the record, the open issues and the running workers, and answers from this page.

First-time setup of a project: [README](../README.md#first-time-setup).

## Before the first feature: choose the stack

Once per project. The stack is decided here, where both repos can be seen at once, and recorded in each implementing repo, where technical decisions live.

| # | You type | You do | The agent does | Next |
| --- | --- | --- | --- | --- |
| S1 | Start the session with `--add-dir ../template-api --add-dir ../template-web`, then "grill the stack" | Answer each round; say what the system must support (users, realtime, offline, integrations, hosting budget) | Interviews you with `grilling`, which writes nothing here, and looks facts up with `research`. Settles the shared decisions (API style and contract format, authentication, hosting) and each repo's own, then drafts one stack ticket per repo ([format](agents/directing-work.md#stack-tickets)) | S2 |
| S2 | "publish the stack tickets" | **Approve them** ✋ | Creates one in each implementing repo, without `ready-for-agent` | S3 |
| S3 | In each implementing repo, `template-api` first since the web client is generated from its contract, a session started with `--add-dir ../template-context`: "work ticket #<n>" | **Review and merge its pull request** ✋ | Writes one ADR per decision, scaffolds the app so every command in its *Stack and commands* table runs, fills that table and `CODING_STANDARDS.md`, opens the pull request | S4 |
| S4 | "update dispatch for the stack" | **Review and merge it** ✋ | Adds each repo's build and test commands to `CLAUDE_ALLOWED` in `scripts/dispatch.sh`, in a pull request here | S5 |
| S5 | In `template-web`: "plan the design" | Answer what the product is and who it is for; **review and merge its pull request** ✋ | Drafts the tokens with `ui-ux-pro-max`, has `frontend-design` review them against generic defaults and write the voice (and `prototype` compare candidates, if asked), then writes `docs/design.md` there, which every screen follows. A Figma file or brand guide, when there is one, is the source instead: export it first (`template-web`'s `docs/design/README.md`), then say "plan the design from Figma" there | 1 |

Stack tickets are worked by hand, not dispatched: a worker may run only the commands `scripts/dispatch.sh` allows, and those exist only after S4.

What you said the system must support is input to the stack, not yet a requirement: carry it into the first feature's grill, where it becomes rules.

## Every feature

| # | You type | You do | The agent does | Next |
| --- | --- | --- | --- | --- |
| 1 | `/grill-with-docs <the idea>` | Answer each round of questions; "yes" accepts the recommended answer | Adds the feature to the [feature log](feature-log.md) with today's date, asks, and writes the requirement, glossary terms and any ADR as answers land | 2 |
| 2 | "open the record PR" | **Review and merge it** ✋: merging confirms the record | Sets each settled module to `Status: Confirmed` and each new ADR to `Accepted`, runs `scripts/check-links.sh`, updates [status](status.md), opens the pull request with its template filled | 2b or 3 |
| 2b | Optional, when the feature's screens are drawn in Figma: export them, then in `template-web` "add the frames for <feature>" | **Review and merge it** ✋ | Adds each frame to *Screens* in `template-web`'s `docs/design.md`, so the spec and web tickets can name it | 3 |
| 3 | `/to-spec` | Confirm the proposed test seams | Writes the spec as an issue in this repo | 4 |
| 4 | `/to-tickets` | **Approve the breakdown** ✋, which authorises the build | Proposes slices, then publishes one ticket per repo per slice | 5 |
| 5 | `/dispatch` | Nothing | Checks each ticket is ready, starts a fresh agent per ready ticket in its repo, reports who started and who waits | 6 |
| 6 | `/dispatch` again, whenever you want news | Answer workers' questions; **review and merge their pull requests** ✋ (no need to wait for the pipeline) | Reports each ticket (PR open, question, failed, still working) and starts what a merge has unblocked | repeat 6 until every ticket is closed |

When the last ticket closes, the agent updates [status](status.md) and fills the feature's Done date in the [feature log](feature-log.md), in a final pull request here.

The three ✋ are the gates: the record, the breakdown, and each pull request. Along the way you also confirm the test seams (step 3) and give the go-ahead for any fix ticket.

## Sometimes

| Situation | What to do |
| --- | --- |
| A confirmed rule changes | `/grill-with-docs`; the change becomes a new ADR that amends the rule. Then step 2 onwards |
| Only someone else can answer | `/to-questionnaire`; it lands in [questionnaires](questionnaires/README.md). File the answers into the record, then carry on |
| A fact can be looked up | Ask for it; the agent uses `research` and writes to [research](research/README.md) |
| A worker asked a question | Answer it here. The answer goes into the record by a pull request first; then the agent resumes the worker on its own branch (`/dispatch` does this) |
| A worker finished with no PR and no question | `/dispatch` shows the end of its log. Once the cause is fixed, it resumes the worker on its branch. To start the ticket over instead, remove its worktree and branch in that repo (`git worktree remove .worktrees/ticket-<n>`, `git branch -D ticket-<n>`) first |
| You see a red pipeline | Tell the agent here, e.g. "api PR #3 is red". It reads the failing job and, with your go-ahead, opens a fix ticket in that repo and `/dispatch`es it like any other. If the pull request isn't merged yet, the fix can go on its branch instead: fix it in a session in that repo |
| The design changes in Figma | Re-export what changed, then in `template-web` "update the design from Figma". What each kind of change leads to: `template-web`'s `docs/design/README.md`, *When the design changes* |
| Update the agent skills | Say "update skills". The agent runs `scripts/update-all-skills.sh` for all three repos and shows each diff; commit each in its repo |
