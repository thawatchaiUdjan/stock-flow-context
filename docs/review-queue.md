# Review queue

What the agent decided on the requirements owner's behalf under [ADR 0005](adr/0005-autopilot.md), for the owner to review. Each row links to where the decision lives.

To keep a decision, tick it. To change one, run `/grill-with-docs` here: the change becomes a new ADR, and its pull request removes the row.

## Start here

Short on time? These five carry the most weight; the rest can wait.

1. [ ] The [security review](#security-review-2026-11-08) below: login has no throttling, and the password minimum is 6 characters.
2. [ ] [ADR 0007](adr/0007-orders-take-stock-when-created.md): an Order takes its stock when created, and is never edited.
3. [ ] [ADR 0006](adr/0006-stock-changes-only-through-movements.md): stock changes only through Stock movements.
4. [ ] [Dashboard & reports](requirements/dashboard-and-reports.md) R1, R2: days run on Bangkok time; Sales count Completed Orders on the day they completed.
5. [ ] [How the work was checked](#how-the-work-was-checked): what was merged with no human review.

## Process

- [ ] [Agent cost policy](agents/agent-costs.md), settled 2026-11-09: standard workers medium, coordinator low, explicit medium reviewers with fresh context; high effort justified per ticket. Sequence shared-file work, follow each repo's local/CI split, retain two reviews and the green-pipeline merge gate. Deduplicate usage and compare the next three standard tasks before claiming savings. This changes dispatched work only; manual sessions and unverified headless defaults are not claimed to be pinned.

- [ ] [ADR 0005](adr/0005-autopilot.md): the agent decides, merges and answers workers' questions until the owner supersedes it.
- [ ] [Contract first](agents/issue-tracker.md#tickets-when-a-slice-crosses-repos): under Autopilot, a feature's api operations are merged first, answering 501, so api and web tickets run in parallel. Until each slice lands, the deployed api answers 501 on its operations and the deployed web shows those screens' error state; acceptable while nothing is live.
- [ ] [Model tiers](agents/directing-work.md#what-every-ticket-carries): `deep` only for concurrency, transactions, and authentication; every web screen is `standard`.
- [ ] [Dispatch](../.agents/skills/dispatch/SKILL.md#autopilot): up to two workers per repo at once, when their tickets build different screens or endpoints.

## Navigation & lists (2026-11-09)

- [ ] [Navigation & lists R3](requirements/navigation-and-lists.md): interpret the requested navigation bar as a responsive top bar with current-page context and parent-list links, alongside the existing main navigation.
- [ ] [Navigation & lists R4-R6](requirements/navigation-and-lists.md): always-visible paging, 10/25/50 rows (25 default) for counted lists; retain cursor paging for histories. Page Users in the web app using the complete API response.
- [ ] [Navigation & lists R7](requirements/navigation-and-lists.md): page the daily sales table at 25 rows, retaining full-range chart and totals; keep bounded Top products and Dashboard summaries intact. No API changes needed.

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

- [ ] Every required text field (Product name and unit, User name, Adjustment note) treats a value of only whitespace, in any script, as blank ([users-and-access](requirements/users-and-access.md) R14, [stock-movements](requirements/stock-movements.md) R5, [products](requirements/products.md) R2, R4). Built in [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) and [api#34](https://github.com/thawatchaiUdjan/stock-flow-api/issues/34).

## How the work was checked

- [ ] Every pull request was merged by the agent on a green pipeline, with no human review.
- [ ] Four of them ran without `code-review` (api#26, api#29, web#27, web#30): Orca's worker preamble forbids sub-agents unless the task asks, and those workers took it to cover `code-review`'s. On 2026-11-08 the agent reviewed the four afterwards and found eleven issues, all low. The ones worth fixing are in [api#30](https://github.com/thawatchaiUdjan/stock-flow-api/issues/30) and [web#31](https://github.com/thawatchaiUdjan/stock-flow-web/issues/31). Workers' prompts now ask for the sub-agents, and `scripts/merge-pr.sh` merges nothing without the review line.

## Security review (2026-11-08)

A read-only review of authentication, sessions and authorization in `stock-flow-api` on `main`, and of how `stock-flow-web` holds the session. Nothing is ticketed yet: the first two findings change confirmed rules, so they need a decision first.

- [ ] **High: login has no throttling or lockout.** Anyone can guess passwords at `POST /login` without limit, for example against the Owner's email. Each attempt runs an Argon2id hash and writes a Login log row. `/setup-link/password` hashes the password before it checks the token, so bad-token calls also burn CPU. A fix needs a rule in [Users & access](requirements/users-and-access.md): how many failures, over what window, and what happens next.
- [ ] **Medium: passwords need only 6 characters** ([Users & access](requirements/users-and-access.md) R19), with no maximum and no deny-list. With no throttling, `123456` falls quickly.
- [ ] **Medium: no security headers on the web origin.** `stock-flow-web/vercel.json` sets no CSP, `frame-ancestors`, nosniff or Referrer-Policy, so the app can be framed (clickjacking). This is technical and can be ticketed in the web repo.
- [ ] **Medium: the api is reachable directly** at its own Vercel origin, so throttling and headers must live in the api itself. Client-IP handling for the Login log ([api ADR 0022](https://github.com/thawatchaiUdjan/stock-flow-api/tree/main/docs/adr), still Proposed) is untested on the second Vercel hop.
- [ ] **Low:** CSRF protection rests on SameSite=Lax alone. That is safe on `vercel.app`, but not if the app moves to a custom domain whose parent domain has untrusted subdomains. Orders have no maximum number of lines, and a quantity has no maximum. Sessions last 7 days with no idle timeout.
- Found sound: 128-bit random session and setup tokens, stored hashed. The cookie is HttpOnly, Secure and SameSite=Lax. Setup links are single-use and atomic. Passwords use Argon2id with a constant-time compare. Every login failure gets one identical 401. Every route has a role check. SQL is fully parameterized. No secrets are committed.
- Not checked: the Vercel and Supabase dashboards, a dependency CVE scan, and the full git history for secrets.
