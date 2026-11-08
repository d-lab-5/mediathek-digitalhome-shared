# Roadmap

What the Mediathek is meant to become, beyond what is built. An item here is
a direction, not a promise. When work starts, it gets an ADR in `docs/adr/`,
and its diagrams appear in the [gallery](diagrams/index.html).

## Archive: documents that belong to the family

**Status:** idea (2026-11-04). No code yet.

### What

Besides photos and films, a family keeps papers that matter. The Archive
should cover:

- the children's school work: scans, PDFs, drawings photographed;
- contracts, invoices, warranties and manuals;
- insurance cases with their evidence: photos of the damage, receipts, letters;
- certificates and records.

Each document is kept once, can be found again, and is kept as safely as
the photos.

### What already exists to build on

- The edge's scan already lists documents as their own kind: `pdf`, `txt`,
  `doc`, `docx`, `csv`, `html` and `svg` (`engine.py`, `KINDS["document"]`).
  Today they are listed but never opened. Fingerprinting covers only photos,
  RAW and films.
- Fingerprints, the bin and stores (ADR-0012) work for any file, so finding
  duplicates and cleaning a drive carry over unchanged.
- Vaults (ADR-0010) already decide who sees what.
- The knowledge graph (ADR-0008) already holds people, places and events,
  which documents can point to.
- Office documents and other files are published as their original
  (ADR-0014), and each can carry a summary in en/de/fr, a document type, its
  own date and the people and places it names. The edge's chat writes it as
  an AI draft, and a person checks it (ADR-0016).
- Photos and films take the same summaries, and the edge finds similar items
  for a selection by how they look, their text and what is known, so the
  chat can name and tag a group (ADR-0017).

### Stages

1. **Onboarding**: fingerprint and remove duplicate documents too, as an
   option on the drive (opt-in, so a photo-only onboarding stays as fast as
   today).
2. **Publish to a vault**, with a preview (the first page) and the text: the
   PDF's text layer first, then OCR.
3. **An Archive view** in the Mediathek: by person (a child's school years),
   by subject (car, house, insurance), by date, with full-text search.
4. **Cases**: an insurance claim or a contract gathers documents and photos,
   with its dates and parties. In the graph it is a schema.org `Event` or
   `CreativeWork`, and its documents are `DigitalDocument`s.
5. **Keep-until dates**, for example invoices for 10 years and warranties
   until they end, with a reminder before something may go.

### Open questions

- **Sensitive papers** (IDs, health, money): a separate, stricter vault?
  Encrypted at rest with a household key, so the cloud operator cannot read
  them?
- **Children's work**: who may see it, and from what age a child decides
  that for themselves.
- **OCR**: on the edge, so nothing is uploaded just to be read, or in the
  cloud later?
- **Long-term formats**: convert to PDF/A when published, or keep the
  original only?
