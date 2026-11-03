# Kettle Simulator — project status

**Last reviewed:** 2026-11-03  
**Maintainer:** Project manager agent

Only user-confirmed dates are commitments. Feature approval status is tracked separately from delivery status.

## Active work

| Work item | Product status | Delivery status | Owner role | Confirmed target | Dependencies | PR | Blocker | Next action |
|---|---|---|---|---|---|---|---|---|
| Smooth flood progression | Legacy scope | In review | Lead / QA / User | — | Explicit merge approval | [#2](https://github.com/moorozoov/kettle-simulator/pull/2) | No technical blocker: CI green and manual playtest passed | User explicitly authorizes or declines merge |
| Product roadmap and delivery plan | In review, Revision 1 | In review | Product / Project | — | User review | Documentation PR | No blocker | Review priorities, risks and open decisions |
| Kettle whistle | In review, Revision 1 | Planned | Product / Designer | — | Approved specification; licensed audio; M0 complete | — | User approval required | User reviews proposal; no development before `Approved` |

## Upcoming decisions

1. Explicitly approve or decline merge of PR #2.
2. Review roadmap order: whistle → first goal → cup.
3. Choose intended tone: household realism, absurd comedy, or a balance.
4. Decide whether failure ends a run or allows the catastrophe to continue.
5. Review open decisions in the whistle proposal.
6. Confirm dates only after an approved scope and dependency review.

## Completed milestones

- Repository and semantic versioning initialized.
- Closed room geometry added.
- Codex product, development, QA and PR-review workflow configured.
- Project manager and visual designer roles added through merged PR #4.
- PR #2 reconciled with `main`; automated checks and user manual playtest completed.

## Current forecast

- **M0 Stable Simulation:** ready for merge decision; no confirmed target date.
- **M1 Readable Feedback:** proposed, not approved.
- **M2 First Playable Goal:** planned after M1, specification not yet created.
- No schedule commitment exists.

## Status update rules

- **Planned:** approved or sequenced work not started.
- **In progress:** implementation is active.
- **Blocked:** a dependency or decision prevents progress.
- **In review:** automated, agent, user or product review is pending.
- **Done:** merged and verified.
