---
name: review-kettle-pr
description: Review a Kettle Simulator pull request or branch for bugs, regressions, unsafe Godot scene edits, broken node paths, duplicated materials, missing tests, and mismatch with acceptance criteria. Use after implementation and before user approval or merge.
---

# Review a Kettle Simulator PR

Work read-only. Review the diff, not only the final files.

Prioritize:

1. Runtime errors, invalid node paths, disconnected signals, and incorrect state
   transitions.
2. Regressions in pickup, placement, filling, overflow, heating, burning, stove,
   sink, puddle, and flood mechanics.
3. Shared material mutation or unnecessary duplicate materials.
4. Untyped Variant inference and GDScript warnings that can fail the project.
5. Scene/resource churn unrelated to the task.
6. Missing automated validation or manual playtest coverage.

Return findings first, ordered by severity, with file and line references. If no
findings exist, say so and list residual risks or manual checks. Never approve a
merge on behalf of the user.

