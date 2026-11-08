# ADR-0012 — Onboarding a source, and the edge's one right to change it

Status: **Accepted**, refined by [ADR-0013](0013-a-source-says-what-it-is-for.md) (roles: store, once, look; publishing through Preview) · Date: 2026-11-03 · Concerns the edge (mediathek-digitalhome-edge)

## Context

Until now the edge only read its sources. Inventory, hashing and publishing
never changed a bucket, a folder or a ZIP. That was right for proving
duplicates before an upload. But a family's real material is a mess on
drives and memory cards: the same photo three times, a `Backup/` folder, a
messenger's re-saved copies. "Settle duplicates" proves which files are the
same, but leaves the drive as messy as it was, and the person has to clean it
up by hand from a list of paths.

## Decision

**A local folder or drive can be onboarded, and then it is a store.**
Onboarding has four steps, each explained on the page in plain words:

1. **scan**: list the files (nothing opened);
2. **fingerprint**: read every photo and film once for its SHA-256, and make
   the photos' previews;
3. **clean**: move extra copies into `<source>/_mediathek-bin/<run>/…`;
4. **store**: choose the vault, publish what is new, and keep it in step from
   then on.

**The bin is the only change.** The edge moves files into a bin folder on the
same drive. That is a rename, so it is instant and keeps the date. Every move
is logged in the catalog (`moves`), and Undo puts a run back. Files are
deleted only when a person empties the bin. The chat panel can propose scan,
fingerprint and sync, but never a move, an undo or emptying the bin.

**What counts as an extra copy:**

- **exact**: the same fingerprint twice on this drive. One copy stays here.
  The keeper is outside "copy"/"backup" folders, then has a name without a
  copy suffix, then is the oldest.
- **in_store**: the same fingerprint in *another store*. A source that is not
  a store does not count, because it may be a temporary folder that is
  cleaned up next.
- **in_mediathek**: published and registered in the current connection.
  This is **opt-in during onboarding only**: once a drive is a store, its own
  photos are in the Mediathek too, and a sync must never bin them because of
  that.
- **lookalike**: the same picture as other bytes (copies.py). It moves only
  when a person ticked it.

Before a file moves, it is read again and must still have the fingerprint
the plan saw, and its keeper must still be there with the same bytes.

**A store syncs itself while the page runs**, every ten minutes, and on
**Sync now**. A sync re-lists the store, fingerprints new files, bins new
*exact* and *in_store* copies, counts new look-alikes for review and
publishes the rest. A file removed from a store is not removed from the
Mediathek. A store carries a marker file (`.mediathek-store.json`) with its
id, so a drive mounted under another path is found again. An unplugged
store is skipped.

S3 and ZIP sources stay read-only and cannot be onboarded.

## Consequences

- The edge's promise changes from "never touches a source" to "never
  touches a source unless it was onboarded, and then only moves files into
  its bin". The README, the skill and the page say so.
- A store's drive holds one copy of each file that came from it. Content
  that was already in the Mediathek before onboarding can be binned there
  if the person asks, and then the Mediathek holds the only copy.
- The catalog gains `sources.stage`, `onboarded_at` and `store_id`, and the
  `moves` table. Older catalogs are migrated in place.
