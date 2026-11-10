# Status

Where each module stands across the three repos. Update it in the same pull request as the change that moved it.

Stock movements and Login log pagination repair (2026-11-10): pending web implementation of [Navigation & lists R8](requirements/navigation-and-lists.md), retaining cursor paging and adding persistent page-size selection. Existing API contracts suffice. Owner-selected task-scoped Autopilot under ADR 0008.

Date-picker presentation repair (2026-11-10): completed in [web PR #46](https://github.com/thawatchaiUdjan/stock-flow-web/pull/46), closing [ticket #45](https://github.com/thawatchaiUdjan/stock-flow-web/issues/45) for [spec #37](https://github.com/thawatchaiUdjan/stock-flow-context/issues/37). Larger captions, regular selected typography, separated day fills and outlined year actions apply to all four pickers; short viewports scroll the calendar. Date-controls R1-R10 remain unchanged. Two independent standard/medium reviews and the presentation/medium rendered audit passed after corrections; 475 local tests and required checks passed, with remote check/E2E/smoke green before scripts/merge-pr.sh proved MERGED. Owner-selected Autopilot under ADR 0008.

Date-picker implementation (2026-11-09): [Date controls](requirements/date-controls.md) adopts the PR #32 proposal under the owner-selected Autopilot scope for all date pickers. Optional bounds use selected-day deselection; Reports shows effective defaults beside the controls without adding them to the address. Completed in [web PR #44](https://github.com/thawatchaiUdjan/stock-flow-web/pull/44), closing [ticket #43](https://github.com/thawatchaiUdjan/stock-flow-web/issues/43) for [spec #34](https://github.com/thawatchaiUdjan/stock-flow-context/issues/34), following [record PR #33](https://github.com/thawatchaiUdjan/stock-flow-context/pull/33). Both independent reviews passed after fixes; required check, E2E and smoke jobs were green before the prescribed merge script proved MERGED. Existing API contracts suffice.

Historical date-picker research (2026-11-09): [empty states and alternatives to Today/Clear](research/2026-11-09-date-picker-empty-state.md) records primary-source findings and a proposed presentation for all From/To controls. The owner selected task-scoped Autopilot under ADR 0008 for research documentation. This is research only; the web design direction and implementation have not changed. No requirement or module status changes.

UI repair (2026-11-09): completed in [web PR #42](https://github.com/thawatchaiUdjan/stock-flow-web/pull/42), under the owner's explicit task-scoped Autopilot selection (ADR 0008). Stock movements columns and notes are readable; mobile navigation uses an opaque in-flow grid; date controls show readable day/default guidance and Bangkok Today/Clear actions. The full-list audit verified existing paging, including Login log, and repaired Reports paging in no-sales/loading/error states. Dashboard and Reports already resolved the correct shared chart colours, verified in the browser. [Audit and screenshots](https://github.com/thawatchaiUdjan/stock-flow-web/blob/main/docs/audits/ticket-41.md) cover 375/768/1024/1440 px and all roles. Existing business rules, summary bounds, report date defaults and API contracts are unchanged. [Spec #29](https://github.com/thawatchaiUdjan/stock-flow-context/issues/29).

| Module | Requirements | API | Web | Notes |
| --- | --- | --- | --- | --- |
| [Date controls](requirements/date-controls.md) | Confirmed | Done (existing contracts) | Done | All four pickers and web design direction completed in [web PR #44](https://github.com/thawatchaiUdjan/stock-flow-web/pull/44); [spec #34](https://github.com/thawatchaiUdjan/stock-flow-context/issues/34). |
| [Navigation & lists](requirements/navigation-and-lists.md) | Confirmed | Done (existing contracts) | Diverges | R8 pagination repair pending; [Spec #23](https://github.com/thawatchaiUdjan/stock-flow-context/issues/23); [branding/navigation PR](https://github.com/thawatchaiUdjan/stock-flow-web/pull/39) and [pagination PR](https://github.com/thawatchaiUdjan/stock-flow-web/pull/40) merged on green pipelines. |
| [Users & access](requirements/users-and-access.md) | Amended | Done | Done | Security review 2026-11-08: login throttling and the password minimum are open questions there. Two concurrency findings, reasoned but not reproduced, are listed in [stock-flow-api#19](https://github.com/thawatchaiUdjan/stock-flow-api/pull/19): a possible deadlock between Update User or Reset password and Log out, and overlapping logins starving a password set. Ticket them if seen. |
| [Products](requirements/products.md) | Confirmed | Done | Done | Decided by the agent under [ADR 0005](adr/0005-autopilot.md). Review follow-up done: [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) (blank names in any script). |
| [Stock movements](requirements/stock-movements.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. |
| [Orders](requirements/orders.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. Review follow-up done: [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). |
| [Dashboard & reports](requirements/dashboard-and-reports.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. Review follow-ups done: [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) (index), [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). |

**Requirements:** `Draft` · `Confirmed` · `Amended`
**API / Web:** `Not started` · `In progress` · `Done` · `Diverges` (built differently from the record; say how in Notes)

Workflow: [ADR 0008](adr/0008-choose-workflow-per-task.md) requires a mode choice before each new task (Autopilot default, or Approval workflow) and removes the review queue. Unresolved findings remain in [security notes](security-notes.md).

Workflow: [agent cost policy](agents/agent-costs.md) initially confirmed under ADR 0005 and refined on 2026-11-09 through the owner's task-scoped Autopilot selection under ADR 0008. [Presentation routing](workflow.md#presentation-work) now uses Terra immediately for settled-source writing and visual audits, including the visual-audit phase of Codex UI implementation; the three-task trial and adoption gate are removed. Coordinator remains standard/low; implementation and both independent code reviewers keep their assigned routes. Task PRs record actual auditor settings, findings, usage and any explicit fallback. Savings are not yet established. Product module implementation status is unchanged.

Kept deliberately small:

- **Open questions are not copied here.** They live in each module's file; a copy drifts.
- **Pull request and pipeline state is not tracked here.** The code host already shows it, and a hand-copied PR state is the first thing to go stale.
- One stale row means the whole board needs checking: a board drifts as a whole.
