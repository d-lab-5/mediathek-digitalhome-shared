# CLAUDE.md: Mediathek shared documentation

The public home of the Mediathek's decisions, roadmap, diagrams and ontology
reference, published by GitHub Pages at docs.mediathek.digitalhome.cloud. The
two applications it describes live in their own, private repositories beside
this one: `../mediathek-digitalhome-edge` and `../mediathek-digitalhome-cloud`.

> **This repository is public.** Read SECURITY.md. No A-Box data, no real
> names, no account ids, hostnames of AWS resources, keys or local paths.
> `npm run check` sweeps for them; it cannot catch a real name in prose.

## Commands

```bash
npm ci
npm run diagrams            # render what changed; needs the Archify skill
npm run check               # what CI runs: diagrams, ontology, site, public sweep
npm run serve               # build and serve _site/ on 127.0.0.1:8792
scripts/sync-ontology.sh [--check]   # the ontology copy vs ../mediathek-digitalhome-cloud
```

## Things that bite

0. **The scripts, site/site.css, the workflow, SECURITY.md and LICENSE come
   from d-lab-5/template-dlab5-shared.** `copier update --trust` replaces them;
   fix them there. `shared.json` (name, domains, texts, ontology) is this
   repository's. The site is also built into docs.dlab5.net/digitalhome/mediathek/.
1. **The ontology's source is in the cloud repo**, `packages/ontology`, because
   the cloud's build and backend need it there. Change it there, then run
   `scripts/sync-ontology.sh` here (its source and files are in `shared.json`).
   CI cannot compare the two: the cloud repo is private.
2. **A diagram is listed exactly once**, in `diagrams/README.md` under a group or
   in its ADR's `## Diagrams`, as `- [Title](../diagrams/<name>.html): what it
   explains.` That line is the gallery card's text. `check` fails otherwise.
3. **Never edit a rendered `diagrams/*.html`.** Edit the source and run
   `npm run diagrams`; `src/rendered.json` records which source a page came
   from, and `check` notices a page changed by hand.
4. **Facts in a diagram come from the code**, read first in the edge or cloud
   repo. Cite paths in the cards (`mediathek_digitalhome_edge/similar.py`);
   the diagrams carry no repository evidence because the code is elsewhere.
5. **ADRs are moved, not copied.** The cloud and the edge refer to them as
   "ADR-00NN in mediathek-digitalhome-shared".

## Conventions

Write for a reader who was not there: short sentences, plain words. Commits as
in the other D-LAB-5 repos; `stage` integrates, `main` is promoted by PR.
