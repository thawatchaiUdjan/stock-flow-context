# Issue tracker: across three repos

Specs live as issues in **this** repo. Tickets live as issues in the **implementing** repo (`stock-flow-api` or `stock-flow-web`). The code host is GitHub; the commands are at the end.

The three remotes (`<owner>/<repo>`) are in the table in `AGENTS.md`. The CLI infers *this* repo from `git remote -v`; for a sibling, pass `-R <owner>/<repo>` explicitly. Inferring from the remote is wrong whenever you write to a sibling.

A reference of the form `<owner>/<repo>#<number>` lives in another repo; a bare `#<number>` lives in this one.

## Labels

Only `ready-for-agent` is in use; `/to-spec` and `/to-tickets` apply it. The `triage` skill is not installed, so no other triage label exists. Create the label once in each of the three repos before first use.

## When a skill says "publish to the issue tracker"

- **`/to-spec`** → create the issue in **this** repo.
- **`/to-tickets`** → create each ticket in the **implementing** repo, with `-R`, following `docs/agents/directing-work.md`.

## When a skill says "fetch the relevant ticket"

Read the issue (command below), adding `-R <owner>/<repo>` when the reference names another repo.

## Specs, written where there is no code

`/to-spec` assumes it runs inside the codebase: it explores the code, sketches test seams, and records implementation decisions. Here there is no code, so:

- Read the current state of the implementing repos with `--add-dir` before writing; describe it, never guess it.
- Write **Implementation Decisions** at contract level: which repo owns what, the API operations and their inputs, outputs and errors, the screens and their states. No file paths, no internal modules.
- In **Testing Decisions**, name the seam *per repo* as a proposal (for the api, the operation; for the web, the screen). The implementing repo confirms or adjusts its own seam before `/implement`, because only it can see its code.

## Tickets, when a slice crosses repos

`/to-tickets` cuts vertical slices through every layer. Here a slice that touches both the API and the screen spans two repos, so:

- One ticket **per repo per slice**, both titled with the same slice name and both linking the spec issue.
- The api ticket **blocks** the web ticket whenever the web needs the contract change the api ticket makes.
- Record a cross-repo block as a `Blocked by: <owner>/stock-flow-api#<n>` line at the top of the web ticket. It works on every host and plan; a native blocking link may be added as well where the host supports one across repos. A ticket is unblocked when every listed blocker is closed.
- A slice that touches only one repo is one ticket, as upstream.
- Skip `to-tickets`' sub-issue step: sub-issues don't span repos. Each ticket's *Spec* link replaces it.

## Pull requests as a triage surface

**PRs as a request surface: no.**

## Commands

### GitHub (`gh`)

- **Create**: `gh issue create --title "..." --body "..."` (heredoc for multi-line bodies), plus `-R <owner>/<repo>` for a sibling.
- **Read**: `gh issue view <n> --json number,title,body,labels,comments`.
- **List**: `gh issue list --state open --label ready-for-agent --json number,title,labels`.
- **Comment**: `gh issue comment <n> --body "..."`.
- **Labels**: `gh issue edit <n> --add-label "..."` / `--remove-label "..."`. Create once: `gh label create ready-for-agent`.
- **Close**: comment first, then `gh issue close <n>`.
- **Pull requests**: `gh pr create`, `gh pr view`, `gh pr comment`. GitHub shares one number space across issues and PRs.
- **Pipeline state of a pull request**: `gh pr checks <n> -R <owner>/<repo>`; it exits non-zero while any check is failing or still running.
- Before the first `gh issue create` of a session, check the target with `gh repo view --json nameWithOwner`: in a fork, `gh` can default to the upstream.
