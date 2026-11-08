# ADR-0005 — Media reaches the browser through CloudFront, with one signed policy per session

Status: **Accepted** · Date: 2026-09-29

## Context

The Mediathek shows hundreds of thumbnails per screen and, from phase 3, films
as HLS: a playlist that the player follows to hundreds of segment files. The
template's pattern (ADR-0004), where a Lambda presigns one S3 GET per object,
does not fit either case. It costs a round trip per thumbnail, and an HLS
player requests URLs the page never sees, so it cannot presign them.

The obvious CloudFront answer is **signed cookies**. But cookies are only sent
to the domain that set them. A site on `mediathek.digitalhome.cloud` cannot
set a cookie for `dxxxx.cloudfront.net`, and a media sub-domain needs a
certificate in us-east-1 plus DNS. Neither exists for a personal sandbox on
localhost.

## Decision

- **CloudFront with Origin Access Control** is the only reader of `derived/`.
  The origin path is `/derived`, so the CDN cannot reach `originals/` even with
  a valid signature.
- **mediaPolicy** (AppSync query, `mediaAccess` Lambda) checks that the caller
  is in `mt-family` or `mt-admins`. It then signs a CloudFront **custom
  policy** whose resource is a wildcard, `https://<cdn>/*`, valid for 6 hours.
- The browser appends the returned query string (`Policy`, `Signature`,
  `Key-Pair-Id`) to every media URL. It is one signature for the whole
  session, on any domain, localhost included. hls.js adds it to segment
  requests the same way.
- Query strings are **not** part of the cache key (`CACHING_OPTIMIZED`), so
  differently signed requests share one cached object.
- **The signing key pair is minted in AWS.** A custom resource generates it on
  the first deploy and stores both halves in Secrets Manager. It hands the
  public half to CloudFront. Later deploys reuse the pair. No private key ever
  exists on a laptop or in git.
- Originals stay out of the CDN. `originalUrl(itemId)` presigns one S3 GET for
  a download.

## Consequences

- **Anyone holding the query string can read any derived file until it
  expires.** Pasting a thumbnail URL into a chat shares the whole library's
  thumbnails for up to 6 hours. That is the price of one signature per
  session. Shorten `POLICY_TTL_SECONDS` if it matters. Originals are not
  exposed this way.
- CORS is open (`*`) on the CDN because the signature, not the origin, is the
  gate. hls.js needs CORS for its XHR requests.
- Revoking a person takes effect when their policy expires (at most 6 hours),
  not instantly.
- Rotating the key pair means emptying the secret and redeploying. Every
  outstanding policy dies at that moment, which is the point of rotating.
- A custom domain for the CDN is optional now, not required. Add one only for
  cosmetics or for cookies.
