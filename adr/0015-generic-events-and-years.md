# ADR-0015 — Generic events, occurrences, and a year set by hand

Status: **Accepted** · Date: 2026-11-06 · Concerns the ontology, the edge and the cloud

## Context

Every event needed a start date and one type. A family that wanted one
"Anniversaire" for all birthdays had to give it a range such as 2000–2026,
and a separate "Anniversaire 2017" for every year it cared about. The year
of a photo was taken only from the file, which is wrong for scans and
copies.

## Decision

**A generic event has no date.** `schema:startDate` becomes optional (at most
one). "Anniversaire", "Christmas", "Holidays at Lakeside" are events with a type,
attendees and a place, but no date. A photo tagged to one keeps its own year.

**The year is a separate facet.** The Library already filters by year, from
each photo's effective date, and by event; the two combine. "Anniversaire" +
2017 needs no event of its own. The specific occasion, where it matters, is
usually already an **album** (the folder it came from).

**An occurrence, when one year needs its own facts.** "Anniversaire 2017",
with its own date, attendees or place, is `schema:superEvent` of the generic
event. A photo of the occurrence counts for the generic event too: the
Library's effective events of an item are its own events, then their generic
events (`eventsWithGeneric`, cycles stopped). The event filter lists generic
events first, each with its occurrences under it (`eventTree`).

**A year set by hand.** `mt:year` (`xsd:gYear`, at most one) on a photo or
film. It wins over the file's date in the Library (`dateSource: "year"`);
month and day are not guessed, so the effective date is the 1st of January.
Clearing it returns to the file's date. Set in the tagging wizard for the
chosen photos, and on one photo in the viewer.

**More generic event types**, as data in `mediathek-concepts.ttl` (EN, DE,
FR): Anniversary (jubilee), First communion, Confirmation, Housewarming,
Carnival, Halloween, Day trip, Weekend trip; and three new top concepts,
Life event (Birth, Moving house, Retirement, Funeral), Work event (Company
party) and Everyday.

## Consequences

- **Deploy the cloud first.** An older cloud refuses a dateless event or an
  `mt:year` from a newer edge with a 400 at sync.
- An event without a date sorts after the dated ones; nothing derives a date
  from it, so an undated photo of a generic event stays undated (filter
  "without a date").
- An occurrence's attendees count for photos of the occurrence; a generic
  event's attendees count for every photo under it. Put people on the
  occurrence when they were there only that year.
- The edge reads `mt:year` and `schema:superEvent` from the A-Box like any
  other statement; both are single-valued in sync (`sync.SINGLE`).
