# Mediathek: shared documentation

The decisions, roadmap, diagrams and ontology reference of the Mediathek, a
family media library made of two applications:

- **the edge**, a local application on a PC (Python, GPL-3.0);
- **the cloud**, the web library (Gatsby + AWS Amplify, MIT).

Both are in private repositories for now. This one is public and holds only
what can be: structures and decisions, never a family's data (see
[SECURITY.md](SECURITY.md)).

Read it at **https://docs.mediathek.digitalhome.cloud/**, or with the other
D-LAB-5 products at **https://docs.dlab5.net/digitalhome/mediathek/**.

## What is here

| Path | What |
|---|---|
| `adr/` | Architecture Decision Records, numbered, with their consequences |
| `ROADMAP.md` | Where the Mediathek is heading |
| `diagrams/` | Archify diagrams: sources in `src/`, rendered pages beside them; [README](diagrams/README.md) |
| `ontology/` | The T-Box, SHACL shapes and SKOS concepts, copied from the cloud |
| `site/` | The landing page text and the stylesheet |
| `scripts/` | `diagrams.mjs` (render and check), `site.mjs` (build the site), `check.mjs`, `sync-ontology.sh`: from [template-dlab5-shared](https://github.com/d-lab-5/template-dlab5-shared) |
| `shared.json` | What the scripts need to know about the Mediathek: name, domains, texts, the ontology's source |

## Working on it

```bash
npm ci
npm run diagrams          # render the diagrams whose source changed (needs Archify)
npm run check             # diagrams in step, ontology parses, site builds, nothing private
npm run serve             # build _site/ and serve it on http://127.0.0.1:8792/
scripts/sync-ontology.sh  # copy the ontology from ../mediathek-digitalhome-cloud
```

Archify is a Claude Code skill (`~/.claude/skills/archify`), not a dependency:
rendered pages are committed, so CI and the site build never need it.

**Adding a diagram:** write `diagrams/src/<name>.<type>.json`, list it once,
with what it explains, under a group in `diagrams/README.md` or under its ADR's
`## Diagrams`, then `npm run diagrams` and `npm run check`.

**Adding a decision:** `adr/NNNN-short-title.md`, with Context, Decision and
Consequences filled in. Numbers are never reused.

## Publishing

`stage` is the integration branch; `main` is updated by a promotion PR. A push
to `main` runs `.github/workflows/pages.yml`, which checks, builds `_site/` and
deploys it to GitHub Pages under the custom domain in `_site/CNAME`.

## Licence

Documents and diagrams CC BY 4.0; scripts and the ontology copy MIT. See
[LICENSE](LICENSE) and [NOTICE](NOTICE).
