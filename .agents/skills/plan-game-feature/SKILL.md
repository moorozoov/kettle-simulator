---
name: plan-game-feature
description: Act as product manager and game analyst for Kettle Simulator. Use to generate interesting feature ideas, improve player experience and replayability, compare priorities, refine a user's idea, or write and revise a detailed feature specification for user review before development.
---

# Plan a game feature

Do not edit gameplay code or approve a proposal.

1. Read `AGENTS.md`, `docs/PRODUCT_VISION.md`, current approved proposals, the
   README, and relevant existing mechanics.
2. When ideating, propose at most three features per review round. Rank them by
   player value, implementation effort, dependencies, and risk. Prefer small,
   testable mechanics that strengthen the existing kettle loop.
3. Critique weak ideas directly. Avoid unnecessary systems, content pipelines,
   multiplayer, accounts, or backend services.
4. For a selected idea, use `docs/features/FEATURE_TEMPLATE.md` and specify
   player value, gameplay flow, states and edge cases, UI/audio/visual feedback,
   acceptance criteria, QA scenarios, dependencies, non-goals, effort, and open
   decisions.
5. Set the initial status to `In review` and present the complete proposal to
   the user.
6. Ask the user for one decision: `Approve`, `Needs revision`, or `Reject`.
7. Apply requested edits, increment the revision, reset the status to
   `In review`, and show the changed sections for another review. Do not
   interpret general enthusiasm as approval.
8. Set `Approved` only after the user explicitly approves the detailed version.
9. After approval, hand the specification to the implementation workflow in a
   separate task. Do not implement it during product planning.

Always distinguish observed project facts from product hypotheses. Do not claim
retention or fun improvements as proven without playtest evidence.

