# Review queue

What the agent decided on the requirements owner's behalf under [ADR 0005](adr/0005-autopilot.md), for the owner to review. Each row links to where the decision lives.

To keep a decision, tick it. To change one, run `/grill-with-docs` here: the change becomes a new ADR, and its pull request removes the row.

## Process

- [ ] [ADR 0005](adr/0005-autopilot.md): the agent decides, merges and answers workers' questions until the owner supersedes it.
- [ ] [Contract first](agents/issue-tracker.md#tickets-when-a-slice-crosses-repos): under Autopilot, a feature's api operations are merged first, answering 501, so api and web tickets run in parallel. Until each slice lands, the deployed api answers 501 on its operations and the deployed web shows those screens' error state; acceptable while nothing is live.
- [ ] [Model tiers](agents/directing-work.md#what-every-ticket-carries): `deep` only for concurrency, transactions, and authentication; every web screen is `standard`.
- [ ] [Dispatch](../.agents/skills/dispatch/SKILL.md#autopilot): up to two workers per repo at once, when their tickets build different screens or endpoints.

## Products

- [ ] [Products](requirements/products.md), every rule. The ones most worth a look:
  - [ ] R3: a SKU is letters, digits and hyphens, unique regardless of case, and can be changed.
  - [ ] R5: prices are in Thai baht to the satang, up to ฿9,999,999.99.
  - [ ] R6, R7: the Product Form never sets stock; a new Product starts at 0 and gets stock by a Receive.
  - [ ] R9: Low means stock above 0 and at or below the Minimum stock.
  - [ ] R11, R12: Products are Archived, never deleted; an Archived Product takes no Receive, Adjustment or new Order.
  - [ ] R15: Staff see prices.
  - [ ] *Out of scope*: Product images, left out because the Supabase bucket needs the owner (`stock-flow-api` ADR 0009).
- [ ] [ADR 0006](adr/0006-stock-changes-only-through-movements.md): stock changes only through Stock movements, which are never edited.

## Stock movements

- [ ] [Stock movements](requirements/stock-movements.md), every rule. The ones most worth a look:
  - [ ] R4: every Role, Staff included, can Receive.
  - [ ] R5: only the Owner and Admins make Adjustments, and each needs a note.
  - [ ] R6: no movement takes stock below 0.

## Orders

- [ ] [Orders](requirements/orders.md), every rule. The ones most worth a look:
  - [ ] R7, R8: an Order takes its stock when created, and is refused whole if any line asks for too much.
  - [ ] R10 to R13: Pending, then Completed or Cancelled; both final.
  - [ ] R11: any Role completes an Order. R12: only the Owner and Admins cancel one.
  - [ ] R14: Orders are never edited; cancel and create a new one.
  - [ ] R1: the customer is a name only, not a record.
- [ ] [ADR 0007](adr/0007-orders-take-stock-when-created.md): an Order takes its stock when created, and is never edited.

## Dashboard & reports

- [ ] [Dashboard & reports](requirements/dashboard-and-reports.md), every rule. The ones most worth a look:
  - [ ] R1: the Shop's days run on Bangkok time.
  - [ ] R2: Sales count Completed Orders only, on the day they were completed.
  - [ ] R3 to R6: what the Dashboard shows.
  - [ ] R7, R8: what Reports show, and the 366-day limit.

## Read into the record by the implementing repos

Choices the workers made where the record was silent. None adds a business rule; each is in its pull request.

- [ ] [api#26](https://github.com/thawatchaiUdjan/stock-flow-api/pull/26), Products: a SKU's letters are A to Z only; stock and Minimum stock stop at 2,147,483,647 (a larger value answers 422); the Product List pages by offset and shows a total.
- [ ] [api#27](https://github.com/thawatchaiUdjan/stock-flow-api/pull/27), Stock movements: the list pages by cursor, as the Login log does.
- [ ] [api#28](https://github.com/thawatchaiUdjan/stock-flow-api/pull/28), Orders: a refused Order may leave a gap in the Order numbers.
- [ ] [api#29](https://github.com/thawatchaiUdjan/stock-flow-api/pull/29), Dashboard & reports: the figures are read one after another, so an Order completed while the page loads can show in one figure and not yet in another (R9, a window of milliseconds).
- [ ] [web#28](https://github.com/thawatchaiUdjan/stock-flow-web/pull/28), Orders: an Order is written "Order #12" everywhere, where the spec said "Order 12".
- [ ] [api#26](https://github.com/thawatchaiUdjan/stock-flow-api/pull/26), Products: the List's `total` comes from a second query, so a Product created between the two can make it differ from the rows by one. Kept: the write rate is tiny.
- [ ] [api#29](https://github.com/thawatchaiUdjan/stock-flow-api/pull/29), Dashboard & reports: a Sales report given only `to` starts on the first day of that month (R7 says only "this month so far by default").

## How the work was checked

- [ ] Every pull request was merged by the agent on a green pipeline, with no human review.
- [ ] Four of them ran without `code-review` (api#26, api#29, web#27, web#30): Orca's worker preamble forbids sub-agents unless the task asks, and those workers took it to cover `code-review`'s. On 2026-11-08 the agent reviewed the four afterwards and found eleven issues, all low. The ones worth fixing are in [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) and [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). Workers' prompts now ask for the sub-agents, and `scripts/merge-pr.sh` merges nothing without the review line.
