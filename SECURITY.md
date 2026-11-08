# Security

This repository is **public**, and so is the site built from it. It holds
the Mediathek's structures and decisions, never a family's data or anything
that would help reach one.

Never commit:
- A-Box data: people, pets, events, places, items, faces, or example vaults
  made from real ones. Invent names when an example is needed.
- AWS account ids, ARNs, app ids, CloudFront or API hostnames, bucket names,
  Cognito pool or client ids, `amplify_outputs.json`, `.env` files.
- Keys, tokens, emails, local paths.

`npm run check` sweeps every tracked file for these and fails the build;
run it before a push. It cannot catch a real name written as prose, so read
what you add.

To report a problem with the Mediathek itself, write to the maintainers
through the repository's GitHub security advisories rather than an issue.
