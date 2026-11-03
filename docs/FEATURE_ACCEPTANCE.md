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

- The player recognizes boiling without reading the HUD.
- Whistle and steam communicate one consistent state.
- The loop is understandable, audible at useful range and not irritating across repeated cycles.

### PM acceptance

- Approved Revision 1 is implemented in one focused PR.
- Audio origin/license is recorded.
- CI, independent QA, PR review and user audio playtest pass.
- Water, heating and interaction regressions are absent.

### QA focus

99 °C boundary, active heat predicate, immediate stop on heat off/pickup/refill/empty/burned, repeated toggles, no stacked playback, distance attenuation, loop seam, regression of water systems.

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
- M1 automated CI and audio-file technical checks: passed.
- M1 audible behavior: pending user Godot playtest.
- M2–M6: test scenarios prepared but not runnable before implementation.
