# ADR-0016 — Document summaries, written by the agent and checked by a person

Status: **Accepted** · Date: 2026-11-07 · Concerns the edge and the cloud · Second step of the Archive (ROADMAP.md) · Extended to photos and films by ADR-0017

## Context

Office documents and other files are published as their original only
(ADR-0014). The Mediathek knows their name, size and type, and nothing
about what they say. A family's papers are only useful when they can be
found again and someone can tell what each one is: an invoice for the
boiler, the school report of 2019, the insurance letter about the hail.

The edge's chat (Claude Code on the person's PC) can read a document when
the edge hands it the text. Writing a short description for each one is
exactly the kind of work it does well. It can also be wrong, so a person
has to be able to review it.

## Decision

**A summary in the knowledge graph, not in the item row.** What a document
says is knowledge about it, like who is on a photo, so it lives in the A-Box
of the item's own vault:

| Statement | Meaning |
|---|---|
| `a mt:Document` | an office document or other file (`rdfs:subClassOf mt:Item, schema:DigitalDocument`) |
| `schema:abstract "…"@en, @de, @fr` | the summary, at most one per language |
| `mt:summaryState mt:SummaryDraft` / `mt:SummaryChecked` | written by the agent, or checked by a person |
| `mt:documentType mt:Invoice` | one of the 20 concepts in `mt:DocumentTypes` (SKOS, en/de/fr) |
| `schema:dateCreated "2021-03"^^xsd:gYearMonth` | the date the paper carries, not the file's |
| `schema:mentions <person>`, `<place>`, `<event>` | the parties and the subject, from the vault's knowledge |

A document also takes `mt:ofEvent`, `mt:place` and `mt:lifeArea`, like a
photo. An event can be the "case" a set of papers belongs to.

**Three languages.** The agent writes en, de and fr at once, so every member
reads it in their language. The viewer shows the reader's language, falling
back to en, de, then fr.

**Draft, then checked.** Confirming the chat's proposal stores the summary as
`mt:SummaryDraft`. In the Library viewer (and the edge's file card) an admin
reads it, edits it, and marks it **Checked**. Marking it checked is never
proposed by the agent. The Library filters Office and Other by "no summary
yet", "AI draft, to check" and "checked". The shapes refuse a summary without
a state.

**What is read, and where.** The edge extracts the text on the PC (`doctext.py`):
- PDF with pypdf, or `pdftotext`;
- Word, Excel, PowerPoint and OpenDocument as the zipped XML they are;
- text, CSV, RTF, HTML and SVG;
- old binary Office files only through LibreOffice when installed.

At most 20,000 characters go to the agent, and only when the person asks it
to read or summarise. A scanned PDF without a text layer is reported as such;
OCR is a later step.

**What a summary must not carry.** Account numbers, IBANs, card numbers, long
ID numbers, passwords, PINs, keys and tokens. A summary describes the paper,
and its numbers stay on the paper. Three places check this:
- the edge (`knowledge.sensitive()`), before storing;
- the Library (`packages/core/src/sensitive.ts`), before saving;
- the graph Lambdas (`graph-shared/sensitive.ts`, the same file, compared by a
  test), which hold for both.

A refusal names what was found, never the value.

**Vault moves need no change.** `vaultMove` already introduces whatever a
moved statement points to, so a document's mentioned people and places
travel with it (tested).

## Diagrams

- [Summarising a document](../diagrams/adr-0016-summarise.html): who calls whom, from the selection to a checked summary.
- [A summary's state](../diagrams/adr-0016-summary-state.html): no summary, proposed, AI draft, checked, and the two dead ends.

Both are standalone HTML made with Archify from their sources in `diagrams/src/`; edit a
source and run `npm run diagrams`. All diagrams are listed in the [gallery](../diagrams/).

## Consequences

- **The text of a document leaves the PC when the person asks the chat to
  read it.** It goes to Claude under the person's own claude.ai account, as a
  picture does with look_at. Nothing is read on its own, and nothing leaves
  when no one asks.
- **A summary is as visible as the vault.** A family vault's papers become
  readable as summaries by the whole family. ADR-0014's caveat applies twice:
  point a source of sensitive papers at a private vault before summarising.
- **An agent's summary can be wrong.** That is why a draft is marked as one
  everywhere it shows, and why only a person can mark it checked.
- **The guard is a pattern check.** It catches the usual shapes (IBAN with
  its checksum, cards by Luhn, nine digits or more, `password:` …), not every
  secret. The agent is told the rule as well.
- **The cloud must be deployed first.** An older cloud refuses `mt:Document`,
  `schema:abstract` and the rest with a 400.
