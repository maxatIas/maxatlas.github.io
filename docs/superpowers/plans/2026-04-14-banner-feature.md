# Banner Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a three-level banner system (frontmatter > page bundle > global static file) that injects a banner image between the nav and `<main>` on any Hugo page.

**Architecture:** A single `banner.html` partial evaluates the priority chain and emits the banner HTML. `baseof.html` calls it in one line. CSS constrains the image to 680px wide and 300px tall without cropping.

**Tech Stack:** Hugo templates (Go template syntax), CSS

**Design spec:** `docs/superpowers/specs/2026-04-14-banner-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `themes/maxatlas/assets/css/main.css` | Modify (line 80) | Add `.site-banner` and `.site-banner__img` styles |
| `themes/maxatlas/layouts/partials/banner.html` | Create | Priority-chain logic + banner HTML |
| `themes/maxatlas/layouts/_default/baseof.html` | Modify (line 7) | Call the banner partial after nav |

---

### Task 1: Add banner CSS

**Files:**
- Modify: `themes/maxatlas/assets/css/main.css` — insert after line 79 (end of `.nav` block, before `/* ── Page wrapper */`)

- [ ] **Step 1: Insert the styles**

Open `themes/maxatlas/assets/css/main.css`. Find the comment `/* ── Page wrapper */` at line 80. Insert the following block immediately before it:

```css
/* ── Site banner ─────────────────────────────────────── */
.site-banner {
  max-width: 680px;
  margin: 0 auto;
  padding: 1rem 1rem 0;
}

.site-banner__img {
  display: block;
  max-width: 100%;
  max-height: 300px;
  width: auto;
  height: auto;
  margin: 0 auto;
}

```

- [ ] **Step 2: Commit**

```bash
git add themes/maxatlas/assets/css/main.css
git commit -m "style: add .site-banner styles"
```

---

### Task 2: Create the banner partial

**Files:**
- Create: `themes/maxatlas/layouts/partials/banner.html`

- [ ] **Step 1: Create the file with priority-chain logic**

Create `themes/maxatlas/layouts/partials/banner.html` with the following content:

```html
{{- $bannerURL := "" -}}
{{- $bannerDest := "" -}}

{{- if .Params.banner -}}
  {{- $bannerURL = .Params.banner -}}
  {{- $bannerDest = .Params.banner_dest | default "" -}}
{{- else -}}
  {{- $bundleBanner := .Resources.GetMatch "banner.*" -}}
  {{- if $bundleBanner -}}
    {{- $bannerURL = $bundleBanner.RelPermalink -}}
  {{- else -}}
    {{- range slice "avif" "webp" "jpg" "jpeg" "png" -}}
      {{- if and (not $bannerURL) (os.FileExists (printf "static/img/banner.%s" .)) -}}
        {{- $bannerURL = printf "/img/banner.%s" . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- if $bannerURL -}}
<div class="site-banner">
  {{- if $bannerDest }}
  <a href="{{ $bannerDest }}" target="_blank" rel="noopener">
  {{- end }}
  <img src="{{ $bannerURL }}" alt="Banner" class="site-banner__img">
  {{- if $bannerDest }}
  </a>
  {{- end }}
</div>
{{- end -}}
```

- [ ] **Step 2: Commit**

```bash
git add themes/maxatlas/layouts/partials/banner.html
git commit -m "feat: add banner.html partial with 3-level priority chain"
```

---

### Task 3: Wire banner partial into baseof.html

**Files:**
- Modify: `themes/maxatlas/layouts/_default/baseof.html`

Current content:
```html
<body>
  {{ partial "nav.html" . }}
  <main>
    {{ block "main" . }}{{ end }}
  </main>
</body>
```

- [ ] **Step 1: Add the partial call**

Replace the `<body>` block so it reads:

```html
<body>
  {{ partial "nav.html" . }}
  {{ partial "banner.html" . }}
  <main>
    {{ block "main" . }}{{ end }}
  </main>
</body>
```

- [ ] **Step 2: Commit**

```bash
git add themes/maxatlas/layouts/_default/baseof.html
git commit -m "feat: call banner partial in baseof.html"
```

---

### Task 4: Verify — global static banner (priority 3)

`static/img/banner.avif` already exists in the repo, so priority 3 fires on every page with no extra setup.

- [ ] **Step 1: Start the dev server**

```bash
hugo server --buildDrafts --buildFuture
```

Open `http://localhost:1313/` in a browser.

- [ ] **Step 2: Check the homepage**

Expected: the banner image appears between the nav bar and the post list, centered, no taller than 300px, not cropped.

- [ ] **Step 3: Check a post page**

Navigate to any post. Expected: same banner appears between nav and article content.

- [ ] **Step 4: Stop the dev server** (`Ctrl+C`)

---

### Task 5: Verify — frontmatter banner with click destination (priority 1)

- [ ] **Step 1: Add frontmatter to an existing post**

Pick any post (e.g. the most recent one under `content/posts/`). Add to its frontmatter:

```yaml
banner: "/img/banner.avif"
banner_dest: "https://example.com"
```

- [ ] **Step 2: Start the dev server and open that post**

```bash
hugo server --buildDrafts --buildFuture
```

Expected: the banner appears, and clicking it opens `https://example.com` in a new tab.

- [ ] **Step 3: Verify priority over static**

The banner shown should be the one specified in frontmatter (same file here, but the `<a>` wrapper proves the frontmatter path was taken — inspect the HTML to confirm `<a href="https://example.com">`).

- [ ] **Step 4: Remove the test frontmatter fields**

Remove `banner:` and `banner_dest:` from the post you edited. Confirm the global banner reappears (no link wrapper).

- [ ] **Step 5: Stop the dev server** (`Ctrl+C`)

---

### Task 6: Verify — page bundle banner on the homepage (priority 2)

This task creates `content/_index.md` to enable a homepage-specific banner that can override the global one. **Skip this task if you do not need a homepage-specific banner distinct from the global one.**

- [ ] **Step 1: Create content/_index.md**

```bash
cat > content/_index.md << 'EOF'
---
title: "Home"
---
EOF
```

- [ ] **Step 2: Copy a banner image into the content/ directory**

```bash
cp static/img/banner.avif content/banner.avif
```

(Use any image you want to appear only on the homepage.)

- [ ] **Step 3: Start the dev server**

```bash
hugo server --buildDrafts --buildFuture
```

- [ ] **Step 4: Verify homepage shows the bundle banner**

Open `http://localhost:1313/`. Expected: the `content/banner.avif` is used (priority 2 wins over static). Since it's the same file here, navigate to a post to confirm the global `static/img/banner.avif` still shows there.

- [ ] **Step 5: Stop the dev server** (`Ctrl+C`)

- [ ] **Step 6: Commit if keeping _index.md**

If you want `content/_index.md` to stay, commit it (with or without the bundle banner):

```bash
git add content/_index.md content/banner.avif   # adjust if no bundle image
git commit -m "feat: add homepage _index.md for bundle banner support"
```

Otherwise revert:

```bash
git checkout -- content/
rm -f content/_index.md content/banner.avif
```
