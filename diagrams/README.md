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
- [From a folder to the Library](../diagrams/e2e-folder-to-library.html): how one file is fetched and hashed on the PC, uploaded with a checksum S3 enforces, registered, and shown through a per-vault CDN policy.
- [Linking an edge](../diagrams/e2e-link-edge.html): the RFC 8628 device flow, from the code on the PC to a household admin's approval, the device token, its rotation and revocation.
- [Knowledge in both places](../diagrams/e2e-knowledge-sync.html): how the A-Boxes on the edge and in the cloud merge statement by statement, and where every write is checked.
- [A chat proposal](../diagrams/e2e-chat-proposal.html): what happens to a change the chat asks for, from waiting for a click to ran, failed or dismissed.

## Edge

The local application: what runs on the PC, and how a person works with it.

- [The edge's parts](../diagrams/edge-parts.html): the page, the web server and its job queue, the engine, the catalog and the local models, and how the chat reaches them only through the edge's own MCP server.
- [Onboarding a drive](../diagrams/edge-onboarding.html): scan, fingerprint, move the extra copies into a bin that can be undone, check it before emptying, then keep the drive as a store that publishes what is new.

## Cloud

The web application: what runs in AWS, and who may see what.

## Models

What is stored where: the ontology, the edge's catalog and the cloud's tables.

- [The data model](../diagrams/overview-data-model.html): households, vaults, assets and albums in the catalog, people, pets, events and places in each vault's A-Box, and what the edge keeps to itself.
