<!--
REFERENCE ONLY — NOT A BUILD MODULE.
This file lives in docs/ (not modules/) so build.sh never concatenates it into
the ChatGPT instructions. It documents ChatGPT's interactive UI component system
(GenUI / "DIL" apps) for our own reference when authoring button-based UI.
-->

# Interactive ChatGPT Responses: Basic Docs & Cheatsheet

> **Captured:** 2026-10-10
> **Last verified:** 2026-10-10
> **Status:** ⚠️ Time-sensitive. This describes an evolving ChatGPT surface
> (interactive GenUI components). Component names, props, hooks, and action APIs
> **can change without notice** and **vary by ChatGPT surface** (web, mobile,
> plain chat, apps). Re-verify against a live surface before relying on anything
> here. If the "Last verified" date above is more than a few weeks old, treat
> this document as potentially outdated.
> **Source:** User-provided cheatsheet (pasted from an interactive-components session).

---

A practical guide to composing ChatGPT responses with interactive UI components such as buttons, inputs, radio groups, tabs, checkboxes, and expandable sections.

## 1. The mental model

A response can combine:
- **Markdown** for normal text, lists, tables, and code.
- **UI components** for layout, inputs, and actions.
- **State** when a control changes what is displayed.
- **Callbacks** to react to user interaction.

Use interactive controls only when they do something useful. A decorative button or input with no behavior is usually a bad UI.

## 2. Basic syntax

### Text and headings

```md
# Main heading
## Section heading

**Bold** and *italic*
- List item
1. Numbered item
```

### Layout

```jsx
<row gap={3} align="center">
  <icon name="settings" size="lg" />
  **Settings**
</row>

<col gap={3}>
  First section
  Second section
</col>

<box padding={4} border radius="lg" gap={2}>
  Content inside a bordered container
</box>
```

Common layout components:
- `<row>`: arrange content horizontally.
- `<col>`: arrange content vertically.
- `<box>`: general-purpose container.
- `<grid>`: grid layout.
- `<divider />`: visual separator.
- `<spacer />`: add flexible space.

Shared layout props often include `gap`, `padding`, `align`, `justify`, `width`, `background`, `border`, and `radius`.

## 3. Inputs

### Text input

```jsx
{@body const [name, setName] = DIL.useState("")}

<col gap={2}>
  <label>Project name</label>
  <input
    value={name}
    onChange={setName}
    placeholder="e.g. Video Studio"
  />
  <text>Current value: {name || "Not entered"}</text>
</col>
```

### Text area

```jsx
{@body const [notes, setNotes] = DIL.useState("")}

<textarea
  value={notes}
  onChange={setNotes}
  placeholder="Add details..."
  rows={4}
/>
```

### Radio group

```jsx
{@body const [format, setFormat] = DIL.useState("vlog")}

<radio-group value={format} onChange={setFormat} direction="col" label="Video type">
  <radio value="vlog">Vlog</radio>
  <radio value="ad">Product advertisement</radio>
  <radio value="story">Short story</radio>
</radio-group>

<text>Selected: {format}</text>
```

### Select dropdown

```jsx
{@body const [quality, setQuality] = DIL.useState("standard")}

<select
  value={quality}
  onChange={setQuality}
  options={[
    { label: "Draft", value: "draft" },
    { label: "Standard", value: "standard" },
    { label: "High quality", value: "high" }
  ]}
/>
```

### Checkbox

```jsx
{@body const [captions, setCaptions] = DIL.useState(false)}

<checkbox checked={captions} onChange={setCaptions}>
  Include captions
</checkbox>
```

### Segmented control (compact tabs/options)

```jsx
{@body const [step, setStep] = DIL.useState("basics")}

<segmented-control
  value={step}
  onChange={setStep}
  options={[
    { label: "Basics", value: "basics" },
    { label: "Script", value: "script" },
    { label: "Style", value: "style" }
  ]}
/>
```

## 4. Buttons and actions

### Button updates the response

```jsx
{@body const [showDetails, setShowDetails] = DIL.useState(false)}

<button onClick={() => setShowDetails(!showDetails)}>
  {showDetails ? "Hide details" : "Show details"}
</button>

{#if showDetails}
  Here are the additional details.
{/if}
```

### Copy text

```jsx
<button onClick={() => GenUI.copy("Text to copy")}>
  Copy text
</button>
```

### Open a URL

```jsx
<button onClick={() => GenUI.openUrl("https://example.com")}>
  Open website
</button>
```

### Send a follow-up message

```jsx
<button onClick={() => GenUI.issueNewTurn("Continue with the selected configuration.")}>
  Continue
</button>
```

Only claim an action succeeded after the host reports its result. Direct host actions should be called from a real user interaction.

## 5. Accordion / expandable sections

There is no dedicated accordion tag in the basic component set. Build one with state, a button, and a conditional section.

```jsx
{@body const [openSection, setOpenSection] = DIL.useState("none")}

<col gap={2}>
  <box border radius="lg" padding={3} gap={2}>
    <button block variant="ghost" onClick={() => setOpenSection(openSection === "overview" ? "none" : "overview")}>
      {openSection === "overview" ? "▾" : "▸"} Overview
    </button>
    {#if openSection === "overview"}
      Summary information goes here.
    {/if}
  </box>

  <box border radius="lg" padding={3} gap={2}>
    <button block variant="ghost" onClick={() => setOpenSection(openSection === "details" ? "none" : "details")}>
      {openSection === "details" ? "▾" : "▸"} Details
    </button>
    {#if openSection === "details"}
      Longer details go here. This can contain text, lists, or other components.
    {/if}
  </box>
</col>
```

