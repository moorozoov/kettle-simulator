---
name: test-godot-change
description: Test or diagnose a Kettle Simulator change, branch, bug fix, or pull request. Use for QA, regression analysis, Godot validation, and producing an exact manual playtest checklist for visual gameplay behavior.
---

# Test a Godot change

Work read-only unless the user explicitly asks for test implementation.

1. Read `AGENTS.md`, the task acceptance criteria, and the full diff against the
   target branch.
2. Run `bash scripts/check_project.sh` and record the actual result.
3. Inspect affected node paths, signals, collision nodes, exported thresholds,
   visibility transitions, material references, and state reset behavior.
4. Test boundary states: immediately before, exactly at, and immediately after
   each threshold.
5. Check interaction combinations such as held/placed kettle, faucet on/off,
   empty/full kettle, heating/cooling, and repeated interactions when relevant.
6. Produce a compact checklist in this form:
   - Setup
   - Action
   - Expected observable result
7. Report findings by severity with file and line. Do not claim visual behavior
   passed unless it was actually observed in a running Godot instance.

