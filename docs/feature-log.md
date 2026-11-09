# Feature log

When each feature started and finished, so "how long did X take?" has an answer with evidence behind it.

| Feature | Started | Done | Days | Links |
| --- | --- | --- | --- | --- |
| Navigation & lists: project icon, home link, navigation bar and pagination | 2026-11-09 | | | Requirements owner's design request; [rules](requirements/navigation-and-lists.md) |
| Users & access: login, roles, access by role | 2026-11-06 | 2026-11-06 | 1 | [Record PR](https://github.com/thawatchaiUdjan/stock-flow-context/pull/3), [Spec](https://github.com/thawatchaiUdjan/stock-flow-context/issues/4) |
| Products: the product list and form | 2026-11-07 | 2026-11-07 | 1 | [Record PR](https://github.com/thawatchaiUdjan/stock-flow-context/pull/10), [Spec](https://github.com/thawatchaiUdjan/stock-flow-context/issues/11) |
| Stock movements: receive, adjust, history | 2026-11-07 | 2026-11-07 | 1 | [Record PR](https://github.com/thawatchaiUdjan/stock-flow-context/pull/10), [Spec](https://github.com/thawatchaiUdjan/stock-flow-context/issues/12) |
| Orders: create, complete, cancel | 2026-11-07 | 2026-11-07 | 1 | [Record PR](https://github.com/thawatchaiUdjan/stock-flow-context/pull/10), [Spec](https://github.com/thawatchaiUdjan/stock-flow-context/issues/13) |
| Dashboard & reports | 2026-11-07 | 2026-11-07 | 1 | [Record PR](https://github.com/thawatchaiUdjan/stock-flow-context/pull/10), [Spec](https://github.com/thawatchaiUdjan/stock-flow-context/issues/14) |

- **Feature:** a short name for what was grilled; one row per `/grill-with-docs` run on a new feature or a rule change.
- **Started:** the day `/grill-with-docs` began, `YYYY-MM-DD`. Written as the grill begins.
- **Done:** the day the feature's last ticket closed. Written in the final pull request that updates [status](status.md). A feature dropped before then gets `Dropped YYYY-MM-DD`.
- **Days:** calendar days from Started to Done, both counted. Filled with Done.
- **Links:** the record pull request and the spec issue. The spec links its tickets and their pull requests.

The evidence for each date is this file's `git log` and the timestamps on the linked pull requests and issues.
