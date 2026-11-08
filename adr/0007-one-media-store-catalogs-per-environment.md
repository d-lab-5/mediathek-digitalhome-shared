# ADR-0007 — One media store; catalogs per environment

Status: **Accepted** · Date: 2026-09-29 · Amends ADR-0005 (where the CDN lives)

> **Amended by ADR-0011.** Besides break-glass, principals tagged `mediathek-derived-mover=true` (only the `vaultMove` function) may delete the current version of objects under `derived/`. Originals, versions and the bucket stay break-glass only.
and ADR-0006 (where edgeMedia writes)

## Context

The first deploy gave each Amplify environment its own bucket and CDN. For
media this is wrong in three ways:

- **Deleting a sandbox deletes its media.** Amplify sandbox storage empties
  the bucket on delete (`Custom::S3AutoDeleteObjects`).
- **Every environment would need its own upload.** The edge would download
  the old buckets again for each one. The price is small (S3 egress beyond
  the free 100 GB/month), but it is the only real transfer cost there is.
- Stage and prod would drift on which files exist.

Originals are content-addressed (the key is the SHA-256), and they never
change. There is nothing environment-specific about them.

## Decision

- **One long-lived media store**, `backend/infra/media` (stack
  `mediathek-media`), deployed **by hand** and not by the Amplify pipeline:
  - a bucket that is retained, versioned and TLS-only, with non-current
    versions expiring after 30 days;
  - the signed CDN (the `MediaCdn` construct from ADR-0005, now shared);
  - SSM parameters under `/mediathek/media/` for the bucket, CDN domain,
    key-pair id and signing-secret ARN;
  - termination protection on.
- **Deletes are denied** by bucket policy to every principal except the
  break-glass role `mediathek-media-admin`, which a person assumes by hand.
  An explicit Deny beats any Allow, so an everyday admin key cannot wipe the
  library.
- **Originals are readable by media readers only.** The bucket policy
  denies `s3:GetObject` on `originals/*` to every principal without the IAM
  tag `mediathek-media-reader=true`, except the break-glass role. Each
  environment tags exactly two roles: `mediaAccess` (presigned downloads)
  and `edgeMedia` (checksum checks). An everyday admin key, `dlab5_devops`
  included, reads no original.
- **The CDN's grant covers `derived/*` only.** `MediaCdn` hands CloudFront a
  bucket reference, so CDK writes no `bucket/*` grant, and it writes its own
  grant scoped to the prefix and the distribution.
- **Uploads are write-once.** `edgeMedia` presigns with `If-None-Match: *`,
  and it refuses a derived file that already exists with different content.
  A changed rendition gets a new name, so a stage experiment can never
  replace what prod shows.
- **Environments share the media, not the rest.** Stage and prod
  (`AWS_BRANCH`), and a sandbox started with `MEDIATHEK_MEDIA=shared`, read
  the SSM parameters in the stacks that use them. Each keeps its own Cognito
  pool, catalog tables and edge pairings.
- **A plain sandbox keeps its own disposable bucket** with the same
  `MediaCdn`. Experiments cannot leave anything in the real store.
- The media stack lives under `backend/` rather than at the repository root.
  That way it shares the backend's `aws-cdk-lib` install; two copies of the
  library break CDK's construct checks.

## Consequences

- The media stack must be deployed **before** the first shared environment,
  or that environment fails to read its SSM parameters.
- Removing media is a deliberate act: assume the break-glass role, then
  delete. Versioning keeps a deleted object for 30 days.
- An object uploaded by stage that prod never catalogs is an **orphan**. It
  costs storage and harms nothing. The edge's orphan report lists these; it
  never deletes them.
- The edge registers the same item in several catalogs without downloading
  it again. The upload step answers "exists", and the edge keeps a local
  ledger of what it registered.
- `amplify_outputs.json` reports `custom.mediathek.mediaStore` as `shared`
  or `sandbox`, so a person can see which store an environment writes to.
- To inspect or repair originals by hand, assume the break-glass role. The
  tag condition means a new environment must tag its reader roles **before**
  it can serve originals, and `backend.ts` does that.
- The trust policy of the break-glass role names IAM users by name
  (`-c breakGlassUsers=…`), and the account id comes from the deploying
  credentials. Neither is written in the repository.