This version allows one section open at a time. For independent sections, use a separate boolean state variable for each section.

## 6. Multi-step wizard

Keep the same form state while changing which step is visible.

```jsx
{@body
const [step, setStep] = DIL.useState(0);
const [topic, setTopic] = DIL.useState("");
const [style, setStyle] = DIL.useState("natural");
}

<text>Step {step + 1} of 2</text>

{#if step === 0}
  <title size="lg">1. Basics</title>
  <input value={topic} onChange={setTopic} placeholder="What is the video about?" />
{:else}
  <title size="lg">2. Style</title>
  <radio-group value={style} onChange={setStyle} direction="col" label="Visual style">
    <radio value="natural">Natural / realistic</radio>
    <radio value="clay">Clay animation</radio>
    <radio value="paper">Paper diorama</radio>
  </radio-group>
{/if}

<row gap={2}>
  <button disabled={step === 0} onClick={() => setStep(step - 1)}>Back</button>
  {#if step < 1}
    <button onClick={() => setStep(step + 1)}>Next</button>
  {:else}
    <button onClick={() => GenUI.issueNewTurn("Create a video plan. Topic: " + topic + ". Style: " + style + ".")}>Create plan</button>
  {/if}
</row>
```

For a production-quality wizard, also consider required-field validation, clear progress, a review step, and preserving state when navigating backward.

## 7. Conditional fields

Show an extra field only when it applies.

```jsx
{@body
const [scriptMode, setScriptMode] = DIL.useState("custom");
const [script, setScript] = DIL.useState("");
}

<radio-group value={scriptMode} onChange={setScriptMode} label="Script source">
  <radio value="custom">Use my script</radio>
  <radio value="generate">Generate a script</radio>
</radio-group>

{#if scriptMode === "custom"}
  <textarea value={script} onChange={setScript} placeholder="Paste your script..." rows={4} />
{/if}
```

## 8. Displaying structured content

### Table

```jsx
<table>
  <table-row>
    <table-cell header>Feature</table-cell>
    <table-cell header>Status</table-cell>
  </table-row>
  <table-row>
    <table-cell>Radio groups</table-cell>
    <table-cell>Supported</table-cell>
  </table-row>
</table>
```

### Cards

```jsx
<grid columns={2} gap={3}>
  <grid-item>
    <box border radius="lg" padding={3} gap={2}>
      <icon name="file-text" size="xl" />
      **Draft**
      <text>Initial version</text>
    </box>
  </grid-item>
  <grid-item>
    <box border radius="lg" padding={3} gap={2}>
      <icon name="check-circle" size="xl" />
      **Ready**
      <text>Reviewed version</text>
    </box>
  </grid-item>
</grid>
```

## 9. State and control rules

- Declare hooks inside one top-level `{@body ...}` block, before the UI that uses them.
- Use `DIL.useState(initialValue)` for values that change.
- Controlled inputs use `value={state}` and `onChange={setState}`.
- Checkboxes use `checked={state}` and `onChange={setState}`.
- A callback receives the **new value**, not a DOM event.
- Use `{#if condition} ... {:else} ... {/if}` for conditional UI.
- Use `{#each items as item} ... {/each}` to repeat UI for data.
- Keep hook order stable. Do not call hooks inside loops, conditions, or callbacks.
- Use `key` when repeated items need stable identity.
- Keep state in the response when controls need to coordinate or preserve choices.

## 10. Useful component reference

| Component | Purpose |
|---|---|
| `button` | Trigger an action |
| `input` | Single-line input |
| `textarea` | Multi-line input |
| `radio-group`, `radio` | Choose one option |
| `checkbox` | Toggle a boolean |
| `select` | Dropdown |
| `segmented-control` | Compact option switcher or tabs |
| `slider` | Numeric range |
| `date-picker` | Date selection |
| `form` | Group inputs and handle submit |
| `popover` | Small contextual popup |
| `pressable` | Clickable surface |
| `row`, `col`, `box`, `grid` | Layout |
| `table` | Structured data |
| `icon` | Icon |
| `badge` | Compact status label |
| `Chart` | Chart visualization |
| `AsyncImage` | Image |
| `MapWidgetV2` | Interactive map |

## 11. Important limitations

- This is a component-authoring format for ChatGPT responses, not ordinary HTML or React. Tags such as `<button>` here are not browser DOM elements.
- Only supported components, props, hooks, and actions are available. Do not assume arbitrary HTML, CSS, React packages, browser APIs, network calls, or local storage will work.
- A response cannot create a persistent website by itself. For a full app with routes, backend logic, durable storage, and deployment, use an app-building workflow.
- A Markdown code block containing component syntax is only an example. It becomes interactive only when authored as live UI, not when displayed as quoted code.
- Component support and rendering behavior can vary by ChatGPT surface.

## 12. Practical design checklist

- [ ] Use normal Markdown unless interaction adds value.
- [ ] Label every input clearly.
- [ ] Give every button a real action.
- [ ] Show progress in multi-step forms.
- [ ] Preserve selections when moving backward.
- [ ] Validate required fields before continuing.
- [ ] Keep long content collapsed by default when it would overwhelm the response.
- [ ] Make the selected state and next step obvious.
- [ ] Include a summary before sending or generating a final result.
