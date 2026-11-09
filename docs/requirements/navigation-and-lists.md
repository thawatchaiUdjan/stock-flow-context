# Navigation & lists

Status: Confirmed (2026-11-09, requirements owner; details decided by agent under ADR 0005)

## Purpose

Every User can identify StockFlow, return to their landing page and move between the pages their Role allows. Lists remain manageable as records grow.

## Rules

- **R1** The application has a project icon beside the StockFlow name in the sidebar. Together they form one accessible link to the User's landing page (Users & access R12); the equivalent home link is available on a phone.
- **R2** Main navigation lists destinations, excluding New product and New order. Creating a Product or Order starts from its list. Removing these navigation items does not change access to the forms or their direct links (Users & access R11, R22).
- **R3** Authenticated pages have a top navigation bar indicating the current page and linking to its parent list when applicable. Main navigation highlights Products for Product forms and Orders for Order forms and details. Navigation respects the User's Role and remains usable on a phone and with a keyboard.
- **R4** The Product List, Orders List, Users list, Stock movements and Login log display one bounded page of records at a time, with visible paging controls even when there is only one page. Loading, errors and empty results have explicit states; an unavailable direction cannot be activated.
- **R5** Product List, Orders List and Users list offer a page size of 10, 25 or 50, defaulting to 25, and show the current page and matching count. Searches, filters and page size survive paging and reloads; changing a search, filter or page size returns to the first page. A page beyond the available results offers a working way back to valid results.
- **R6** Stock movements and Login log retain cursor paging with clearly named older and newest controls and an indication when viewing older entries. They never imply that the API supplies a total or arbitrary page jumps. Their filters survive paging and reloads.
- **R7** The Reports daily sales table is paginated at 25 rows per page; its chart and totals still describe the full selected date range. Its bounded Top products table and Dashboard summaries are not paginated.

## Out of scope

- Changing Role permissions, landing destinations, list sort order or business operations.
- Changing API contracts where existing responses suffice: Products and Orders already supply offset paging and totals; Stock movements and Login log supply cursors; Users and Reports can page their complete responses in the web app.
- A new colour scheme. Icon artwork and navigation layout belong in the web repo's design direction.

## Open questions

None. The requirements owner requested the icon, home link, removal of the two create shortcuts, paginated lists and a navigation bar. R3's top-bar interpretation and R4-R7's detailed paging behaviour are agent decisions under ADR 0005, recorded in the review queue.
