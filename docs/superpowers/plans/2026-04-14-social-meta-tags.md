# Social Media Meta Tags Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Open Graph and Twitter Card meta tags to every page of the maxatlas Hugo site for rich social media previews.

**Architecture:** A dedicated `og.html` partial handles all OG/Twitter tag logic and is included from `head.html`. Image resolution: Page Bundle cover first, then static fallback. Description resolution: frontmatter `.Description` → `.Summary` → site global.

**Tech Stack:** Hugo extended 0.160.1, Go templates, AVIF image

---

### Task 1: Add the default fallback image

**Files:**
- Create: `static/og-default.avif`

- [ ] **Step 1: Place the fallback image**

  Copy or create a 1200×630 px image at `static/og-default.avif`. This image is shown whenever a page has no Page Bundle cover (home, about, tag/series list pages).

  If you don't have one ready, create a minimal placeholder with ImageMagick:

  ```bash
  magick -size 1200x630 xc:#0a0a0f -fill '#00fff7' \
    -font JetBrains-Mono-Bold -pointsize 64 \
    -gravity Center -annotate 0 'MaxAtlas' \
    static/og-default.avif
  ```

- [ ] **Step 2: Verify the file exists**

  ```bash
  ls -lh static/og-default.avif
  ```

  Expected: file present, size > 0.

- [ ] **Step 3: Commit**

  ```bash
  git add static/og-default.avif
  git commit -m "feat: add default OG fallback image"
  ```

---

### Task 2: Create the og.html partial

**Files:**
- Create: `themes/maxatlas/layouts/partials/og.html`

- [ ] **Step 1: Create the partial with the full OG + Twitter Card logic**

  Create `themes/maxatlas/layouts/partials/og.html` with the following content:

  ```html
  {{- $img := "og-default.avif" | absURL -}}
  {{- $cover := .Resources.GetMatch "cover.*" -}}
  {{- if $cover -}}
    {{- $img = $cover.Permalink -}}
  {{- end -}}

  {{- $desc := site.Params.description -}}
  {{- if .Summary -}}
    {{- $desc = .Summary -}}
  {{- end -}}
  {{- if .Description -}}
    {{- $desc = .Description -}}
  {{- end -}}

  {{- $type := "website" -}}
  {{- if and .IsPage (eq .Section "posts") -}}
    {{- $type = "article" -}}
  {{- end -}}

  <!-- Open Graph -->
  <meta property="og:title" content="{{ .Title }}">
  <meta property="og:description" content="{{ $desc }}">
  <meta property="og:type" content="{{ $type }}">
  <meta property="og:url" content="{{ .Permalink }}">
  <meta property="og:image" content="{{ $img }}">
  <meta property="og:site_name" content="{{ site.Title }}">
  {{- if eq $type "article" }}
  <meta property="article:published_time" content="{{ .Date.Format "2006-01-02T15:04:05Z07:00" }}">
  {{- range .Params.tags }}
  <meta property="article:tag" content="{{ . }}">
  {{- end }}
  {{- end }}

  <!-- Twitter Cards -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{{ .Title }}">
  <meta name="twitter:description" content="{{ $desc }}">
  <meta name="twitter:image" content="{{ $img }}">
  ```

- [ ] **Step 2: Build the site to verify no template errors**

  ```bash
  hugo --gc 2>&1 | head -30
  ```

  Expected: build completes with `0 errors`.

- [ ] **Step 3: Commit**

  ```bash
  git add themes/maxatlas/layouts/partials/og.html
  git commit -m "feat: add og.html partial for social meta tags"
  ```

---

### Task 3: Wire og.html into head.html

**Files:**
- Modify: `themes/maxatlas/layouts/partials/head.html`

Current content of `head.html`:

```html
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} · {{ site.Title }}{{ end }}</title>
<meta name="description" content="{{ with .Description }}{{ . }}{{ else }}{{ site.Params.description }}{{ end }}">
{{ $css := resources.Get "css/main.css" | minify }}
<link rel="stylesheet" href="{{ $css.RelPermalink }}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
```

- [ ] **Step 1: Add the og.html partial call after the description meta tag**

  Replace the contents of `themes/maxatlas/layouts/partials/head.html` with:

  ```html
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ if .IsHome }}{{ site.Title }}{{ else }}{{ .Title }} · {{ site.Title }}{{ end }}</title>
  <meta name="description" content="{{ with .Description }}{{ . }}{{ else }}{{ site.Params.description }}{{ end }}">
  {{ partial "og.html" . }}
  {{ $css := resources.Get "css/main.css" | minify }}
  <link rel="stylesheet" href="{{ $css.RelPermalink }}">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
  ```

- [ ] **Step 2: Build the site**

  ```bash
  hugo --gc 2>&1 | head -30
  ```

  Expected: `0 errors`.

- [ ] **Step 3: Commit**

  ```bash
  git add themes/maxatlas/layouts/partials/head.html
  git commit -m "feat: include og.html partial in head"
  ```

---

### Task 4: Verify generated HTML

**Files:** (read-only verification)
- `public/index.html` — home page
- `public/posts/2026/2026-04-06-astronight-gameplay/index.html` — post with cover + tags + series

- [ ] **Step 1: Build the site**

  ```bash
  hugo --gc 2>&1 | tail -5
  ```

  Expected: `Total in X ms`, `0 errors`.

- [ ] **Step 2: Check home page — fallback image and website type**

  ```bash
  grep -E 'og:|twitter:' public/index.html
  ```

  Expected output includes:
  ```
  og:title … MaxAtlas
  og:type … website
  og:image … https://maxatlas.github.io/og-default.avif
  twitter:card … summary_large_image
  ```

- [ ] **Step 3: Check a post — cover image, article type, tags**

  ```bash
  grep -E 'og:|twitter:|article:' public/posts/2026/2026-04-06-astronight-gameplay/index.html
  ```

  Expected output includes:
  ```
  og:type … article
  og:image … https://maxatlas.github.io/posts/2026/2026-04-06-astronight-gameplay/cover.avif
  article:published_time … 2026-04-06
  article:tag … game
  article:tag … unity
  twitter:card … summary_large_image
  ```

- [ ] **Step 4: Check a series list page — fallback image and website type**

  ```bash
  grep -E 'og:|twitter:' public/series/astronight/index.html
  ```

  Expected: `og:type … website`, `og:image … og-default.avif`.

- [ ] **Step 5: Commit verification note (no code change — skip if no adjustments needed)**

  If any output didn't match expectations, fix `og.html` and re-run steps 1–4 before committing.
