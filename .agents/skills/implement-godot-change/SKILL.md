---
name: implement-godot-change
description: Implement or fix gameplay, GDScript, Godot scene, resource, interaction, water, kettle, stove, sink, UI, or environment behavior in Kettle Simulator. Use for requested code or scene changes that should result in a focused branch and pull request.
---

# Implement a Godot change

1. Read `AGENTS.md`, the relevant scene, its scripts, and referenced resources.
2. Restate the observable outcome and acceptance criteria before editing.
3. Check the current branch and working tree. Preserve unrelated changes. If
   the current branch is `main`, create and switch to the appropriate
   `feature/*`, `fix/*`, or `chore/*` branch before the first write.
4. Trace node paths, signals, groups, exported values, and material ownership.
5. Implement the smallest complete change with typed GDScript.
6. Reuse existing resources, especially `water_universal.tres`.
7. Run `bash scripts/check_project.sh`.
8. Inspect `git diff --check` and the complete scoped diff.
9. Hand the result to the QA and review workflows before creating the PR.
10. Report files changed, checks run, and exact manual playtest steps.

Do not merge the PR. Wait for explicit user approval.

