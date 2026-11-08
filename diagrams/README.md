# Diagrams

Interactive drawings of how the Mediathek works, made with Archify. The site
shows them in its gallery at `/diagrams/`.

- `src/<name>.<type>.json`: the source, the only file to edit.
- `<name>.html`: the page rendered from it. Never edit it by hand.
- `src/rendered.json`: which source each page was rendered from.

`npm run diagrams` renders what changed (it needs the Archify skill in
`~/.claude/skills/archify`, or `$ARCHIFY`); `npm run check` says whether every
page is in step with its source and listed once.

A diagram is listed once, with what it explains: under one of the groups
below, or in the ADR it belongs to, under that ADR's `## Diagrams`. Each line
reads `- [Title](../diagrams/<name>.html): what it explains.` and becomes the
gallery card's text.

## End to end

How the edge on a PC and the cloud work together.

- [How the Mediathek works](../diagrams/overview-how-it-works.html): from the sources on the PC through the edge to the shared store and the Library, and what never leaves the PC.

## Edge

The local application: what runs on the PC, and how a person works with it.

## Cloud

The web application: what runs in AWS, and who may see what.

## Models

What is stored where: the ontology, the edge's catalog and the cloud's tables.

- [The data model](../diagrams/overview-data-model.html): households, vaults, assets and albums in the catalog, people, pets, events and places in each vault's A-Box, and what the edge keeps to itself.
