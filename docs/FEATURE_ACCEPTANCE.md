# Feature acceptance plan

**Updated:** 2026-11-03  
**Roadmap revision:** 1

This document defines acceptance responsibility for each milestone. Automated checks do not replace manual audio, visual or gameplay acceptance.

## M0 — Stable Simulation

### PO acceptance

- Filling, heating, overflow, puddles and flooding form one understandable simulation.
- Water reaches the room before the level rises.
- Colour, lighting and texture remain visually continuous.
- The player understands how their actions created each consequence.

### PM acceptance

- PR #2 scope, CI, QA and manual checklist are complete.
- No blocker/high finding remains.
- The user has accepted the behavior and explicitly authorized merge.
- Status and roadmap are updated after merge.

### QA focus

Thresholds 9.9/10/11.9/12 L, overflow under the faucet, faucet without kettle, source switching, colour/light/texture continuity, stop accumulation when water is off.

## M1 — Readable Feedback

### PO acceptance

- A visible metal whistle on the spout explains the source of the sound.
- The player recognizes boiling without reading the HUD; whistle and steam communicate one consistent state.
- The softer sound is audible near the stove without dominating the scene (default `-20 dB`, maximum distance `5 m`).
- The complete `boil → pick up → place` loop has no dead end.
- The player can understand placement on the burner, sink area and countertop without developer guidance.

### PM acceptance

- Approved Revision 2 is implemented in one focused PR; rejected Revision 1 is not merged as-is.
- Physical whistle, replacement audio and three placement targets are tracked as separate deliverables.
- Audio origin/license is recorded.
- QA owns automated or agent-run x10 transition tests and water/heating/interaction regression.
- CI, independent QA and PR review have no blocker/high/medium findings.
- Owner acceptance is limited to no more than three short sensory actions and is performed only after QA passes.
- Merge requires separate explicit owner approval.

### QA focus

Physical-whistle visibility and attachment; 99 °C/active-heat predicate; `-20 dB` and `5 m` defaults; immediate stop on heat off/pickup/refill/empty/burned; no stacked playback or loop seam; valid placement on burner/sink/countertop; invalid and occupied-target rejection; collision and interaction restoration; correct station assignment; x10 burner pickup/place, x10 countertop pickup/place, x10 burner toggles; five restarts; overflow, faucet, puddle and flooding regression. Repetitive runs are QA-owned, not owner-owned.

### Owner acceptance — maximum three actions

1. Boil water once and assess the visible whistle and sound level.
2. Pick the kettle up and place it on the countertop.
3. Return it to the burner and confirm that boiling feedback resumes correctly.

## M2 — First Playable Goal

### PO acceptance

- A new player understands the objective without developer explanation.
- Success requires actual boiling and a safe reaction.
- Failure has a clear cause and the player understands how to retry.

### PM acceptance

- A separate proposal is approved.
- Session lifecycle, UI, result and reset are complete.
- Five consecutive restarts leave no stale objects or duplicated signals.
- Three to five external playtests are recorded.
- No blocker/high finding remains.

### QA focus

Nominal success, false success prevention, every failure cause, result shown once, full state reset, five restart stress run, critical flood integration, understandable UI without debug HUD.

## M3 — Complete Household Loop

### PO acceptance

- The player can pour hot water into a cup without precise simulation controls.
- The household loop has a clear completion point.
- Pouring is understandable by the second attempt.

### PM acceptance

- A technical control spike passes before full implementation.
- Water volume and temperature conservation are verified.
- Cup overflow reuses the spill system and universal water material.
- CI, QA, review and manual control acceptance pass.

### QA focus

Correct pour, conservation of volume, empty kettle, interruption, cup overflow, missed aim, stream/number synchronization, temperature transfer and usability.

## M4 — Entertaining Failure

### PO acceptance

- The cause of fire and the available response are readable.
- Failure creates an entertaining decision rather than an immediate dead end.
- Escalation stays understandable and controllable.

### PM acceptance

- Version 1 is limited to one accident chain and one extinguishing method.
- VFX, sound, reset and performance gates pass.
- Asset licenses and regression coverage are complete.
- No unapproved room-wide fire simulation enters scope.

### QA focus

Smoke/fire thresholds, no premature ignition, extinguishing, re-ignition rules, reset cleanup, performance under maximum VFX, scope-limited spread and interaction with water.

## M5 — Demo Readiness

### PO acceptance

- The demo gives a complete short experience without developer assistance.
- Menu, settings and game feedback are understandable.
- External players can finish or intentionally fail the scenario.

### PM acceptance

- Windows build launches on a clean target machine.
- Menu, pause, restart, exit, audio and display settings pass.
- Licenses, versioning, changelog and release checklist are complete.
- External playtest findings are triaged.
- Blocker/high count is zero.

### QA focus

Clean install, navigation, settings persistence, resolutions/fullscreen, corrupted or missing save, licenses, performance, debug output, five external playtests and release smoke.

## M6 — Replayability

### PO acceptance

- Results explain how the player performed.
- At least three strategies produce meaningfully different outcomes.
- Players understand how to improve or intentionally create a worse result and want another attempt.

### PM acceptance

- Metrics and scoring are approved after core-loop playtests.
- Results are deterministic and save data is resilient.
- Unlocks are versioned and persist correctly.
- Replayability value is validated before more content is commissioned.

### QA focus

Deterministic score, transparent bonuses/penalties, best-result persistence, corrupted-save recovery, multiple strategies, unlock conditions, repeat unlock prevention and balance playtest.

## Execution status

- M0 automated and manual acceptance: passed.
- M1 Revision 1: rejected by the owner (no physical whistle, incomplete placement loop, loud sound and excessive owner QA burden).
- M1 Revision 2 corrective work: in progress; previous CI/audio checks are insufficient for acceptance.
- M1 QA evidence and three-action owner acceptance: pending implementation and independent QA.
- M2–M6: test scenarios prepared but not runnable before implementation.
