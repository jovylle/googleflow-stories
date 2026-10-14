# Submitting the GFS plugin to the ChatGPT/Codex plugin directory

Sources re-read **2026-10-14** (they move — read them again before uploading):

- Guidelines — https://developers.openai.com/plugins/plugin-guidelines
- Packaging — https://developers.openai.com/plugins/build/plugins
- Submission flow — https://developers.openai.com/plugins/deploy/submission
- Package field reference — the submission page's *Manifest fields* and
  *Automatically provide submission and review information* sections

Every page also has a Markdown twin (`<url>.md`) that is far easier to read than the rendered page.
Fetch the twins with `curl`, not a browser.

## Outcome of the 2026-10-14 upload — the directory is closed to skills-only

The ZIP uploaded and validated, and the dashboard's **Metadata & Skills** checks returned three
findings, quoted here in full:

1. *"We are not accepting more skills-only submissions at this time."*
2. *"The plugin's name or description references another AI assistant, model, or platform."*
3. *"We couldn't confirm the selected category. Review the category and make sure the listing clearly
   explains the plugin's main purpose."*

Finding 1 is portal policy, not a package defect: nothing in the package can clear it, and it is the
clause the guidelines flag (*"Skills-only plugins may be subject to additional eligibility
requirements for listing in the Directory"*). **The public directory is therefore not a live route
for this plugin**, and no amount of metadata work reopens it. Distribution now runs through the repo
marketplace in `.agents/plugins/marketplace.json` — see `plugin/README.md`.

Findings 2 and 3 are real and would have to be fixed for any future listing:

- **Finding 2** means the listing text cannot name another AI model or platform. Ours names **Google
  Flow** (a platform) and **Veo 3.1** (a model) in `longDescription` and the root `description`, and
  the display name **Flow Story Maker** carries the platform's name. A fixed version needs a
  brand-neutral `displayName`, `shortDescription`, and `longDescription` — describing "a
  video-generation platform and model you already use" instead of naming them — plus a rename of
  `name` and the folder inside the ZIP. The rulebook text itself is instruction content, not listing
  metadata, but the skills' `SKILL.md` descriptions name the same products and would need the same
  treatment if the scan reads skill prose.
- **Finding 3** means the listing has to state the plugin's main purpose plainly and early enough for
  the category to be confirmable. Rewrite the first sentence of both descriptions to lead with the
  job ("plans multi-clip story videos and writes the copy-ready prompt for each clip"), then pick the
  closest category from the dashboard's own list at upload time.

Only the MCP route is open for a public listing, and it is a product change rather than a packaging
one: a new draft with a hosted MCP server **in the initial ZIP** (adding MCP to a skills-only plugin
is not supported), real server-side tools, domain verification at
`https://<host>/.well-known/openai-apps-challenge`, tool annotations, five positive and three
negative test cases in the manifest, and a demo recording. See the section below for the rest.

## Rule of the road

`plugin/flow-story-maker/` must stay **skills-only**. The portal cannot accept a plugin ZIP that
contains an app reference (`.app.json`) or lifecycle hooks (`hooks/`, which makes a package ineligible
for the public directory), and adding an MCP server to an existing skills-only plugin is not
supported. `validate-plugin.sh` fails on all three so this can't be broken by accident.

Skills-only is not a lighter bar for the listing itself. The guidelines are explicit: *"Plugins that
contain only skills must meet all metadata and listing requirements above. Skills-only plugins may be
subject to additional eligibility requirements for listing in the Directory."* The metadata and
listing work below is therefore mandatory, and the last clause is the one open risk that no package
change can close.

## Listing fields live in the manifest

The portal imports listing metadata **from the package** and package fields are read-only in the
dashboard, so every listing field is edited here and re-uploaded as a new ZIP. The four URLs are
`interface` fields — the root `homepage` and `author.url` do **not** fill them:

| Manifest field (`extensions.com.openai.interface`) | Live value |
|---|---|
| `websiteURL` | https://gfs.uft1.com/ |
| `supportURL` | https://gfs.uft1.com/support |
| `privacyPolicyURL` | https://gfs.uft1.com/privacy |
| `termsOfServiceURL` | https://gfs.uft1.com/terms |

All four are declared in `plugin.json` and verified reachable (HTTP 200 on 2026-10-14). Rule that
matters at review time: *"Public URLs must be accessible and identify the same publisher as the
submission"* — the pages name **Jovylle Bermudez** as the developer, which is what makes a
`gfs.uft1.com` URL acceptable under a verification identity.

## Before uploading

- [ ] `./plugin/build-plugin.sh` — rebuilds the pack, syncs the version, refreshes the embedded
      rulebook, writes `plugin/dist/flow-story-maker-<version>.zip`.
- [ ] `./plugin/validate-plugin.sh` — package shape, field limits, listing URLs, icons, skills layout,
      marketplace catalog, freshness. Offline by default.
- [ ] `CHECK_URLS=1 ./plugin/validate-plugin.sh` — same run plus reachability of the four live URLs.
- [ ] `VALIDATE_PLUGIN=1 ./validate.sh` — the full rulebook suite plus the plugin section.

The reported count is the number of *passing* checks, so it shrinks when one failure suppresses a
downstream group (a version mismatch skips the ZIP-content group and reports its own FAIL). Read the
FAIL lines, not the total.

## Portal steps

1. **Identity.** Complete individual or business verification in the organization settings first; the
   directory shows the name attached to that verified developer identity. Only organization owners can
   submit unless they grant *Apps Management Write*.
2. **Upload** `dist/flow-story-maker-<version>.zip` at https://platform.openai.com/plugins. Package
   metadata is read-only in the portal — every metadata change means editing `plugin.json` here and
   re-uploading a new ZIP (same for skills; only hosted MCP changes skip the ZIP).
3. **Resolve automated findings.** *Metadata & Skills* must come back clean, and the required skill
   scans must finish successfully before submitting.
4. **Submit for review** (policy attestations), then choose when to publish once approved. One review
   can be active per plugin; a rejected package is fixed by uploading a corrected ZIP.

## Field limits the validator enforces

`displayName` ≤30 · `shortDescription` ≤30 · `longDescription` ≤4000 · `developerName` ≤80 ·
`capabilities` ≤20×120 · `defaultPrompt` ≤3×128, unique, no app @mentions · the four listing URLs
https and ≤1024 with no embedded credentials · `author.name` ≤120 / `author.url` ≤2048 ·
`homepage`/`repository` ≤2048 · `brandColor` ≥2:1 against white, `brandColorDark` ≥2:1 against
`#212121` · icons square and ≥48×48 (PNG, JPEG, WebP, or SVG, ≤5 MiB, rasters ≤4096 px per side) ·
`name` lowercase letters/numbers/single hyphens, ≤64 chars · no `mcp.json`, `hooks/`, `.app.json`,
`.codex-plugin/`, credentials, or `.DS_Store`.

## Live URLs (verified 2026-10-14)

Live on Cloudflare Pages (project `flow-story-maker`, custom domain `gfs.uft1.com`, source `site/` in
this repo). Redeploy after any `site/` edit:
`npx wrangler pages deploy site --project-name flow-story-maker --branch main`

| Listing field | URL |
|---|---|
| Product website | https://gfs.uft1.com/ |
| Privacy policy | https://gfs.uft1.com/privacy |
| Support | https://gfs.uft1.com/support |
| Terms of service | https://gfs.uft1.com/terms |

## Still needed from you (not in the package)

- [x] ~~The four listing URLs~~ — live, and now declared in `plugin.json`.
- [x] ~~A published privacy policy~~ — https://gfs.uft1.com/privacy states the categories collected
      (none), purposes, recipients, retention, and controls, which is exactly what the guidelines ask
      a policy to carry.
- [x] ~~A primary listing icon~~ — `plugin/dist/icon/flow-story-maker-512.png`, a square 512×512 PNG
      the validator checks; the dashboard also accepts PNG/JPEG/WebP/SVG.
- [ ] **Developer identity verification** — must be completed in the organization settings before the
      panel will accept a submission, and it decides the developer name the directory displays.
- [ ] **Category** — `plugin.json` says `Productivity`. Confirm against the dashboard's own category
      list at upload time and correct it there if a better-fitting title exists.
- [ ] **Country availability** — optional (`publication.countries`); omitting it keeps existing
      targeting, which is what we want until the listing is live.

## What the directory does NOT need for this plugin

No MCP server, no tool scan, no domain verification, no OAuth setup, no review test cases, and no demo
recording — the field reference says plainly that *"skills-only plugins don't need MCP app review cases
or a demo recording."* Skills-only metadata validation also doesn't demand all four URLs, but the
dashboard imports them and flags a missing privacy or support URL, so they are declared anyway. Skills
scans must still finish successfully.

## Two things to keep in mind at review time

- **Appropriateness.** The guidelines hold every plugin to general-audience suitability (13–17). The
  horror-riddle path is narrative horror with no gore mandate, which fits that bar — but if a reviewer
  asks, the honest answer is that it writes a spoken riddle and a consequence, not graphic content.
- **Naming.** The package is `flow-story-maker` and the display name is **Flow Story Maker** — "Google"
  is deliberately kept *out* of the name and subtitle, because published plugins may only use IP the
  publisher owns or has permission to use and must not imply endorsement. Compatibility ("for Google
  Flow and Veo 3.1") stays in the description as ordinary descriptive use. If a fully brand-neutral
  name is wanted later, change `name`, `displayName`, and `shortDescription`, rename the folder inside
  the ZIP to match `name`, and re-zip.
