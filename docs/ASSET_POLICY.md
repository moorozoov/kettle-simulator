# Visual asset policy

## Allowed sources and licenses

- Prefer original project assets and CC0 assets.
- CC BY 4.0 assets are allowed when full attribution is stored in `LICENSES.md`.
- Do not use assets with unclear provenance, non-commercial restrictions,
  editorial-only restrictions, or missing license evidence.
- Verify the license on the asset's original source page before download; a
  search result or third-party repost is not evidence.

## Technical defaults

- Use 1K textures by default for this small interior scene.
- Prefer PBR maps: albedo, normal GL, roughness, and AO.
- Download only maps used by the Godot material.
- Keep each sourced material in its own directory under `assets/materials/`.
- Reuse `assets/materials/water/water_universal.tres` for all water surfaces.
- Avoid modifying shared materials whose parameters change at runtime.

## Required attribution record

Every sourced asset entry in `LICENSES.md` must include:

- work title and asset name;
- author or publisher;
- original source URL;
- exact license and license URL;
- copyright notice supplied by the source, or `None supplied`;
- modifications such as resizing, channel packing, conversion, or cropping;
- local file and material paths.

## Review gate

Adding a compliant asset does not approve its visual direction. Provide a
preview or reproducible editor checklist and wait for user approval before
merging a visual change.

