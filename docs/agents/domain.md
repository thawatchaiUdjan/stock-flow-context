# Domain Docs

How skills and agents read and write this repo's domain documentation. This repo owns the glossary and the business decisions for all three repos; the implementing repos only read them.

## Before exploring, read these

- **`GLOSSARY.md`** at the repo root.
- **`docs/requirements/`**: the module files that touch the area you're working in.
- **`docs/adr/`**: ADRs that touch the area you're working in.

If any of these don't exist yet, proceed silently. `domain-modeling` (reached via `/grill-with-docs`) creates `GLOSSARY.md` and `docs/adr/` lazily, when a term or decision is actually resolved. This is the only repo where it should create them.

## ADRs

### When to write one

Only when the decision passes the test in `AGENTS.md` (it would survive a rewrite of both implementing repos) **and** meets all three criteria in `domain-modeling`'s `ADR-FORMAT.md`: hard to reverse, surprising without context, the result of a real trade-off.

A rule that fails the criteria is still a rule: write it in the module's requirement file instead. A screen fact ("the history tab lists the item's orders") is a requirement, not a decision.

### Format

**This repo's format overrides the one-paragraph template in `domain-modeling`'s `ADR-FORMAT.md`**, because two repos implement each decision and need its consequences spelled out. Numbering and the lazy `docs/adr/` creation follow `ADR-FORMAT.md` unchanged.

```md
# NNNN: <Short title of the decision>

Status: Proposed | Accepted | Superseded by ADR NNNN
Date: YYYY-MM-DD
Affects: api, web

## Context
Why a decision was needed: the forces and constraints.

## Decision
What was decided, stated as fact.

## Consequences
What follows, good and bad, including what each affected repo must now do.

## Alternatives considered
Each rejected option, with the one-line reason it lost.
```

Keep it to one page. `Affects` names every repo that must implement or respect the decision, so a reader of either repo can find what applies to them.

### Accepted ADRs are immutable

Once an ADR is `Accepted` and merged, never edit it. Changing course means a new ADR that names the one it supersedes; the old one's only permitted edit is its `Status:` line, set to `Superseded by ADR NNNN`. Code in the implementing repos cites ADR numbers, so an ADR whose meaning changes in place silently makes those citations wrong.

The record pull request that brings an ADR in sets it to `Accepted`; merging it is the acceptance. An ADR not yet merged is a draft and can be edited freely.

## Glossary

`GLOSSARY.md` follows `domain-modeling`'s `GLOSSARY-FORMAT.md`: a bolded term, a one- or two-sentence definition of what it *is*, and an `_Avoid_:` line naming the rejected synonyms. Domain terms only: no implementation detail, no rules, no history.

## Use the glossary's vocabulary

When your output names a domain concept (a requirement, an issue title, a ticket), use the term as defined in `GLOSSARY.md`. Don't drift to synonyms the glossary avoids.

If the concept you need isn't in the glossary, either you are inventing language the project doesn't use (reconsider) or there is a real gap (resolve it with `/grill-with-docs`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding it:

> _Contradicts ADR-0007 (orders are cancelled whole), but worth reopening because…_
