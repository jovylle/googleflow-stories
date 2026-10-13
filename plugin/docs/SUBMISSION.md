# Submitting the GFS plugin to the ChatGPT directory

Sources (fetched 2026-10-13 — re-read them before submitting, they move):

- Guidelines — https://developers.openai.com/plugins/plugin-guidelines
- Packaging — https://developers.openai.com/plugins/build/plugins
- Submission flow — https://developers.openai.com/plugins/deploy/submission
- Package field reference — same page, "Automatically provide submission and review information"

Every page also has a Markdown twin (`<url>.md`) that is far easier to read than the rendered page.

## Rule of the road

`plugin/flow-story-maker/` must stay **skills-only**. The portal cannot accept a plugin ZIP that
contains an app reference (`.app.json`) or lifecycle hooks (`hooks/`), and adding an MCP server to an
existing skills-only plugin is not supported. `validate-plugin.sh` fails on all three so this can't
be broken by accident.

## Before uploading

- [ ] `./plugin/build-plugin.sh` — rebuilds the pack, syncs the version, refreshes the embedded
      rulebook, writes `plugin/dist/flow-story-maker-<version>.zip`.
- [ ] `./plugin/validate-plugin.sh` — package shape, field limits, icons, skills layout, freshness.
- [ ] `./validate.sh` — the rulebook itself still passes (324 checks + handoff freshness).

## Portal steps

1. **Identity.** Complete individual or business verification in the organization settings first; the
   directory shows the name attached to that verified developer identity. Only organization owners can
   submit unless they grant *Apps Management Write*.
2. **Upload** `dist/flow-story-maker-<version>.zip` at https://platform.openai.com/plugins. Package
   metadata is read-only in the portal — every metadata change means editing `plugin.json` here and
   re-uploading a new ZIP (same for skills).
3. **Resolve automated findings.** *Metadata & Skills* must come back clean, and the required skill
   scans must finish successfully before submitting.
4. **Submit for review**, then choose when to publish once approved.

## Still needed from you (not in the package)

- [ ] **A published privacy policy URL.** Required for submission. It can be short — a skills-only
      plugin collects nothing — but it must state the categories of personal data collected (none),
      the purpose of use, recipients, retention, and user controls.
- [ ] Product website, support page, and terms-of-service URLs if you want them on the listing (the
      dashboard asks for these; skills-only metadata validation does not require all four).
- [ ] **A primary listing icon** — `assets/logo.svg` is in the package, but the dashboard wants an
      icon before submission; PNG/JPEG/WebP/SVG, square, ≥48×48, ≤5 MiB.
- [ ] **Category** — `plugin.json` currently says `Productivity`. Confirm against the dashboard's own
      category list when you upload and correct it there if a better-fitting title exists.
- [ ] **Country availability** and release notes — optional in the manifest
      (`extensions.com.openai.publication`); omit = keep existing targeting.

## Naming decision (deliberate)

The package name is `flow-story-maker` and the display name is **Flow Story Maker** — "Google" is
deliberately kept *out* of the name and the subtitle. The guidelines require that published plugins
only use IP the publisher owns or has permission to use, and that they not imply endorsement. Naming
a plugin after another company's product is the kind of thing review can reject; describing
compatibility in the description ("for Google Flow and Veo 3.1") is ordinary descriptive use and is
kept there. If a fully brand-neutral name is wanted later, change `name`, `displayName`, and the
`shortDescription` in `plugin.json` and re-zip — the folder inside the ZIP must be renamed to match
the `name` field.

## What the directory does NOT need for this plugin

No MCP server, no tool scan, no domain verification, no OAuth setup, no review test cases, and no
demo recording — those apply to plugins with an MCP server. Skills-only plugins still need their
skill scans to pass.
