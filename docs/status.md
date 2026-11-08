# Status

Where each module stands across the three repos. Update it in the same pull request as the change that moved it.

| Module | Requirements | API | Web | Notes |
| --- | --- | --- | --- | --- |
| [Users & access](requirements/users-and-access.md) | Amended | Done | Done | Two concurrency findings, reasoned but not reproduced, are listed in [stock-flow-api#19](https://github.com/thawatchaiUdjan/stock-flow-api/pull/19): a possible deadlock between Update User or Reset password and Log out, and overlapping logins starving a password set. Ticket them if seen. |
| [Products](requirements/products.md) | Confirmed | Done | Done | Decided by the agent under [ADR 0005](adr/0005-autopilot.md). Review follow-up open: [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) (blank names in any script). |
| [Stock movements](requirements/stock-movements.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. |
| [Orders](requirements/orders.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. Review follow-up open: [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). |
| [Dashboard & reports](requirements/dashboard-and-reports.md) | Confirmed | Done | Done | Decided by the agent under ADR 0005. Review follow-ups open: [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) (index), [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). |

**Requirements:** `Draft` · `Confirmed` · `Amended`
**API / Web:** `Not started` · `In progress` · `Done` · `Diverges` (built differently from the record; say how in Notes)

Kept deliberately small:

- **Open questions are not copied here.** They live in each module's file; a copy drifts.
- **Pull request and pipeline state is not tracked here.** The code host already shows it, and a hand-copied PR state is the first thing to go stale.
- One stale row means the whole board needs checking: a board drifts as a whole.
