# Kettle Simulator — project status

**Last reviewed:** 2026-11-03  
**Maintainer:** Project manager agent

Only user-confirmed dates are commitments. Feature approval status is tracked separately from delivery status.

## Active work

| Work item | Product status | Delivery status | Owner role | Confirmed target | Dependencies | PR | Blocker | Next action |
|---|---|---|---|---|---|---|---|---|
| Physical whistle and complete boiling loop | Approved, Revision 2 | In progress | Product / Designer / Developer / QA | — | Softer audio; discrete placement targets | PR #6 revision required | Owner rejected Revision 1: no physical whistle, placement dead end, loud sound, excessive owner QA | Add physical whistle, replace audio, implement burner/sink/countertop placement and QA-owned x10 runs |
| First playable goal | Roadmap approved; proposal pending | Planned | Product / Project | — | M1 complete | — | Detailed Revision 1 required | Prepare proposal while M1 is in review |

## Completed milestones

- M0 Stable Simulation completed.
- PR #2 merged as commit `f478da53` after CI and user manual acceptance.
- Closed room geometry and stable flood progression added.
- Agent workflow, project manager and visual designer roles configured.
- Product roadmap Revision 1 approved by the user.

## Current forecast

- **M1 Readable Feedback:** at risk while Revision 2 corrective work is in progress; no confirmed target date.
- **M2 First Playable Goal:** planned after M1; proposal to be prepared.
- No calendar commitment exists.

## Next gates

1. Add a visible metal whistle on the spout.
2. Replace the loud reference with a softer sound at `-20 dB` and `5 m`.
3. Implement valid placement on burner, sink area and countertop.
4. QA runs automated/agent-owned x10 pickup, placement and toggle scenarios.
5. CI, independent QA and PR review.
6. Owner performs only three short acceptance actions.
7. Explicit owner merge approval.
