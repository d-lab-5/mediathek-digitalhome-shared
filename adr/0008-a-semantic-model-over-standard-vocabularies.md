# ADR-0008 — A semantic model over standard vocabularies, English master

Status: **Accepted (phase 1)** · Date: 2026-09-29

## Context

Photos are about more than albums: a class reunion, a family, a place, a
part of life. A column per idea in DynamoDB would need a schema change for
every new kind of event. The family works in three languages. DigitalHome.Cloud
already models homes as a T-Box, SHACL shapes and per-tenant A-Boxes.

## Decision

- **Reuse before inventing.** The model reuses:
  - schema.org for events, places and media objects
  - FOAF for persons, groups and `depicts`
  - the RELATIONSHIP vocabulary for family relations
  - SKOS for concept schemes
  - Web Annotation with media fragments for face regions (stored compactly on the Item, ADR-0009)
  - WGS84 for coordinates

  `mt:` adds only what these lack (`mt:Item`, `mt:Family`, `mt:eventType`,
  `mt:lifeArea`, `mt:place`, `mt:classmateOf`, `mt:FaceAnnotation`, …).
- **Event types and life areas are SKOS concepts**, so a new one is data. An
  "area" is two things: **places** (a hierarchy of `mt:Place`, optionally
  linked to GeoNames) and **life areas** (a SKOS scheme).
- **English is the master.** SHACL requires exactly one `@en` prefLabel per
  concept, and the tests require `@de` and `@fr` for everything a person
  sees.
- **SHACL shapes** define a valid A-Box. The tests are on the DHC pattern and
  prove the shapes refuse ten kinds of broken data, each for the right
  reason.
- **A-Boxes are per family or occasion, and synchronised.** They are edited
  on the edge or in the Mediathek, and synchronised through the edge's
  device token. That is phases 2 and 3, and not built yet.

## Consequences

- A-Boxes are personal data. With sync (phase 3), family relations and
  attendance live in AWS too, behind Cognito and `mt-admins`. Face vectors
  still never leave the edge: an A-Box holds only confirmed names and photo
  regions.
- The site, the edge and later CLIP read labels from these files, so a new
  concept appears everywhere in three languages at once.
- Real A-Boxes never go into the repository, only fictional examples.
