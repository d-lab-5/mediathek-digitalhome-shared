# ADR-0013 — A source says what it is for: keep in sync, clean up once, or just look

Status: **Accepted** · Date: 2026-11-06 · Concerns the edge (mediathek-digitalhome-edge) · Refines ADR-0012

## Context

ADR-0012 gave the edge one right to change a source: moving extra copies into
a bin on the same drive. Onboarding ended with step 4, "Make it a store",
which also published everything new on the drive.

Using it on a real 1 TB drive showed three problems:

- **What a folder is for came last.** A person who only wanted to empty an
  old folder into the Mediathek met "store" at the end, and could not tell
  whether that was the step they needed.
- **Copy versus move had no name.** A store keeps its files, and the
  Mediathek gets a copy. Emptying a folder means the Mediathek keeps the
  file, and the folder does not. Both used the same steps.
- **Publishing happened inside onboarding.** It bypassed the Preview, where
  a person looks and leaves pictures out. It also published photos and films
  together, ignoring the photos/films mode the rest of the page follows.

## Decision

**Every source has a role, chosen when it is added** (`sources.role`):

| Role | Icon | Meaning | Allowed for |
|---|---|---|---|
| `store` | 🔁 | **Keep in sync** (copy): the folder stays the home of its pictures, and the Mediathek gets a copy. | local folders and drives |
| `once` | 🧹 | **Clean up once** (move): the folder is emptied into the Mediathek through the bin. | local folders and drives |
| `look` | 👁 | **Just look**: only listed and compared, never changed. | every source; the only role for S3, ZIP and Google pick folders |

A source made before roles existed is `look`, or `store` if it was a store.

**The role decides the steps.**

- **look:** list, fingerprint, then **Into the Mediathek**.
- **store:** list, fingerprint, clean copies, **Into the Mediathek**, then
  **Keep in sync**. This writes the marker and sets stage `store`. A store
  never bins a file just because the Mediathek has it.
- **once:** list, fingerprint, clean copies, **Into the Mediathek**, then
  **Don't keep what is published**, then **Check and empty the bin**.
  - The "Don't keep" step reuses `plan_clean`'s `in_mediathek` group. That
    group now also holds what was just published from the folder itself.
  - What the person left out in Preview is not published, so it stays.

**Publishing always goes through Preview and Publish, in the page's mode.**
- Publish gains a **From** choice (`/api/publish` `source`). Preview's source
  filter sets it as well.
- "Into the Mediathek" only shows the counts for the mode and opens those
  two tabs.
- The store step no longer publishes from the page.

**A store's ongoing sync publishes only the kinds published from it by
hand.** Publishing with a source records the scope (photos or videos) in
`sources.published_scopes`. `sync_store` then publishes new files of those
scopes only. Switching the page to films once therefore never starts
uploading every film of every store.

**The bin is checked before it is emptied** (`check_bin`, job
`onboard-checkbin`).
- For every file in the bin, the check confirms that:
  - it still has the SHA-256 it was moved with;
  - its keeper is still there: the kept file on the drive or in another
    store (with the same bytes for an exact copy), the kept picture for a
    look-alike, or a registration in the Mediathek.
- Each run's result is kept (`bin_checks`).
- Problems can be put back on their own (`undo(…, keys)`).
- Emptying stays possible either way, but its confirmation says whether the
  bin was checked and what the check found.
- Adding the bin as a source was rejected: every file in it would show up
  as a duplicate of its keeper.

**The Sources screen leads with this.**
- A guided **Add photos and films** asks three things: where (a plugged-in
  drive, a folder, a bucket or a ZIP), what should happen (the three roles),
  and the name and vault.
- Each source is a card with its role, a one-line state for the mode, and
  one next step.
- The onboarding steps open from the card. The separate "Onboard a drive"
  menu item is gone, and "Stores" filters Sources to 🔁.

## Consequences

- One vocabulary for the person: keep in sync, clean up once, just look. The
  copy/move difference is visible before anything happens.
- In the "once" case the Mediathek becomes the only copy of what is let go,
  once the bin is emptied. The bin check and the separate empty step are
  what make that safe.
- A role can be changed while no job runs on the source. A store keeps its
  role until it is forgotten.
- Office documents (the Archive, `docs/ROADMAP.md`) will use the same roles
  when they are fingerprinted.
