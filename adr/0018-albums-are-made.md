# ADR-0018 — Albums are made; folders are where things came from

Status: **Accepted** · Date: 2026-11-10 · Concerns the edge and the cloud · Replaces the folder albums of ADR-0010

## Context

An album was the folder a file was found in. `DCIM/102CANON` became an album
because a camera named its folder that way, and nobody could change it:
- there was no way to create, rename, merge or clean up an album, on the edge
  or in the Mediathek;
- the cloud's `Album` and `AlbumEntry` rows were written only by the edge's
  publish and never removed, so a renamed folder left the old album behind
  with its items;
- one holiday spread over three cameras was three albums, and a "Not sorted"
  folder holding ten years was one.

Events (ADR-0008, 0015) already show the way: knowledge in the vault's A-Box,
edited on the edge and in the Mediathek, and synchronised.

## Decision

**An album is knowledge.** It sits in the A-Box, like an event:
- `mt:Album` (a `schema:Collection`) with one `schema:name`, at most one
  `schema:description`, and at most one `mt:cover`, which is one of its items;
- `<item> mt:inAlbum <album>` for each item in it;
- a minted id, `…/id/album/b-` and ten characters (ADR-0003), never a name or
  a path.

**An album is in each vault it has items in, with the same id.** As for
events (ADR-0011), each vault's A-Box says which of *its* items are in the
album. Bringing an album into another vault shows its name to that vault's
members, so it waits for a yes when the album is not in the family vault. The
cover is said in the A-Box of the vault its item is in.

**A folder is not an album.** Where a file was found stays provenance
(`Asset.origins`). A folder becomes an album only when a person makes one of
it, and the album remembers the folder (`mt:fromFolder`), so the suggestion
to make it is not repeated.

**Made by people, helped by the edge.** The edge's Albums tab suggests:
- **from a folder:** a folder whose items are in no album, with a name
  proposed from its dates, places, events and people;
- **new from groups:** items in no album that belong together by time, looks
  and text (ADR-0017);
- **missing items and strays:** items that look like they belong to an
  album, and those that do not fit the rest of it;
- **merge and clean up:** albums that share items or are one trip split over
  folders, and empty albums.

Suggestions are computed on the PC, like similarity. The chat can read them,
look at the items and propose a name. Every change is a button or a card the
person confirms, on the edge or in the Mediathek.

**Edited in both places.** On the edge in the Albums tab, and in the
Mediathek on its Albums page, for household admins, through `saveGraph` with
its version check. The A-Box sync carries them both ways, as it does events.

**The folder albums go.** In this order:
1. The Library's album filter reads albums from the A-Box.
2. The edge stops sending folders as albums when it publishes. They are
   still sent as where each file was found.
3. One release later, `Album` and `AlbumEntry` are removed, as `Collection`
   and `Membership` were. A move to another vault (ADR-0011) then carries the
   album's statements with the items, as it does for events.

## Consequences

- **Nothing is sorted for you.** After the switch, items are in albums only
  once someone made them. The edge's first suggestions list every folder, so
  turning the useful ones into albums means going through one list.
- **An album's name is personal data, like an event's.** It goes where the
  A-Box goes, and is shown to another vault's members only after a yes.
- **Two names for one album can meet.** Renamed in the Mediathek and on the
  edge before a sync, the A-Box sync asks which name to keep, as it does for
  an event.
- **The cloud must be deployed first.** An older cloud refuses an A-Box with
  an album (its shapes do not know `mt:cover` and `mt:fromFolder`).
- **Old suggestions stop.** Folder names stop meaning anything to the
  Library. A link with `?c=<folder album>` opens the whole Library.
