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

`validate-plugin.sh` checks the packaged manifest against the published field limits (display name 30,
subtitle 30, long description 4000, developer name 80, prompts ≤3×128 and unique, capabilities
≤20×120, `author` and URL length caps), the four listing URLs (https, ≤1024, no embedded credentials),
the icon rules (square ≥48×48, supported formats, ≤5 MiB — including the dashboard's 512px PNG), the
skills layout (`SKILL.md` name == directory), the skills-only boundary (no `mcp.json`, `hooks/`,
`.app.json`, `.codex-plugin/`), brand-colour contrast, embedded-rulebook freshness, secret hygiene, and
the ZIP's contents. Add `CHECK_URLS=1` to also fetch the four listing URLs and assert HTTP 200; that
one needs the network, the default run stays offline. The reported count is the number of *passing*
checks and shrinks when a failure suppresses a downstream group (a version mismatch skips the
ZIP-content group), so read the FAIL lines, not the total.

## Distribution

**Repo marketplace — how it installs today.** `$REPO_ROOT/.agents/plugins/marketplace.json` is a
one-entry catalog pointing at `./plugin/flow-story-maker`. Anyone with the ChatGPT desktop app (or
Codex CLI) installs the plugin with:

```bash
codex plugin marketplace add jovylle/googleflow-stories --ref dev
```

then restarts the desktop app, opens the **Plugins Directory**, picks the **Flow Story Maker
Plugins** marketplace and installs **Flow Story Maker**. Do not add `--sparse` — `source.path` is
resolved from the marketplace root (the repo root), so a sparse checkout of `.agents/plugins` alone
would leave the plugin folder behind. The host copies the package into
`~/.codex/plugins/cache/<marketplace>/<plugin>/local/`, so after editing the package, reinstall or
refresh and restart the app; `--ref dev` is required until the branch carrying the plugin reaches the
default branch. `validate-plugin.sh` checks the catalog (entry shape, `policy.*`, `category`, a
`source.path` that resolves to a packaged `plugin.json` inside the root, name parity with the
manifest) so a broken entry cannot ship quietly.

**Website** — https://gfs.uft1.com (source: `site/`, Cloudflare Pages project `flow-story-maker`;
privacy at `/privacy`, support at `/support`, terms at `/terms`). Redeploy after any `site/` edit:
`npx wrangler pages deploy site --project-name flow-story-maker --branch main`.

## The public plugin directory (currently closed to skills-only)

The package is submission-ready, but **OpenAI is not accepting skills-only submissions at this
time** — a portal policy, not a package defect, and the reason the listing is not live. Two metadata
findings from that upload also stay open until a listing is possible: the listing must not name
another AI model or platform (ours names Google Flow and Veo 3.1, and the display name carries
"Flow"), and the category must be confirmable from the listing text. `docs/SUBMISSION.md` records all
three findings verbatim and what each one would require.
