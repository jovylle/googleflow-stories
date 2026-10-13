# GFS ChatGPT plugin — package source

The public ChatGPT/Codex plugin for the Google Flow Story Maker rulebook. This folder is the
**package source**; the rulebook still lives in `../modules/` and is never edited here.

```
plugin/
├── flow-story-maker/                 # the plugin package (this is what gets zipped)
│   ├── plugin.json                   # portable Agent Plugins manifest, version synced from version.txt
│   ├── assets/                       # logo + composer icon (square SVG)
│   └── skills/
│       ├── flow-story-maker/         # the workflow skill
│       │   ├── SKILL.md              # router: triggers, workflow, boundaries
│       │   └── references/
│       │       └── gfs-instructions.md   # GENERATED copy of the compiled rulebook
│       └── get-started/SKILL.md      # onboarding skill (manifest onboardingSkill)
├── build-plugin.sh                   # modules → rulebook copy → version stamp → ZIP
├── validate-plugin.sh                # package/limit/icon/freshness/secret checks
├── dist/                             # generated ZIPs (upload these)
└── docs/SUBMISSION.md                # what the portal still needs from you
```

It is a **skills-only** plugin: no MCP server, no server URL, no auth, no data collection. That
matters beyond today's scope — adding an MCP server to an existing skills-only plugin is not
supported, so if an MCP-backed version is ever wanted it has to be a second plugin.

## Build and validate

```bash
./plugin/build-plugin.sh      # rebuilds the pack, syncs the version, refreshes the copy, writes dist/*.zip
./plugin/validate-plugin.sh   # must pass before any upload
```

`build-plugin.sh` runs the repo's own `./build.sh` first, so the plugin copy can never drift from the
modules. It stamps the plugin's `version` from `version.txt`: **the pack version and the plugin
version move together** — one bump releases both.

`validate-plugin.sh` checks the packaged manifest against the published field limits (display name
30, subtitle 30, description 4000, prompts ≤3×128, capabilities ≤20×120), the icon rules (square SVG
≥48×48), the skills layout (`SKILL.md` name == directory), the skills-only boundary (no `mcp.json`,
`hooks/`, `.app.json`, `.codex-plugin/`), brand-colour contrast, embedded-rulebook freshness, secret
hygiene, and the ZIP's contents.

## Publishing

**Live at https://gfs.uft1.com** (source: `site/`, Cloudflare Pages project `flow-story-maker`;
privacy at `/privacy`, support at `/support`, terms at `/terms` — the four URLs the directory asks for).

See `docs/SUBMISSION.md` for the portal checklist and the items that are still on you (developer
verification, the dashboard's primary icon, country targeting). Short version: run both scripts,
upload `dist/flow-story-maker-<version>.zip` at platform.openai.com/plugins, resolve the automated
findings, submit for review, then choose when to publish.
