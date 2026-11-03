# Feature proposal workflow

The product analyst creates proposals from `FEATURE_TEMPLATE.md`. Development
may start only after the user explicitly approves the detailed description.

## Statuses

- `Proposed` — an early idea, not yet ready for detailed review.
- `In review` — a detailed description is waiting for user review.
- `Needs revision` — the user requested changes.
- `Approved` — the user explicitly approved this exact description.
- `Rejected` — the user declined the feature.
- `In development` — implementation started from an approved description.
- `Done` — implementation was accepted and merged.

Store proposals in `docs/features/proposals/` using a short kebab-case filename,
for example `kettle-whistle.md`. Record every user decision in the proposal's
decision log.

Approval always applies to a specific numbered revision. Any material change to
the summary, detailed behavior, acceptance criteria, non-goals, or open
decisions increments the revision and returns the proposal to `In review`.

