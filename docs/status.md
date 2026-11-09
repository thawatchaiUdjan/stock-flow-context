# Status

Where each module stands across the three repos. Update it in the same pull request as the change that moved it.

UI repair (2026-11-09): completed in [web PR #42](https://github.com/thawatchaiUdjan/stock-flow-web/pull/42), under the owner's explicit task-scoped Autopilot selection (ADR 0008). Stock movements columns and notes are readable; mobile navigation uses an opaque in-flow grid; date controls show readable day/default guidance and Bangkok Today/Clear actions. The full-list audit verified existing paging, including Login log, and repaired Reports paging in no-sales/loading/error states. Dashboard and Reports already resolved the correct shared chart colours, verified in the browser. [Audit and screenshots](https://github.com/thawatchaiUdjan/stock-flow-web/blob/main/docs/audits/ticket-41.md) cover 375/768/1024/1440 px and all roles. Existing business rules, summary bounds, report date defaults and API contracts are unchanged. [Spec #29](https://github.com/thawatchaiUdjan/stock-flow-context/issues/29).

| Module | Requirements | API | Web | Notes |
| --- | --- | --- | --- | --- |
| [Navigation & lists](requirements/navigation-and-lists.md) | Confirmed | Done (existing contracts) | Done | [Spec #23](https://github.com/thawatchaiUdjan/stock-flow-context/issues/23); [branding/navigation PR](https://github.com/thawatchaiUdjan/stock-flow-web/pull/39) and [pagination PR](https://github.com/thawatchaiUdjan/stock-flow-web/pull/40) merged on green pipelines. |
| [Users & access](requirements/users-and-access.md) | Amended | Done | Done | Security review 2026-11-08: login throttling and the password minimum are open questions there. Two concurrency findings, reasoned but not reproduced, are listed in [stock-flow-api#19](https://github.com/thawatchaiUdjan/stock-flow-api/pull/19): a possible deadlock between Update User or Reset password and Log out, and overlapping logins starving a password set. Ticket them if seen. |
| [Products](requirements/products.md) | Confirmed | Done | Done | Decided by the agent under [ADR 0005](adr/0005-autopilot.md). Review follow-up done: [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) (blank names in any script). |
| [Stock movements](requirements/stock-movements.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. |
| [Orders](requirements/orders.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. Review follow-up done: [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). |
| [Dashboard & reports](requirements/dashboard-and-reports.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. Review follow-ups done: [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) (index), [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). |

**Requirements:** `Draft` · `Confirmed` · `Amended`
**API / Web:** `Not started` · `In progress` · `Done` · `Diverges` (built differently from the record; say how in Notes)

Workflow: [ADR 0008](adr/0008-choose-workflow-per-task.md) requires a mode choice before each new task (Autopilot default, or Approval workflow) and removes the review queue. Unresolved findings remain in [security notes](security-notes.md).

Workflow: [agent cost policy](agents/agent-costs.md) confirmed under ADR 0005 on 2026-11-09. Standard workers default to medium; dispatched review briefs use fresh context. Measurement compares the next three tasks; savings are not yet established. Product module implementation status is unchanged.

Kept deliberately small:

- **Open questions are not copied here.** They live in each module's file; a copy drifts.
- **Pull request and pipeline state is not tracked here.** The code host already shows it, and a hand-copied PR state is the first thing to go stale.
- One stale row means the whole board needs checking: a board drifts as a whole.
