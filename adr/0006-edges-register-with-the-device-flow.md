# ADR-0006 — Edges register with the digitalhome.cloud device flow, and write media through it

Status: **Accepted** · Date: 2026-09-29

## Context

The catalog and the bucket are filled by `mediathek-digitalhome-edge`, a local
tool that hashes, renders and uploads on the curator's workstation. It needs
to write to a cloud it has no account in. The first draft handed it the
curator's own AWS credentials and had it write DynamoDB directly. That meant
account-admin keys on every edge, no revocation short of rotating them, and
a second writer that knows the table layout.

digitalhome.cloud already solved this for `digitalhome-edge` boxes:
DH-SPEC-100, an RFC 8628 device authorization grant whose wire spec is
`digitalhome-edge/docs/specs/edge-cloud-api.md` v0.2, implemented in
`digitalhome-cloud-darkfactory/repos/core`.

## Decision

**The Mediathek uses the same mechanism, on the same wire.**

- `POST /edge/v1/device_authorization`, `/token`, `/token/rotate` and
  `/telemetry`, with the handlers, code formats (`dc_v1_`, `XXXX-XXXX`,
  `dt_v1_<edge_id>.<secret>`), TTLs and error strings carried over from
  darkfactory.
- The trust anchor is an **mt-admin's Cognito login**. The edge shows a code.
  The admin opens `/link?user_code=…` in the Mediathek and approves it. The
  edge's next poll returns its device token. The cloud stores only
  `sha256(token)`.
- The SmartHome binding is dropped. An edge belongs to the library.
- Two Mediathek routes sit behind the same bearer:
  - `POST /edge/v1/media/uploads` returns presigned PUTs for an item's
    original and derived files. Each PUT is signed with
    `x-amz-checksum-sha256`, and an original's checksum must equal its id.
    S3 refuses bytes that do not hash to what was claimed.
  - `POST /edge/v1/media/items` re-checks the stored original's checksum
    against the id. It then writes the Item, finds or mints Collections by
    folder path, and adds Memberships.
- Settings → Edges lists the linked edges and revokes one. A revoked edge gets
  410 and must pair again.

## Consequences

- The edge holds **no AWS credentials for the new bucket or the catalog**,
  only a device token that can be revoked on its own. It still uses the
  curator's AWS CLI credentials to *read* the old buckets during migration,
  which is a local matter.
- The DynamoDB item shapes are written by `edgeMedia` rather than AppSync, so
  `edgeMedia` must set what AppSync would: `__typename`, `createdAt` and
  `updatedAt`. It must also store `renditions` as a native map, because
  AppSync stores AWSJSON that way. A new model field goes into
  `data/resource.ts`, `edgeMedia` and the site's types in the same change.
- Membership ids are the pair `<collectionId>:<itemId>`. They are derived, not
  minted (ADR-0003's exception), so a re-run cannot put a photo in an album
  twice.
- **Stack placement differs from darkfactory.** `edgeMedia` (edge stack)
  writes catalog tables (data stack), so the pairing tables live in the data
  stack. Otherwise `edgeDeviceApproval` (data) reading them would close a
  cycle.
- Single presigned PUTs cap an object at 5 GB. The largest file today is
  3.1 GB. Phase 3 (video) adds multipart before anything larger arrives.
- Changes to the shared wire belong upstream, in the edge-cloud-api spec,
  before either side diverges.
