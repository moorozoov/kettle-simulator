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
2. **Project manager** — turn the approved scope into trackable work, confirm
   dependencies and user-approved target dates, monitor progress and blockers,
   and keep `docs/PROJECT_STATUS.md` current.
3. **Visual designer** — when approved work needs visual assets, source or
   prepare license-safe materials and textures and submit them for visual review.
4. **Godot developer** — inspect the relevant scenes and scripts, implement
   the smallest complete change, and run available checks.
5. **QA engineer** — after implementation, inspect the diff read-only, execute
   automated checks, identify regressions, and produce a short manual playtest
   checklist with observable expected results.
6. **PR reviewer** — after implementation, inspect the final diff read-only for
   correctness, scene-path breakage, duplicated resources, unsafe shared
   materials, missing validation, and scope creep.

Use subagents only when roles are independent or isolated context improves the
result. Do not spawn agents for trivial one-line edits. Only one agent may edit
the working tree at a time; QA and review agents must be read-only. The lead
agent resolves findings, reruns checks, creates the commit and PR, and reports
remaining manual checks to the user.

Use the repository workflows under `.agents/skills/` when their descriptions
match the task.

## Project management rules

- The project manager may update planning and status documents, but may not
  edit gameplay code, approve product scope, approve visual design, or merge.
- Do not invent commitments. Proposed target dates become commitments only
  after the user explicitly confirms them.
- Track approved scope, owner role, status, target date, blockers, dependencies,
  PR, and next action in `docs/PROJECT_STATUS.md`.
- Use `Planned`, `In progress`, `Blocked`, `In review`, or `Done` for delivery
  status. A feature proposal's product status remains separate.
- Escalate a blocker or likely missed commitment to the user with evidence and
  a recommended decision. Do not silently reduce scope or move a date.
- Verify agent claims against repository state, checks, and PRs before marking
  work complete.

## Visual asset rules

- Source assets only for approved work or an explicit visual exploration.
- Prefer CC0. CC BY 4.0 is allowed only when attribution is recorded. Reject
  unclear, non-commercial, editorial-only, or attribution-unknown assets.
- Record asset name, author, source URL, license, and local paths in
  `LICENSES.md` in the same change that adds the files. For CC BY, also record
  the work title, any supplied copyright notice, and material modifications.
- Prefer existing project materials before adding files. Never duplicate
  `water_universal.tres` or another suitable resource.
- Default to 1K PBR textures unless the approved specification requires more.
- Keep source maps together under `assets/materials/<type>/<asset-name>/` and
  use lowercase kebab-case or snake_case consistently within that folder.
- Do not manually edit Godot `.import` metadata.
- Do not replace an existing visual direction without explicit user approval.
- Provide source links, license evidence, affected scenes, and a screenshot or
  exact editor review checklist in the PR.

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

