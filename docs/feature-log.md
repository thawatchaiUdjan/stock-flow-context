# Feature log

When each feature started and finished, so "how long did X take?" has an answer with evidence behind it.

| Feature | Started | Done | Days | Links |
| --- | --- | --- | --- | --- |

- **Feature:** a short name for what was grilled; one row per `/grill-with-docs` run on a new feature or a rule change.
- **Started:** the day `/grill-with-docs` began, `YYYY-MM-DD`. Written as the grill begins.
- **Done:** the day the feature's last ticket closed. Written in the final pull request that updates [status](status.md). A feature dropped before then gets `Dropped YYYY-MM-DD`.
- **Days:** calendar days from Started to Done, both counted. Filled with Done.
- **Links:** the record pull request and the spec issue. The spec links its tickets and their pull requests.

The evidence for each date is this file's `git log` and the timestamps on the linked pull requests and issues.
