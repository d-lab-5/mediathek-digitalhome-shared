# The Mediathek

A family's media library: photos and films, and the documents that matter,
together with the people, pets, places and events they belong to. It is two
applications that work as one.

<div class="apps">

<section>

## The edge, on a PC

A local application, started on the computer where the files are. It lists
sources (folders, drives, buckets, Google exports) without changing them,
finds the doubles, recognises faces on the PC, and publishes what a person
chooses. A chat agent helps name people and events, and proposes every change
for the person to confirm. Pictures and faces are compared on the PC; only
what a person publishes leaves it.

Python, Flask, an MCP server, SQLite. GPL-3.0, in a private repository for now.

</section>

<section>

## The cloud, in the browser

The library the family opens: a household with its vaults, each vault with
the people allowed to read it. It stores each piece of media once, delivers
it through signed links, and keeps what is known about it (who, where, when,
what it says) as a knowledge graph per vault, checked against the ontology.

Gatsby, AWS Amplify (Cognito, AppSync, Lambda, S3, CloudFront). MIT, in a private repository for now.

</section>

</div>

## How they connect

An edge is linked to a Mediathek with a code an admin approves (the device
flow, [ADR-0006](adr/0006-edges-register-with-the-device-flow.md)). After that
it uploads what is published, and the two keep each vault's knowledge in step.
The [diagrams](diagrams/) show it end to end, then each application on its own.

## In these pages

- **[Diagrams](diagrams/)**: {diagrams} interactive drawings of the flows, the parts and the models.
- **[Decisions](adr/)**: {adrs} architecture decisions, with why and what follows.
- **[Roadmap](roadmap.html)**: where the Mediathek is heading.
- **[Ontology](ontology/)**: the T-Box, the classes, properties, rules and vocabularies every vault's knowledge follows.

These pages hold structures and decisions only. No family's data is here.
