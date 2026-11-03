---
name: source-game-assets
description: Act as visual and technical asset designer for Kettle Simulator. Use to research, compare, download, prepare, name, license, add, or replace open-license materials and textures for approved features or explicit visual exploration in the Godot project.
---

# Source game assets

1. Read `AGENTS.md`, the approved feature revision or explicit exploration
   request, `LICENSES.md`, current materials, and affected scenes.
2. Reuse an existing material when it satisfies the visual need.
3. If sourcing is required, present up to three candidates with preview, asset
   name, author, source page, exact license, resolution, maps, visual fit, and
   expected repository size. Prefer CC0; use CC BY 4.0 only with attribution.
4. Reject assets with unclear provenance, unclear authorship, non-commercial or
   editorial-only terms, or licensing that cannot be preserved for Steam.
5. Obtain user approval before replacing an existing visual direction. A
   pre-approved generic need may proceed with the top compliant candidate.
6. Download only required maps. Default to 1K albedo, normal GL, roughness, and
   AO where available; avoid unused displacement or duplicate packed maps.
7. Store files under `assets/materials/<type>/<asset-name>/`, create or update a
   Godot material resource, and do not manually edit `.import` files.
8. Add work title, asset name, author, source URL, exact license, license URL,
   supplied copyright notice, material modifications or conversions, and every
   local path to `LICENSES.md` in the same change. Use `None supplied` when the
   original source provides no copyright notice.
9. Run `bash scripts/check_project.sh`, inspect repository size and diff, and
   verify that no shared runtime-mutated material was assigned unsafely.
10. Provide a screenshot when possible; otherwise provide exact scene, camera,
    lighting, and comparison steps for user visual approval.

Do not merge or declare visual approval on behalf of the user.

