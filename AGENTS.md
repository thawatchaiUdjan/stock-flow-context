# AGENTS.md

## What this repo is

The record for stock-flow: what the system must do, for whom, and under what rules. **No code lives here.** Two repos implement what this repo states:

| Repo | Role | Local path | Remote (`owner/repo`) |
| --- | --- | --- | --- |
| `stock-flow-context` | **This repo.** Requirements, business decisions, vocabulary | `.` | `thawatchaiUdjan/stock-flow-context` |
| `stock-flow-api` | Backend. Publishes the API contract | `../stock-flow-api` | `thawatchaiUdjan/stock-flow-api` |
| `stock-flow-web` | Frontend. Consumes the API contract | `../stock-flow-web` | `thawatchaiUdjan/stock-flow-web` |

The project is a practice project for frontend development: [README](README.md#project-goal).

To read a sibling repo, start the session with `--add-dir ../stock-flow-api` (or `../stock-flow-web`). Read them; never edit them from here. The only things this repo runs in them are `scripts/update-all-skills.sh` and the workers `/dispatch` starts (through Orca orchestration, or `scripts/dispatch.sh` without Orca).

## What belongs here

Ask of any decision: **would it still stand if both implementing repos were rewritten in another stack?** Yes → it belongs here. No → it belongs in the repo that implements it.

| Kind | Where |
| --- | --- |
| What the system must do, for whom, under what rules | `docs/requirements/<module>.md`, format in `docs/requirements/README.md` |
| A business decision, or a change to a confirmed requirement | `docs/adr/NNNN-slug.md`, rules in `docs/agents/domain.md` |
| Shared vocabulary | `GLOSSARY.md` |
| Where each module stands across the three repos | `docs/status.md` |
| When each feature started and finished | `docs/feature-log.md` |
| Specs | Issues in this repo |
| Tickets | Issues in the implementing repo, per `docs/agents/directing-work.md` |
| Language, framework, schema, library, deployment | not here: the implementing repo's own `docs/adr/`. The stack is still chosen from here, once, by `grilling` and stack tickets: `docs/workflow.md`, *Before the first feature* |

Link to the sibling repos' docs; never copy them. A copy drifts from its source.

## Authoring rules

- **Never write a requirement from assumption.** A plausible invented rule is worse than a blank, because the next agent builds on it. Whatever you cannot confirm goes under that module's `## Open questions`.
- **Finding facts is your job; decisions are the requirements owner's.** Look up what is discoverable (the design, the sibling repos, a standard) yourself, with the `research` skill when it needs sources. Put only decisions to the owner.
- **The record leads.** A rule reaches an implementing repo only after its requirement or ADR is merged here. Directing that work: `docs/agents/directing-work.md`.
- In prose, the person who decides requirements is the *requirements owner* (thawatchaiUdjan, project owner). A dev may decide within what the owner leaves to devs, and takes the rest to the owner.

## Guiding the user

The steps, with what the user types at each: `docs/workflow.md`. End every step by naming the next one and its command. When asked "what's next?", work out where things stand from the record, the open issues in all three repos and the running workers (`orca orchestration worker-list --json`, or `scripts/dispatch.sh --status` without Orca), then answer from that page. Until both implementing repos have merged their stack, and `stock-flow-web` its design direction (`docs/design.md`), the next step is *Before the first feature*.

## Where skill output goes

- `research` notes: `docs/research/`, per its README.
- `/to-questionnaire` writes `to-questionnaire-<slug>.md` in the repo root. Move it to `docs/questionnaires/` in the same change.

## Updating skills

When asked to update or check the agent skills, update **all three repos**: run `./scripts/update-all-skills.sh`. It refreshes each repo with that repo's own `scripts/install-skills.sh` and reports what changed. Then show each repo's diff; each change is committed in its own repo, on a branch.

## Definition of done (any change here)

- Every rule written is confirmed, or listed under `## Open questions` instead.
- Every new domain term is in `GLOSSARY.md`.
- Every new ADR follows `docs/agents/domain.md`.
- `docs/status.md` reflects the change, in the same pull request.
- `docs/feature-log.md` has the feature's row: Started added when `/grill-with-docs` begins, Done when its last ticket closes.
- `./scripts/check-links.sh` exits 0: every relative link resolves to a file that exists.
- Every decision in it was made by the requirements owner, or by a dev within what the owner left to devs. The pull request template says which.

## Commits & pull requests

The record, commits, pull requests and tickets are written in English, whatever language the session itself uses. Conventional commits (`docs(<module>): ...`). Work on a branch; `main` is the record. Open a pull request (a merge request on GitLab) for every change, and fill every section of its template.

## Agent skills

### Issue tracker

Issues on GitHub or GitLab: specs in this repo, tickets in the implementing repo. See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `GLOSSARY.md` and `docs/adr/` at this repo's root, shared by all three repos. See `docs/agents/domain.md`.
