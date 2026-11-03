# Kettle Simulator agent instructions

## Project

Kettle Simulator is a small first-person 3D game made with Godot 4.7 and
GDScript. Keep the implementation simple, inspectable, and suitable for a
small Steam release.

## Non-negotiable rules

- Never commit or push directly to `main`.
- Never merge a pull request without the user's explicit approval.
- Preserve unrelated user changes and existing scene node paths.
- Reuse `assets/materials/water/water_universal.tres` for every water surface.
- Do not create duplicate materials when an existing material fits.
- Do not assign shared mutable materials to the kettle body or burner; their
  scripts change material properties at runtime.
- Treat `.tscn` and `.tres` files as structured resources. Make focused edits
  and verify node paths after changing them.
- Use typed GDScript. Warnings may be treated as errors.
- Keep gameplay tuning values exported when the designer may need to adjust
  them in the Godot Inspector.

## Agent team workflow

Use the **product analyst** before development when the user asks for feature
ideas, game improvements, product analysis, feature refinement, or a detailed
specification. The product analyst may propose and refine work, but may not
approve a feature or send it to development. Only the user can set a proposal
to `Approved`.

When the user asks to implement or fix a non-trivial gameplay change and asks
for the agent team, orchestrate the following roles:

1. **Product analyst** — confirm that the feature description is approved and
   implementation-ready. Skip this step for a narrowly defined bug fix.
2. **Godot developer** — inspect the relevant scenes and scripts, implement
   the smallest complete change, and run available checks.
3. **QA engineer** — after implementation, inspect the diff read-only, execute
   automated checks, identify regressions, and produce a short manual playtest
   checklist with observable expected results.
4. **PR reviewer** — after implementation, inspect the final diff read-only for
   correctness, scene-path breakage, duplicated resources, unsafe shared
   materials, missing validation, and scope creep.

Use subagents only when roles are independent or isolated context improves the
result. Do not spawn agents for trivial one-line edits. Only one agent may edit
the working tree at a time; QA and review agents must be read-only. The lead
agent resolves findings, reruns checks, creates the commit and PR, and reports
remaining manual checks to the user.

Use the repository workflows under `.agents/skills/` when their descriptions
match the task.

## Product approval workflow

- Store detailed proposals under `docs/features/proposals/` using
  `docs/features/FEATURE_TEMPLATE.md`.
- Use exactly one status: `Proposed`, `In review`, `Needs revision`, `Approved`,
  `Rejected`, `In development`, or `Done`.
- Present proposals to the user before any implementation begins.
- Treat silence, partial agreement, or approval of an idea as insufficient
  approval of the detailed specification.
- Only the user's explicit approval may change a proposal to `Approved`.
- Approval applies to one numbered revision. Any material edit to the summary,
  detailed behavior, acceptance criteria, non-goals, or open decisions must
  increment the revision and reset the status to `In review`.
- Let the user review and request edits to the description before development.
- Never implement `Proposed`, `In review`, `Needs revision`, or `Rejected`
  features.
- Keep rejected proposals for decision history unless the user asks to delete
  them.

## Git workflow

- Branches: `feature/<name>`, `fix/<name>`, or `chore/<name>`.
- Commits: Conventional Commits such as `feat: add kettle whistle`.
- Keep each PR focused on one mechanic or infrastructure change.
- PR descriptions must include the outcome, changed files, automated checks,
  manual playtest steps, and known limitations.

## Verification

Run `bash scripts/check_project.sh` after code, scene, resource, or project
configuration changes. If Godot is unavailable, report that the engine check
was not run; never describe an unavailable check as passed.

Visual gameplay changes also require a manual check in the editor. State exact
setup, action, expected observation, and relevant thresholds. A PR is ready for
the user's approval only after automated findings are resolved and the manual
checklist is provided.

