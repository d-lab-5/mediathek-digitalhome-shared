# ADR-0014 — Office documents and other files, kept as their original

Status: **Accepted** · Date: 2026-11-06 · Concerns the edge and the cloud · First step of the Archive (docs/ROADMAP.md)

## Context

The edge lists every file in a source and gives it a kind (`engine.py`), but
until now it published only photos, RAW files and films. Office documents
were counted and then left behind, and so was everything else: music,
editing projects, archives, files of unknown type. A drive onboarded into a
store (ADR-0012) was therefore only partly in the Mediathek.

The roadmap's Archive (previews, full text, cases, keep-until dates) is a
larger piece of work. These files need a place in the Mediathek before that
exists.

## Decision

**Two more sides, besides photos and films.** Both the edge and the Library
have them:

| Side | Kinds | Extensions (edge, `engine.py`) |
|---|---|---|
| Office | `office` | pdf, doc(x), dot(x), rtf, odt, xls(x/m), ods, csv, ppt(x), pps(x), odp, txt, md, pages, numbers, key, vsd(x), one |
| Other | `audio`, `project`, `archive`, `other` | everything else, including svg and html |

Two kinds are never published: `sidecar` (Takeout's JSON, already read into
the photo it belongs to) and `system` (desktop.ini, Thumbs.db, .DS_Store).

**The same process as photos.** A publish of the new kinds goes through the
same steps:

- the dry run that says what would be published;
- one upload per fingerprint (SHA-256);
- the source's vault, with one vault per item (ADR-0011);
- items left out by hand;
- Move to vault.

**The original only.** These files have no renditions, so there is nothing
under `derived/`. The Library shows a tile with the file type and the name.
The viewer shows a card with a **Download** button, which uses `originalUrl`.
`originalUrl` presigns with `Content-Disposition: attachment`, so an html or
svg file is downloaded and never rendered in the Mediathek's origin.

**Vault moves need no change.** `vaultMove` lists `derived/<from>/<id>/`. For
these files the list is empty, so steps 1 and 6 do nothing, and the row,
albums and knowledge move as for a photo.

**Over 5 GB is refused in the dry run.** That is the single-PUT limit. Such a
file is reported as too large instead of failing during the upload.

## Consequences

- An office document goes to its source's vault. **Sensitive papers in a
  family source become visible to the whole family.** Point such a source at
  a private vault before publishing it, or move the papers afterwards. The
  roadmap's question about a stricter vault for sensitive papers stays open.
- Nothing is read from inside the files: there are no previews, no text and
  no search. Those belong to the Archive.
- `edgeMedia` accepts the kinds `office`, `project`, `archive` and `other`.
  An edge older than this one never sends them. A cloud older than this one
  refuses them with a 400, so **deploy the cloud first**.
