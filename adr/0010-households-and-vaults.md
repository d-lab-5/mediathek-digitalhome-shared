# ADR-0010 — Households and vaults

Status: **Accepted** · Date: 2026-10-01 · Supersedes the single-family access model of ADR-0002 (mt-family) and ADR-0005 (one CDN policy for everything)

> **Amended by ADR-0011.** "Move to vault" exists now (`moveToVault`, `/edge/v1/media/move`), with its knowledge and album entries, and the old derived files deleted at once. An item lives in one vault: the most private one wins when the same photo is meant for two.

## Context

Until now one Mediathek was one family. `mt-family` could read everything and
`mt-admins` could do everything. The signed CDN policy covered every file
under `derived/`, and the catalog was keyed by a photo's SHA-256 alone.

That leaves two gaps:

- **Inside the family,** access is all or nothing. There is no "only for the
  two of us", and nothing to keep a child's account away from some photos.
- **A second household,** such as relatives with their own family, could not
  use the same Mediathek:
  - A catalog keyed by hash has room for one owner per photo.
  - A shared store would answer "already there" for a photo another
    household uploaded, which reveals that it exists.
  - The operator would see everything.

## Decision

**Household.** A household (`h-…`, minted) is a group of people with their
own admins.
- Its admins are the Cognito group **named exactly like the household id**.
- A household's originals live under `originals/<household>/sha256/…`, so
  deduplication never reaches across households.

**Vault.** A vault (`v-…`, minted) is a set of photos and videos with its
own readers.
- Its readers are the Cognito group **named exactly like the vault id**.
- Every household starts with one vault of kind `family`. Admins add
  `private` vaults.
- A photo belongs to exactly one vault (v1). The edge decides at publish
  time, from the vault of the source it was found in. "Move to vault" comes
  later.
- A vault's files live under `derived/<vault>/<sha256>/…`.

**Who sees what** (enforced by AppSync and the Lambdas, not by the page):

| Who | Sees |
|---|---|
| vault reader (group `v-…`) | that vault's photos, albums and A-Box |
| household admin (group `h-…`) | every vault of the household. Can also write: A-Box, angles, tags, members, new vaults, edge pairing |
| operator (`mt-admins`) | runs the platform: creates households, sees household names and edge metadata. **No photos, names or A-Boxes** unless also a member |

**Catalog.** New models carry `vaultId` and `householdId`. Their rules are
`groupDefinedIn("vaultId")` (read) and `groupDefinedIn("householdId")` (read
and update), so a row is visible exactly to the groups it names. The models:
- `Asset`: key (vaultId, sha256), replacing Item.
- `Album` and `AlbumEntry`: replacing Collection and Membership.
- `Household` and `Vault`.
- `Graph` (one A-Box per vault, named like the vault) and `Suggestion` gain
  the two fields.

The old Item, Collection and Membership models are removed once the
re-published library has been checked.

**Files.** `mediaPolicy` signs one CloudFront custom policy **per vault** the
caller may read, each for `https://<cdn>/<vault>/*`.
- A CloudFront policy has one resource pattern, so separate prefixes are what
  makes separate access possible.
- Policies expire after 6 h. Removing someone from a vault therefore takes
  effect for files within 6 h, and for the catalog at their next token
  refresh (≤ 1 h).
- `originalUrl(vaultId, id)` presigns only for that vault's readers and the
  household's admins.

**Membership.** A `households` function creates households and vaults, which
means Cognito groups. It adds and removes members by e-mail
(AdminAddUserToGroup), only for accounts that already exist, since signup
stays admin-only (ADR-0002).
- `createHousehold` is for operators. It makes the household, its family
  vault and its first admin, and can copy everyone in `mt-family` into the
  family vault.

**Edges belong to a household.** Pairing (`approveDeviceCode`) names the
household and needs one of its admins. The registry row keeps it, and every
edge call is limited to that household's vaults. An edge paired before this
has no household and is refused until it is linked again.
`/edge/v1/household` tells an edge its household and vaults.

**A-Boxes per vault.** A private vault's people, events and links stay in
that vault's graph.
- The site reads the graphs of every vault it can see and shows their union.
- A person known in two vaults has the same id in both.
- A change goes to the graph of the photo's vault. Naming someone goes to
  every graph that knows them.

**Migration.**
1. An operator creates the first household.
2. The edge is linked again (now to that household).
3. The edge re-publishes into the family vault: about 2.2 GB, about €0.20 of
   download from the old buckets.
4. Face boxes, angles and the A-Box (`main` → the family vault's graph) follow
   on Sync.
5. Once checked, the old models, files and `mt-family` are removed.

## Consequences

- A private vault really is private: no catalog row, no A-Box statement and
  no CDN file of it is reachable without membership. A sha known from
  elsewhere does not help, because the file sits under a prefix the caller's
  policy does not cover.
- Household admins see their household's private vaults. Private means private
  from other members, not from the admins, who could add themselves anyway.
- The operator can run the platform without seeing any household's photos.
  Recovery needs a household admin, or the break-glass role (ADR-0007),
  whose use is visible in CloudTrail.
- The same photo in two households is stored twice (two originals). Within one
  household, one copy.
- Listing the library is one query per visible vault rather than one scan.
- Edge sources choose a vault by **name** (e.g. "Family"), because vault ids
  differ between stage and prod. Each connection resolves the name to its own
  vault.
- Moving a photo between vaults needs its derived files deleted from the old
  prefix, so that access really ends. That needs a role allowed to delete
  `derived/*` (not originals). It comes with "Move to vault".

## Addendum (2026-10-01): the same household on two sites

Store keys carry the household id (originals) and the vault id (derived files).
Because each environment minted its own ids, prod would have uploaded every
original again and converted every film again, which defeats ADR-0007's single
store.

- **A household code** goes from one site to another. It has the form
  `h-…/v-family/v-private=Name/…`, and its admins see it in Settings.
  `addHousehold(…, sameAs)` creates the household on a second site with the
  same ids.
  - Each id is checked for its form.
  - No id may exist on that site already, whether as a row or as a Cognito
    group.
  - Only operators can create households, and that does not change.
- With the same ids, the edge registers its items on the second site from its
  ledger (`sync_catalog`). The files are already in the store, so nothing is
  uploaded or converted twice.
- **Trust:** a household that exists on two sites can be reached through either
  site's groups. Whoever operates either pool could add themselves to its
  admin group. Use a code only between sites run by the same operators, as
  stage and prod are. A site run by someone else must mint its own ids.
- Uploads stay write-once, so a stage experiment never replaces a file that
  prod shows.
