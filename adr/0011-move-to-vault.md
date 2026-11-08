# ADR-0011 — Move to vault, and one vault per item

Status: **Accepted** · Date: 2026-10-04 · Amends ADR-0007 (who may delete) and ADR-0010 ("Move to vault comes later")

## Context

A household's admins made a private vault for one person's own pictures,
which so far sat in the family vault. ADR-0010 put each item in exactly one
vault and left moving for later, because a move has to take the files along:
derived files live under `derived/<vault>/<sha256>/…`, signed per vault, and
only the break-glass role could delete in the store (ADR-0007). It also has
to take what the vault's A-Box says about the item, or family readers keep
learning who is on a photo they can no longer see.

At the same time the same photo turned up in sources meant for two vaults,
and an edge could publish it into both: two Asset rows, one sha256.

## Decision

**Move.** `vaultMove` moves an item to another vault of its household. The
Library's `moveToVault` (the household's admins, two-step sign-in) and an
edge's `POST /edge/v1/media/move` (its device token) both call it. Per item,
in an order that never loses anything, each step idempotent, so running it
again finishes a move that stopped half-way:

1. copy `derived/<from>/<id>/*` to `derived/<to>/<id>/*` (server-side, no download);
2. write the row in the target vault (`movedFrom`, `movedAt`; `copyOf` dropped, copies are per vault);
3. album entries: into the album of the same path in the target vault (made when missing), out of the source's;
4. knowledge: what the source A-Box says about the item (its own statements,
   its marked faces) moves to the target A-Box; the people, events and places
   it points to stay in the source and are **introduced** into the target when
   it does not know them (same ids; their labels, an event's date and place);
   the target is saved first, then the source, each with its version;
5. delete the source row;
6. delete the source's derived files.

The original (`originals/<household>/…`) is the household's and is never touched.

**Who may delete derived files.** The store's policy (ADR-0007) now lets
principals tagged `mediathek-derived-mover=true` delete the **current**
version of objects under `derived/`, and nothing else: originals and the
bucket stay break-glass only, and so does deleting a **version**. Only the
`vaultMove` role carries the tag. The bucket is versioned, so a moved file's
old copy is recoverable for 30 days (the lifecycle rule) and gone after.

**One vault wins.** An item lives in one vault. When the same photo is meant
for two (its sources point to different vaults) the winner is, in order: a
choice made for that item; the **most private** vault among its sources;
the family vault. The edge reports items in two vaults; settling one is a
move in **merge mode** (the target already has the row): its knowledge and
origins are merged in, and the other row and its files are removed.

**Environments sharing the store.** Stage and prod share the store
(ADR-0007), and a household made with a household code has the same vault
ids on both. A move in one environment must not delete files the other
still shows: that happened once, when a move on stage left 14 photos on prod
without their thumbnails (restored by copying them back). So every deployed
environment publishes its Asset table's name under `/mediathek/catalogs/`,
and step 6 deletes the old files only when no catalog still has the item in
the old vault. The move in the LAST environment deletes them. An edge moves
in every linked environment, so for it the files go at once; a Library move
in one environment leaves them until the others move too.

## Consequences

- Moving out of a private vault into the family vault shows the photo to the
  whole family: it is an admin's or a linked edge's act, recorded in
  `movedFrom` and the A-Box's `updatedBy`.
- A family reader whose browser already holds a signed policy keeps reaching
  the old files until they are deleted in step 6 (seconds) — no longer than
  that, unlike a Bin purge.
- A move is idempotent but not atomic. A failure between steps 4 and 5 leaves
  the item in both vaults for a moment; running the move again finishes it.
- Albums are per vault, so a moved item's album appears in the target vault
  with the same path; the source album may end up empty.
- Derived files over 5 GB cannot be copied in one call; such a move is
  refused until multipart copy exists.
