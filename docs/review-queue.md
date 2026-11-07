# Review queue

What the agent decided on the requirements owner's behalf under [ADR 0005](adr/0005-autopilot.md), for the owner to review. Each row links to where the decision lives.

To keep a decision, tick it. To change one, run `/grill-with-docs` here: the change becomes a new ADR, and its pull request removes the row.

## Process

- [ ] [ADR 0005](adr/0005-autopilot.md): the agent decides, merges and answers workers' questions until the owner supersedes it.

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
