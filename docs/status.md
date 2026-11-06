# Status

Where each module stands across the three repos. Update it in the same pull request as the change that moved it.

| Module | Requirements | API | Web | Notes |
| --- | --- | --- | --- | --- |
| [Users & access](requirements/users-and-access.md) | Amended | Done | Done | Two concurrency findings, reasoned but not reproduced, are listed in [stock-flow-api#19](https://github.com/thawatchaiUdjan/stock-flow-api/pull/19): a possible deadlock between Update User or Reset password and Log out, and overlapping logins starving a password set. Ticket them if seen. |

**Requirements:** `Draft` · `Confirmed` · `Amended`
**API / Web:** `Not started` · `In progress` · `Done` · `Diverges` (built differently from the record; say how in Notes)

Kept deliberately small:

- **Open questions are not copied here.** They live in each module's file; a copy drifts.
- **Pull request and pipeline state is not tracked here.** The code host already shows it, and a hand-copied PR state is the first thing to go stale.
- One stale row means the whole board needs checking: a board drifts as a whole.
