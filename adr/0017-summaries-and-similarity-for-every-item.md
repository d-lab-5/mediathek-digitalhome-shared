# ADR-0017 — Summaries and similarity for every item

Status: **Accepted** · Date: 2026-11-07 · Concerns the edge and the cloud · Extends ADR-0016

## Context

ADR-0016 gave office documents and other files a summary that the edge's
chat drafts and a person checks. Photos and films had none, yet a film is
the hardest item to find again: its name says nothing, and nobody watches
an hour of home video to look for one scene.

Grouping is the other half. A family's photos and films arrive in folders
that rarely match what happened: one holiday is spread over three cameras,
and a school folder holds ten years. The chat can name a group and tag it,
but first it has to know which items belong together.

## Decision

**A summary on every item.** The same statements as ADR-0016:
- `schema:abstract` in en/de/fr;
- `mt:summaryState` (draft or checked);
- `schema:dateCreated`;
- `schema:mentions`.

They now hold for `mt:Photo` and `mt:Video` as well, through one
`SummaryShape` on all three item classes.

**Only a document has a type.** `mt:documentType` stays on `mt:Document`, and
the shapes refuse it on a photo or film. Saving a summary keeps the item's
own class (`setDocument`, with `itemClassOf(kind)`), so a photo is never
turned into a document.

**What the agent sees:**
- a photo: its 480 px preview (`look_at`);
- a film: about six frames spread over it, taken on the PC with ffmpeg
  (`look_at_film`);
- a document: its text (`read_document`).

Each is sent only when the person asks the chat to summarise, as before.
Draft, then checked, is unchanged: only a person marks a summary checked, in
the Library viewer (a Summary panel under photos and films) or on the edge.
The Library's summary filter applies to every side.

**Finding similar items is worked out on the PC.** The edge ranks candidates
for a selection by a weighted mix of three signals, each with its reason:
- **Looks:** a CLIP ViT-B/32 image vector per photo, and per film the mean
  of six frames. It is computed on the PC by ONNX Runtime with an MIT model
  of about 350 MB, fetched once by `scripts/fetch-models.sh looks`.
  - The score is the cosine to the selection's centre.
- **Text:** TF-IDF over a document's extracted text and any item's summary.
  It matches words, not meanings, so it needs no model.
- **What is known:**
  - the same event, person, pet or place in the A-Box;
  - the same album or folder;
  - a date within a few days.

The preview shows the result as **Similar to N selected**:
- mixed kinds, best first, with a threshold;
- the matches are selected, so Chat, tagging and Move act on the group.

The chat's `find_similar` reads the same ranking, and `show_in_preview` opens
it on the page. Naming the group and tagging it are proposals, as always.

## Diagrams

- [Finding similar items](../diagrams/adr-0017-find-similar.html): the three signals worked out on the PC, mixed into one score with its reasons, shown in the preview and read by the chat; only confirmed tags reach the cloud.

The summary flow and states are ADR-0016's diagrams; they now hold for photos and films too.

## Consequences

- **Looks never leave the PC.** The vectors live in the edge's catalog like
  face embeddings. The cloud learns nothing from similarity except the tags
  a person confirms.
- **Pictures leave when the person asks.** A summary of a photo or film sends
  its preview or frames to Claude under the person's own account, as
  `look_at` already did. The visibility of the vault applies to the summary
  as it does to the picture.
- **A model download and a pass over the photos.** Looks need about 350 MB
  once, and CPU time per photo. Until a photo has its vector, similarity
  falls back to text and what is known, and says so.
- **Text similarity is language-bound.** An invoice in Dutch and one in
  French from the same sender are found through the sender's name and
  numbers, not through meaning.
- **The cloud must be deployed first.** An older cloud refuses a summary on a
  photo or film with a 400.
