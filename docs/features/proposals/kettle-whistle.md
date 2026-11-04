# Feature proposal — Physical kettle whistle and complete boiling loop

**Status:** Approved
**Revision:** 2
**Priority:** P0
**Estimated size:** L
**Roadmap:** M1 — Readable Feedback

## Approval record

Revision 2 follows the user's explicit corrective requirements: add a visible
whistle, let the player place the kettle after pickup, replace the loud sound,
and move repetitive testing from the owner to QA.

## Problem and value

Revision 1 added audio but not a complete experience. The kettle has no visible
whistle, the player can pick it up after boiling but cannot place it on a useful
surface, and the reference sound is too loud. Revision 2 makes the sound source
visible and completes the scenario `boil → pick up → place`.

## User story

As a player, I can see the whistle on the spout, hear a moderate realistic
signal, pick the kettle up and place it on a valid surface without a dead end.

## Main scenario

1. The filled kettle stands on an active burner.
2. At 99 °C steam and one moderate whistle start together.
3. A physical metal whistle is visible on the end of the spout.
4. Picking the kettle up stops steam and audio immediately.
5. The player aims at a valid free placement zone and sees a short prompt.
6. The kettle is placed stably and becomes interactable again.
7. Returning it to an active burner starts one whistle when conditions are true.

## Scope

### Physical whistle

- one visible classic metal whistle cap on the spout;
- Godot primitives or a license-safe asset;
- reuse the existing stainless-steel material;
- keep it under the kettle root so it moves with the kettle;
- no opening animation in Revision 2.

### Placement

- approved targets: burner, sink area and countertop;
- placement only in a valid free zone;
- concise prompt that does not cover the crosshair;
- restore transform, collision and interaction after placement;
- assign a station only for a functional burner or sink target;
- countertop placement must neither heat nor fill the kettle.

### Audio

- replace the harsh procedural reference with a softer realistic sound;
- one `AudioStreamPlayer3D` and one loop;
- default volume: `-20 dB`;
- default maximum distance: `5 m`;
- no seam, click, duplicate playback or volume growth;
- stop within one physics frame after heat off, pickup, refill below threshold,
  empty water or burned state;
- record source, license, modifications and local path for external assets.

### QA ownership

- QA runs repeated pickup/place, burner-toggle and restart cycles;
- automated or agent-run checks cover state transitions and regressions;
- the owner is not assigned repetitive stress tests.

## Out of scope

- animated whistle opening;
- free throwing or arbitrary placement on all geometry;
- realistic center-of-mass simulation;
- countertop heat damage;
- multiple whistle models or selectable sounds;
- cup pouring, recipes, scoring and missions.

## Functional acceptance criteria

1. The whistle is visible from the normal camera and stays attached during
   pickup and placement.
2. Steam and audio start only with water, at least 99 °C, active heat and a
   non-burned kettle.
3. Audio defaults to `-20 dB` and `5 m` maximum distance.
4. Audio stops within one physics frame after every stop condition.
5. Repeated transitions never create more than one playing source.
6. The kettle can be placed on burner, sink area and countertop targets.
7. Invalid or occupied targets reject placement.
8. Collision and interaction return after successful placement.
9. Burner placement heats, sink placement fills and countertop placement does
   neither.
10. Overflow, puddles, flooding, evaporation and burning remain unchanged.

## PO acceptance

- The visible whistle explains the source of the sound.
- The sound is audible near the stove but does not dominate the scene.
- The scenario `boil → pick up → place` has no dead end.
- Placement is understandable without developer guidance.
- Returning the kettle to the burner behaves predictably.

## PM acceptance

- Physical whistle, placement and audio are separate tracked deliverables.
- CI, independent QA and review have no blocker/high/medium findings.
- Audio origin and license are recorded when applicable.
- QA evidence includes x10 runs and regression coverage.
- Owner acceptance contains no more than three short sensory actions.
- Merge requires separate explicit approval from the owner.

## QA-owned test scenarios

QA must execute and record:

- 10 pickup/place cycles on the burner;
- 10 pickup/place cycles on the countertop;
- 10 rapid burner toggles;
- sink placement and return to the burner;
- invalid and occupied target rejection;
- collision and interaction after every placement;
- one audio source without volume growth or delayed playback;
- cold refill, evaporation to zero and burned state;
- five scene restarts without stale audio or duplicated signals;
- overflow, faucet, puddle and flooding regression.

Automation should cover the boiling predicate, idempotent audio state, station
assignment/clearing, placement validation, collision restoration and repeated
transitions.

## Owner acceptance — maximum three actions

1. Boil water once and assess the visible whistle and sound level.
2. Pick the kettle up and place it on the countertop.
3. Return it to the burner and confirm feedback resumes as expected.

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| Whistle model is unreadable | Review from the normal gameplay camera |
| Sound remains harsh | Softer source, `-20 dB`, `5 m`, designer listening gate |
| Placement leaves stale station | Central transition and automated assertions |
| Kettle becomes non-interactable | Restore collision/state in one method |
| Audio stacks | One player and idempotent play/stop |
| Scope expands | Restrict placement to three discrete target zones |

## Success signal

The owner completes the three-action acceptance without a dead end, while QA
evidence proves repeated transitions and regression coverage.
