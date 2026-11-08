# ADR-0009 — People are ids, names are labels; face boxes live on the Item

Status: **Accepted** · Date: 2026-09-30

## Context

The edge groups faces that look alike. Some groups are clearly one person
whose name nobody remembers yet, or someone only a relative will recognise.
Until now a person needed a name (`schema:name` was required), so such a group
could only be named wrongly or thrown away, and it was regrouped (renumbered)
on every scan.

The Mediathek should show on each photo who is on it, count those not yet
recognised ("+2 not recognised"), and let someone name them there, with the
name then holding on every photo of that person.

Face regions were planned as Web Annotations in the A-Box (ADR-0008,
`mt:FaceAnnotation`). The main A-Box is 106 KB after 439 photos, the server
limit is 350 KB (a DynamoDB item), and the 868 confirmed faces as annotations
would take most of what is left, with thousands of photos still to come.

## Decision

- **A person is their minted id** (`…/id/person/p-…`, ADR-0003). `schema:name`
  is optional (at most one). A person without one is shown as
  **"Unknown" + the first four characters of the id**, the same on the edge
  (`knowledge.unknown_label`) and in the site (`core unknownLabel`).
- **`mt:hidden true`** leaves someone out of lists and filters, while each
  photo still counts them. People kept without a name start hidden. The
  edge also has **ignored** (strangers): never listed, and taken out of the
  A-Box on the next export. That state stays on the edge.
- **Merging keeps a forwarding address.** When one record turns out to be
  someone else, everything said about or pointing at it moves to the other,
  and it stays as `mt:mergedInto <other>`. Readers follow it, so a face box or
  a link made elsewhere to the old id still finds the person. The edge
  (`knowledge.merge_people`) and the site (`core namePerson`) do the same.
- **Who is in the A-Box; where is on the Item.** The edge sends face boxes
  to `POST /edge/v1/media/faces`, and they are stored as `Item.faces`:
  `{"r": rotation found at, "f": [{"b": [x, y, w, h], "p": person IRI}]}`,
  with boxes as fractions of the picture turned by `r`. The server keeps only
  `b` and `p`, and only a well-formed person IRI. `mt:FaceAnnotation` stays
  in the ontology as the model; `Item.faces` is its compact projection.
- **The A-Box wins over the edge's catalog.** Every change on the edge
  (name, hide, merge) is written to the local A-Box at once. After a sync,
  the edge takes names, hidden flags and merges from the A-Box (`reconcile`).
  A name given in the Mediathek therefore reaches the edge, and the edge's
  face model learns it.

## Consequences

- Naming someone once names them on every photo, because photos point at
  the id, not the name. The same holds for renaming.
- Only admins can name people in the site (saveGraph is mt-admins). Family
  members see the count and the faces.
- Sync from the edge now also sends face boxes for published photos, but only
  those that changed (a digest per photo and connection, `faces_sent`), and
  an empty list where faces went away (e.g. someone was ignored).
- Nothing about faces beyond boxes and ids leaves the PC. Crops in the site
  are cut from the display rendition the site already has.
- Boxes are relative to the rotation they were found at. The site maps them
  back onto the unturned rendition (`core unturnedBox`). A photo turned later
  is scanned again by the edge, and its boxes follow on the next sync.
- `schema:name`, `mt:hidden` and `mt:mergedInto` are single-valued in the
  edge's three-way merge, so two different names given in two places become
  a conflict to decide, not two names.
- Older catalogs migrate in place: people keep their ids and get the A-Box
  id of the same name on first export (`people.link_iris`).

## Addendum (2026-10-01): people tagged by hand, and faces marked in the Library

- **"+ Person"** (admins) adds `foaf:depicts` from the photo to someone known,
  someone new by name, or someone not recognised (hidden, no name), with
  `core tagPerson`. It works for anyone on the photo, including a face the
  edge never found, or someone seen only from behind.
- **A marked face** is a Web Annotation in the A-Box (`mt:FaceAnnotation`),
  which is the model ADR-0008 planned. The selector is a media fragment,
  `xywh=percent:…`, of the picture **as stored (unturned)**, which is what a
  media fragment means. The site converts from the turned view
  (`core unturnedBox`). Hand marks are few, so they fit the A-Box. Face boxes
  the edge finds stay on the Item.
- **The edge learns marked faces on sync** (`people.learn_marked`):
  - When a face it already knows lies in the box, that face is confirmed as
    the person.
  - Otherwise it looks for the face inside the box, zoomed in, in its local
    working copy (`faces.find_in_box`). It keeps what it finds as a
    confirmed face with `source='marked'`, which a rescan keeps and turns
    with the photo.
  - Either way, the face then teaches the suggestions. The vector stays on
    the PC.
- **Taking a person off a photo** removes the link and its mark. The edge
  then un-learns the face, so its next export cannot bring the person back.
  A person the edge found by their face, without a mark, is corrected on the
  edge. The site links to that photo there (`http://127.0.0.1:8771/#photo=<sha256>`,
  which works only on the PC that runs the edge).
