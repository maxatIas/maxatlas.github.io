# maxatlas Hugo Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a cyberpunk-themed Hugo static site with custom theme `maxatlas`, featuring a blog with series support, deployed to GitHub Pages.

**Architecture:** Custom Hugo theme with vanilla CSS (no JS framework), taxonomy-based series, Page Bundle cover auto-detection, single `main.css` driven by CSS custom properties. No comments, no search, dark-only.

**Tech Stack:** Hugo (latest extended), vanilla CSS with custom properties, Go HTML templates, GitHub Actions.

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `hugo.toml` | Create | Site config, taxonomies |
| `themes/maxatlas/theme.toml` | Create | Theme metadata |
| `themes/maxatlas/assets/css/main.css` | Create | All styles (tokens + components) |
| `themes/maxatlas/layouts/_default/baseof.html` | Create | Base HTML shell |
| `themes/maxatlas/layouts/partials/head.html` | Create | `<head>` + CSS + fonts |
| `themes/maxatlas/layouts/partials/nav.html` | Create | Top navigation bar |
| `themes/maxatlas/layouts/partials/post-card.html` | Create | Reusable article card |
| `themes/maxatlas/layouts/_default/list.html` | Create | Homepage + /posts/ list |
| `themes/maxatlas/layouts/_default/single.html` | Create | Article page |
| `themes/maxatlas/layouts/shortcodes/video.html` | Create | WebM embed shortcode |
| `themes/maxatlas/layouts/series/list.html` | Create | /series/ taxonomy list |
| `themes/maxatlas/layouts/series/term.html` | Create | /series/<name>/ term page |
| `content/about/index.md` | Create | About page content |
| `content/series/astronight/_index.md` | Create | AstroNight series metadata |
| `content/series/timelapse/_index.md` | Create | Timelapse series metadata |
| `content/posts/astronight-ep1/index.md` | Create | Sample post with series |
| `content/posts/astronight-ep2/index.md` | Create | Sample post (series nav test) |
| `content/posts/timelapse-ep1/index.md` | Create | Sample post (second series) |
| `content/posts/rust-lifetimes/index.md` | Create | Sample standalone post |
| `.github/workflows/static.yml` | Modify | Hugo build + deploy |
| `index.html` | Delete | Legacy file |
| `style.css` | Delete | Legacy file |
| `.gitignore` | Modify | Add public/, resources/ |

---

### Task 1: Initialize Hugo project

**Files:**
- Create: `hugo.toml`, `themes/maxatlas/theme.toml`, `themes/maxatlas/layouts/_default/baseof.html` (stub)
- Create: `content/about/index.md`
- Delete: `index.html`, `style.css`
- Modify: `.gitignore`

- [ ] **Step 1: Install Hugo and verify**

```bash
brew install hugo
hugo version
```
Expected: `hugo v0.X.X+extended ...` (version 0.110 or newer).

- [ ] **Step 2: Create directory structure**

```bash
mkdir -p themes/maxatlas/layouts/{_default,series,shortcodes,partials}
mkdir -p themes/maxatlas/assets/css
mkdir -p themes/maxatlas/static
mkdir -p content/{posts,series,about}
```

- [ ] **Step 3: Create `hugo.toml`**

```toml
baseURL = "https://maxatlas.github.io/"
languageCode = "en-us"
title = "MaxAtlas"
theme = "maxatlas"

[taxonomies]
  series = "series"
  tag = "tags"

[params]
  description = "Dev articles with a gaming soul"

[pagination]
  pagerSize = 10
```

- [ ] **Step 4: Create `themes/maxatlas/theme.toml`**

```toml
name = "maxatlas"
```

- [ ] **Step 5: Create stub `baseof.html` to unblock build**

`themes/maxatlas/layouts/_default/baseof.html`:
```html
<!DOCTYPE html>
<html lang="{{ site.LanguageCode }}">
<head><meta charset="UTF-8"><title>{{ .Title }}</title></head>
<body>{{ block "main" . }}{{ end }}</body>
</html>
```

- [ ] **Step 6: Create About page**

`content/about/index.md`:
```markdown
---
title: "About"
---

Max Pilato — developer and gamer.
```

- [ ] **Step 7: Remove legacy files and update `.gitignore`**

```bash
git rm index.html style.css
```

Add to `.gitignore`:
```
public/
resources/
.hugo_build.lock
```

- [ ] **Step 8: Verify Hugo builds**

```bash
hugo
```
Expected: outputs `| EN` stats table, no errors, `public/` created.

- [ ] **Step 9: Commit**

```bash
git add hugo.toml themes/ content/ .gitignore
git commit -m "feat: initialize Hugo project with maxatlas theme skeleton"
```

---

### Task 2: CSS Foundation

**Files:**
- Create: `themes/maxatlas/assets/css/main.css`

- [ ] **Step 1: Create `main.css`**

`themes/maxatlas/assets/css/main.css`:
```css
/* ── Design tokens ──────────────────────────────────── */
:root {
  --bg-base:        #0d0d1a;
  --bg-surface:     #111128;
  --bg-nav:         #080810;
  --accent-cyan:    #00ffff;
  --accent-magenta: #ff00ff;
  --accent-purple:  #7b2fff;
  --text-primary:   #e2e8f0;
  --text-muted:     #64748b;
  --border:         #1a2a3a;
  --code-text:      #39ff14;
  --code-bg:        #050505;

  --glow-cyan:    0 0 10px rgba(0, 255, 255, 0.4);
  --glow-magenta: 0 0 10px rgba(255, 0, 255, 0.4);

  --transition-card:  transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
  --transition-cover: transform 0.3s ease;
}

/* ── Reset ───────────────────────────────────────────── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

/* ── Base ────────────────────────────────────────────── */
html { font-size: 16px; }

body {
  background: var(--bg-base);
  color: var(--text-primary);
  font-family: system-ui, sans-serif;
  font-size: 0.9375rem;
  line-height: 1.7;
  min-height: 100vh;
}

a { color: var(--accent-cyan); text-decoration: none; }
a:hover { color: var(--accent-magenta); }

/* ── Nav ─────────────────────────────────────────────── */
.nav {
  background: var(--bg-nav);
  border-bottom: 1px solid rgba(0, 255, 255, 0.13);
  padding: 0.625rem 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav__logo {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--accent-cyan);
  text-shadow: var(--glow-cyan);
  letter-spacing: 0.125rem;
}

.nav__links {
  display: flex;
  gap: 1.25rem;
  list-style: none;
}

.nav__links a {
  font-family: monospace;
  font-size: 0.6875rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.0625rem;
  transition: color 0.15s ease;
}

.nav__links a:hover,
.nav__links a[aria-current="page"] { color: var(--accent-cyan); }

/* ── Page wrapper ────────────────────────────────────── */
.page { max-width: 680px; margin: 0 auto; padding: 1.5rem 1rem; }

/* ── Tags ────────────────────────────────────────────── */
.tag {
  display: inline-block;
  font-family: monospace;
  font-size: 0.5625rem;
  text-transform: uppercase;
  letter-spacing: 0.0625rem;
  padding: 0.125rem 0.4375rem;
  border-radius: 2px;
}

.tag--series {
  background: #1a0020;
  color: var(--accent-magenta);
  border: 1px solid rgba(255, 0, 255, 0.27);
}

.tag--regular {
  background: #001a1a;
  color: var(--accent-cyan);
  border: 1px solid rgba(0, 255, 255, 0.27);
}

/* ── Post card ───────────────────────────────────────── */
.post-list {
  display: flex;
  flex-direction: column;
  gap: 0.875rem;
}

.post-card {
  display: flex;
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-radius: 6px;
  overflow: hidden;
  cursor: pointer;
  transition: var(--transition-card);
  text-decoration: none;
  color: inherit;
}

.post-card--series     { border-left: 3px solid var(--accent-magenta); }
.post-card--standalone { border-left: 3px solid var(--accent-cyan); }

.post-card:hover {
  transform: translateY(-2px) scale(1.01);
  box-shadow: 0 6px 24px rgba(0, 255, 255, 0.12);
  border-color: rgba(0, 255, 255, 0.27);
}

.post-card__cover {
  width: 130px;
  min-height: 90px;
  flex-shrink: 0;
  position: relative;
  overflow: hidden;
  border-right: 1px solid var(--border);
}

.post-card__cover--empty {
  background-color: #080812;
  background-image:
    linear-gradient(#0a0a18 1px, transparent 1px),
    linear-gradient(90deg, #0a0a18 1px, transparent 1px);
  background-size: 16px 16px;
}

.post-card__cover-img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: var(--transition-cover);
}

.post-card:hover .post-card__cover-img { transform: scale(1.08); }

.post-card__body {
  padding: 0.625rem 0.75rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.post-card__date    { font-family: monospace; font-size: 0.5625rem; color: var(--text-muted); }
.post-card__title   { font-size: 0.75rem; font-weight: 700; color: var(--text-primary); line-height: 1.4; }
.post-card__excerpt { font-size: 0.5625rem; color: var(--text-muted); line-height: 1.4; flex: 1; }
.post-card__tags    { display: flex; flex-wrap: wrap; gap: 0.3125rem; margin-top: 0.25rem; }

/* ── Pagination ──────────────────────────────────────── */
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 0;
  font-family: monospace;
  font-size: 0.625rem;
  color: var(--text-muted);
  border-top: 1px solid var(--border);
  margin-top: 1rem;
}

.pagination a { color: var(--accent-cyan); }
.pagination .pagination__current { color: var(--text-primary); }

/* ── Article cover ───────────────────────────────────── */
.article__cover {
  width: 100%;
  aspect-ratio: 16 / 6;
  position: relative;
  overflow: hidden;
}

.article__cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.article__cover-scanlines {
  position: absolute;
  inset: 0;
  background: repeating-linear-gradient(
    0deg,
    transparent,
    transparent 3px,
    rgba(0, 0, 0, 0.18) 3px,
    rgba(0, 0, 0, 0.18) 4px
  );
  pointer-events: none;
}

/* ── Article header ──────────────────────────────────── */
.article__title {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--accent-cyan);
  text-shadow: var(--glow-cyan);
  line-height: 1.3;
  margin-bottom: 0.375rem;
  margin-top: 1.25rem;
}

.article__meta {
  font-family: monospace;
  font-size: 0.625rem;
  color: var(--text-muted);
  margin-bottom: 0.5rem;
}

.article__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.3125rem;
  margin-bottom: 1.25rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border);
}

/* ── Article body ────────────────────────────────────── */
.article__body h1,
.article__body h2,
.article__body h3 {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  color: var(--accent-cyan);
  text-shadow: 0 0 6px rgba(0, 255, 255, 0.3);
  margin: 1.25rem 0 0.5rem;
}

.article__body h2 { font-size: 1rem; }
.article__body h3 { font-size: 0.875rem; }
.article__body p  { color: #cbd5e1; margin-bottom: 0.75rem; }

.article__body code {
  font-family: monospace;
  font-size: 0.8125rem;
  color: var(--code-text);
  background: var(--code-bg);
  padding: 0.125rem 0.3125rem;
  border-radius: 2px;
}

.article__body pre {
  background: var(--code-bg);
  border-left: 3px solid var(--code-text);
  border-radius: 4px;
  padding: 0.75rem 0.875rem;
  margin: 0.75rem 0;
  overflow-x: auto;
}

.article__body pre code {
  background: none;
  padding: 0;
  font-size: 0.8125rem;
  color: var(--code-text);
}

.article__body blockquote {
  border-left: 3px solid var(--accent-purple);
  padding: 0.5rem 0.875rem;
  margin: 0.75rem 0;
  color: var(--text-muted);
  font-style: italic;
}

/* ── Series prev/next nav ────────────────────────────── */
.series-nav {
  display: flex;
  justify-content: space-between;
  padding: 0.875rem 0;
  border-top: 1px solid var(--border);
  margin-top: 1.5rem;
  font-family: monospace;
  font-size: 0.625rem;
}

/* ── Video embed ─────────────────────────────────────── */
.video-embed {
  width: 100%;
  border-radius: 4px;
  overflow: hidden;
  margin: 0.875rem 0;
  border: 1px solid var(--border);
  background: #080812;
  aspect-ratio: 16 / 9;
}

.video-embed video { width: 100%; height: 100%; display: block; }

/* ── Page title (series index, etc.) ────────────────── */
.page__title {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--accent-cyan);
  text-shadow: var(--glow-cyan);
  letter-spacing: 0.125rem;
  margin-bottom: 0.25rem;
}

.page__subtitle {
  font-family: monospace;
  font-size: 0.625rem;
  color: var(--text-muted);
  margin-bottom: 1.25rem;
}

/* ── Series term header ──────────────────────────────── */
.series-header {
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border);
  margin-bottom: 1.25rem;
}

.series-header__breadcrumb {
  font-family: monospace;
  font-size: 0.5625rem;
  color: var(--text-muted);
  margin-bottom: 0.5rem;
}

.series-header__title {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 1.375rem;
  font-weight: 700;
  color: var(--accent-magenta);
  text-shadow: var(--glow-magenta);
  letter-spacing: 0.125rem;
  margin-bottom: 0.375rem;
}

.series-header__desc {
  font-size: 0.8125rem;
  color: #94a3b8;
  line-height: 1.6;
  margin-bottom: 0.375rem;
}

.series-header__meta {
  font-family: monospace;
  font-size: 0.5625rem;
  color: var(--text-muted);
}

.series-header__meta span { color: var(--accent-magenta); }

/* ── Episode card (series term page) ────────────────── */
.episode-list {
  display: flex;
  flex-direction: column;
  gap: 0.875rem;
}

.episode-card {
  display: flex;
  background: var(--bg-surface);
  border: 1px solid var(--border);
  border-left: 3px solid var(--accent-magenta);
  border-radius: 6px;
  overflow: hidden;
  cursor: pointer;
  transition: var(--transition-card);
  text-decoration: none;
  color: inherit;
}

.episode-card:hover {
  transform: translateY(-2px) scale(1.01);
  box-shadow: 0 6px 24px rgba(255, 0, 255, 0.12);
  border-color: rgba(255, 0, 255, 0.27);
}

.episode-card__num {
  width: 2.25rem;
  flex-shrink: 0;
  background: #0a0010;
  border-right: 1px solid rgba(255, 0, 255, 0.13);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: monospace;
  font-size: 1rem;
  font-weight: 700;
  color: rgba(255, 0, 255, 0.35);
}

.episode-card__cover {
  width: 100px;
  min-height: 70px;
  flex-shrink: 0;
  position: relative;
  overflow: hidden;
  border-right: 1px solid var(--border);
}

.episode-card__cover--empty {
  background-color: #080812;
  background-image:
    linear-gradient(#0a0a18 1px, transparent 1px),
    linear-gradient(90deg, #0a0a18 1px, transparent 1px);
  background-size: 14px 14px;
}

.episode-card__cover-img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: var(--transition-cover);
}

.episode-card:hover .episode-card__cover-img { transform: scale(1.08); }

.episode-card__body    { padding: 0.5rem 0.625rem; flex: 1; }
.episode-card__meta    { font-family: monospace; font-size: 0.5625rem; color: var(--text-muted); margin-bottom: 0.1875rem; }
.episode-card__title   { font-size: 0.75rem; font-weight: 700; color: var(--text-primary); line-height: 1.4; margin-bottom: 0.25rem; }
.episode-card__excerpt { font-size: 0.5625rem; color: var(--text-muted); line-height: 1.4; }
```

- [ ] **Step 2: Verify build**

```bash
hugo
```
Expected: clean build, no errors.

- [ ] **Step 3: Commit**

```bash
git add themes/maxatlas/assets/css/main.css
git commit -m "feat: add CSS foundation with cyberpunk design tokens"
```

---

### Task 3: Base layout (baseof, head, nav)

**Files:**
- Modify: `themes/maxatlas/layouts/_default/baseof.html`
- Create: `themes/maxatlas/layouts/partials/head.html`
- Create: `themes/maxatlas/layouts/partials/nav.html`

- [ ] **Step 1: Create `partials/head.html`**

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

- [ ] **Step 2: Create `partials/nav.html`**

```html
<nav class="nav">
  <a class="nav__logo" href="{{ "/" | relURL }}">MAXATLAS</a>
  <ul class="nav__links">
    <li><a href="{{ "/posts/" | relURL }}"{{ if hasPrefix .RelPermalink "/posts" }} aria-current="page"{{ end }}>Blog</a></li>
    <li><a href="{{ "/series/" | relURL }}"{{ if hasPrefix .RelPermalink "/series" }} aria-current="page"{{ end }}>Series</a></li>
    <li><a href="{{ "/about/" | relURL }}"{{ if hasPrefix .RelPermalink "/about" }} aria-current="page"{{ end }}>About</a></li>
  </ul>
</nav>
```

- [ ] **Step 3: Replace `baseof.html` with full version**

```html
<!DOCTYPE html>
<html lang="{{ site.LanguageCode }}">
<head>
  {{ partial "head.html" . }}
</head>
<body>
  {{ partial "nav.html" . }}
  <main>
    {{ block "main" . }}{{ end }}
  </main>
</body>
</html>
```

- [ ] **Step 4: Verify build**

```bash
hugo
```
Expected: clean build, minified CSS file appears in `public/`.

- [ ] **Step 5: Commit**

```bash
git add themes/maxatlas/layouts/
git commit -m "feat: add base layout with head and nav partials"
```

---

### Task 4: Post card partial + homepage

**Files:**
- Create: `themes/maxatlas/layouts/partials/post-card.html`
- Create: `themes/maxatlas/layouts/_default/list.html`
- Create: `content/posts/astronight-ep1/index.md`
- Create: `content/posts/rust-lifetimes/index.md`

- [ ] **Step 1: Create `partials/post-card.html`**

```html
{{ $cover := .Resources.GetMatch "cover.*" }}
{{ $isSeries := .Params.series }}
<a class="post-card{{ if $isSeries }} post-card--series{{ else }} post-card--standalone{{ end }}" href="{{ .RelPermalink }}">
  <div class="post-card__cover{{ if not $cover }} post-card__cover--empty{{ end }}">
    {{ if $cover }}
      <img class="post-card__cover-img" src="{{ $cover.RelPermalink }}" alt="{{ .Title }}">
    {{ end }}
  </div>
  <div class="post-card__body">
    <div class="post-card__date">{{ .Date.Format "2006-01-02" }}</div>
    <div class="post-card__title">{{ .Title }}</div>
    <div class="post-card__excerpt">{{ .Summary | plainify | truncate 120 }}</div>
    <div class="post-card__tags">
      {{ range .Params.series }}
        <span class="tag tag--series">{{ . }}</span>
      {{ end }}
      {{ range .Params.tags }}
        <span class="tag tag--regular">{{ . }}</span>
      {{ end }}
    </div>
  </div>
</a>
```

- [ ] **Step 2: Create `_default/list.html`**

```html
{{ define "main" }}
<div class="page">
  <div class="post-list">
    {{ range .Pages.ByDate.Reverse }}
      {{ partial "post-card.html" . }}
    {{ end }}
  </div>
  {{ template "_internal/pagination.html" . }}
</div>
{{ end }}
```

- [ ] **Step 3: Create sample series post**

`content/posts/astronight-ep1/index.md`:
```markdown
---
title: "Bootstrap: Setting Up the Project"
date: 2026-03-01
series: ["astronight"]
episode: 1
tags: ["rust", "webgpu"]
---

Setting up a Cargo workspace, initializing a wgpu surface, and rendering the first triangle. Everything starts somewhere — ours starts here.
```

- [ ] **Step 4: Create sample standalone post**

`content/posts/rust-lifetimes/index.md`:
```markdown
---
title: "Why Lifetimes Make Sense (Eventually)"
date: 2026-03-15
tags: ["rust"]
---

Rust's borrow checker is not your enemy. Once you stop fighting it, it becomes the best pair-programmer you've ever had.
```

- [ ] **Step 5: Start dev server and verify homepage**

```bash
hugo server
```

Open http://localhost:1313 and verify:
- Two post cards visible, most recent first
- AstroNight card: magenta left border, series tag in magenta
- Rust card: cyan left border, tag in cyan
- Both cards show the grid placeholder (no cover files yet)
- Hover effect: card lifts slightly

- [ ] **Step 6: Commit**

```bash
git add themes/maxatlas/layouts/partials/post-card.html themes/maxatlas/layouts/_default/list.html content/posts/
git commit -m "feat: add homepage list and post card partial with cover detection"
```

---

### Task 5: Article single page

**Files:**
- Create: `themes/maxatlas/layouts/_default/single.html`
- Create: `content/posts/astronight-ep2/index.md`

- [ ] **Step 1: Create `_default/single.html`**

```html
{{ define "main" }}
{{ $cover := .Resources.GetMatch "cover.*" }}
{{ $series := index .Params.series 0 }}

{{ if $cover }}
<div class="article__cover">
  <img src="{{ $cover.RelPermalink }}" alt="{{ .Title }}">
  <div class="article__cover-scanlines"></div>
</div>
{{ end }}

<div class="page">
  <article>
    <h1 class="article__title">{{ .Title }}</h1>
    <div class="article__meta">
      {{ .Date.Format "January 2, 2006" }} · {{ .ReadingTime }} min read
    </div>
    <div class="article__tags">
      {{ range .Params.series }}
        <a href="{{ printf "/series/%s/" . | relURL }}" class="tag tag--series">{{ . }}</a>
      {{ end }}
      {{ range .Params.tags }}
        <a href="{{ printf "/tags/%s/" . | relURL }}" class="tag tag--regular">{{ . }}</a>
      {{ end }}
    </div>

    <div class="article__body">
      {{ .Content }}
    </div>

    {{ if $series }}
      {{ $currentEp := .Params.episode }}
      {{ $seriesPages := (index site.Taxonomies.series $series).Pages.ByParam "episode" }}
      {{ $prev := false }}
      {{ $next := false }}
      {{ range $seriesPages }}
        {{ if lt .Params.episode $currentEp }}{{ $prev = . }}{{ end }}
        {{ if and (not $next) (gt .Params.episode $currentEp) }}{{ $next = . }}{{ end }}
      {{ end }}
      {{ if or $prev $next }}
      <nav class="series-nav">
        <span>{{ if $prev }}← <a href="{{ $prev.RelPermalink }}">{{ $prev.Title }}</a>{{ end }}</span>
        <span>{{ if $next }}<a href="{{ $next.RelPermalink }}">{{ $next.Title }}</a> →{{ end }}</span>
      </nav>
      {{ end }}
    {{ end }}
  </article>
</div>
{{ end }}
```

- [ ] **Step 2: Add a second episode for series nav testing**

`content/posts/astronight-ep2/index.md`:
```markdown
---
title: "Shaders: Writing WGSL from Scratch"
date: 2026-03-20
series: ["astronight"]
episode: 2
tags: ["rust", "webgpu", "wgsl"]
---

WGSL is WebGPU's shading language. It looks like Rust, but it isn't. Here's how to write your first vertex and fragment shaders without losing your mind.
```

- [ ] **Step 3: Start dev server and verify article pages**

```bash
hugo server
```

Open http://localhost:1313/posts/astronight-ep1/ and verify:
- No cover zone (no `cover.*` file) — page begins directly with title
- Title in cyan glow, monospace font
- Meta shows date + reading time
- Tags: `astronight` in magenta, `rust`/`webgpu` in cyan, both are links
- Body text renders
- Series nav shows "→ Shaders: Writing WGSL" (no prev link)

Open http://localhost:1313/posts/astronight-ep2/ and verify:
- Series nav shows "← Bootstrap" and no next link

- [ ] **Step 4: Commit**

```bash
git add themes/maxatlas/layouts/_default/single.html content/posts/astronight-ep2/
git commit -m "feat: add article page with cover, highlighted tags, and series navigation"
```

---

### Task 6: Video shortcode

**Files:**
- Create: `themes/maxatlas/layouts/shortcodes/video.html`

- [ ] **Step 1: Create `shortcodes/video.html`**

```html
{{ $src := .Get "src" }}
{{ $resource := .Page.Resources.GetMatch $src }}
<div class="video-embed">
  <video autoplay loop muted playsinline>
    {{ if $resource }}
      <source src="{{ $resource.RelPermalink }}" type="video/webm">
    {{ else }}
      <source src="{{ $src }}" type="video/webm">
    {{ end }}
  </video>
</div>
```

- [ ] **Step 2: Add shortcode usage to the first sample post**

Update `content/posts/astronight-ep1/index.md`:
```markdown
---
title: "Bootstrap: Setting Up the Project"
date: 2026-03-01
series: ["astronight"]
episode: 1
tags: ["rust", "webgpu"]
---

Setting up a Cargo workspace, initializing a wgpu surface, and rendering the first triangle.

## The first triangle

Every graphics tutorial starts here. Ours is no different.

{{</* video src="demo.webm" */>}}

The triangle rotates at 60fps. Not impressive yet, but it's all downhill from here.
```

> Note: Hugo's built-in `{{</* youtube VIDEO_ID */>}}` shortcode works without any configuration. No custom shortcode needed for YouTube.

- [ ] **Step 3: Verify build (no actual `.webm` file needed)**

```bash
hugo
```
Expected: clean build. The `<video>` tag renders with a missing source — no template errors.

- [ ] **Step 4: Commit**

```bash
git add themes/maxatlas/layouts/shortcodes/ content/posts/astronight-ep1/
git commit -m "feat: add WebM video shortcode for self-hosted embeds"
```

---

### Task 7: Series index page

**Files:**
- Create: `themes/maxatlas/layouts/series/list.html`
- Create: `content/series/astronight/_index.md`
- Create: `content/series/timelapse/_index.md`
- Create: `content/posts/timelapse-ep1/index.md`

- [ ] **Step 1: Create `series/list.html`**

```html
{{ define "main" }}
<div class="page">
  <h1 class="page__title">// SERIES</h1>
  <p class="page__subtitle">Long-form content organized into episodes</p>

  <div class="post-list">
    {{ range .Data.Terms.ByCount }}
      {{ $termPage := .Page }}
      {{ $cover := $termPage.Resources.GetMatch "cover.*" }}
      {{ $pages := .Pages.ByDate.Reverse }}
      {{ $latest := index $pages 0 }}
      <a class="post-card post-card--series" href="{{ $termPage.RelPermalink }}">
        <div class="post-card__cover{{ if not $cover }} post-card__cover--empty{{ end }}">
          {{ if $cover }}
            <img class="post-card__cover-img" src="{{ $cover.RelPermalink }}" alt="{{ $termPage.Title }}">
          {{ end }}
        </div>
        <div class="post-card__body">
          <div class="post-card__title" style="color:var(--accent-magenta);text-shadow:var(--glow-magenta);">
            {{ upper $termPage.Title }}
          </div>
          <div class="post-card__excerpt">{{ $termPage.Params.description }}</div>
          <div class="post-card__date">
            <span style="color:var(--accent-magenta);">{{ len .Pages }} episodes</span>
            {{ if $latest }} · last updated {{ $latest.Date.Format "January 2, 2006" }}{{ end }}
          </div>
        </div>
      </a>
    {{ end }}
  </div>
</div>
{{ end }}
```

- [ ] **Step 2: Create series metadata files**

`content/series/astronight/_index.md`:
```markdown
---
title: "AstroNight"
description: "Building a real-time space renderer from scratch — Rust, WebGPU, and a lot of caffeine."
---
```

`content/series/timelapse/_index.md`:
```markdown
---
title: "Timelapse"
description: "Rapid prototyping challenges — building full projects in 48 hours or less."
---
```

- [ ] **Step 3: Add a Timelapse post so both series appear**

`content/posts/timelapse-ep1/index.md`:
```markdown
---
title: "From Zero to WASM in 48 Hours"
date: 2026-03-28
series: ["timelapse"]
episode: 1
tags: ["rust", "wasm"]
---

The goal: compile a working game engine to WebAssembly in under 48 hours. It actually worked, mostly.
```

- [ ] **Step 4: Start dev server and verify `/series/`**

```bash
hugo server
```

Open http://localhost:1313/series/ and verify:
- Both series cards visible
- Magenta title, description, episode count, last updated date
- Cover space reserved (grid placeholder — no cover files yet)
- Hover lifts card

- [ ] **Step 5: Commit**

```bash
git add themes/maxatlas/layouts/series/list.html content/series/ content/posts/timelapse-ep1/
git commit -m "feat: add series index page and series metadata"
```

---

### Task 8: Series term page

**Files:**
- Create: `themes/maxatlas/layouts/series/term.html`

- [ ] **Step 1: Create `series/term.html`**

```html
{{ define "main" }}
{{ $cover := .Resources.GetMatch "cover.*" }}

{{ if $cover }}
<div class="article__cover" style="margin-bottom:0;">
  <img src="{{ $cover.RelPermalink }}" alt="{{ .Title }}">
  <div class="article__cover-scanlines"></div>
</div>
{{ end }}

<div class="page">
  <div class="series-header">
    <div class="series-header__breadcrumb">
      <a href="{{ "/series/" | relURL }}">Series</a> / {{ .Title }}
    </div>
    <h1 class="series-header__title">✦ {{ upper .Title }}</h1>
    <p class="series-header__desc">{{ .Params.description }}</p>
    <div class="series-header__meta">
      <span>{{ len .Pages }} episodes</span> · ongoing
    </div>
  </div>

  <div class="episode-list">
    {{ range .Pages.ByDate.Reverse }}
      {{ $epCover := .Resources.GetMatch "cover.*" }}
      <a class="episode-card" href="{{ .RelPermalink }}">
        <div class="episode-card__num">{{ .Params.episode }}</div>
        <div class="episode-card__cover{{ if not $epCover }} episode-card__cover--empty{{ end }}">
          {{ if $epCover }}
            <img class="episode-card__cover-img" src="{{ $epCover.RelPermalink }}" alt="{{ .Title }}">
          {{ end }}
        </div>
        <div class="episode-card__body">
          <div class="episode-card__meta">{{ .Date.Format "January 2, 2006" }}</div>
          <div class="episode-card__title">{{ .Title }}</div>
          <div class="episode-card__excerpt">{{ .Summary | plainify | truncate 100 }}</div>
        </div>
      </a>
    {{ end }}
  </div>
</div>
{{ end }}
```

- [ ] **Step 2: Start dev server and verify series term pages**

```bash
hugo server
```

Open http://localhost:1313/series/astronight/ and verify:
- Breadcrumb: `Series / AstroNight`
- Magenta title `✦ ASTRONIGHT`, description, episode count
- Episode list: ep 2 shown before ep 1 (most recent first)
- Episode number in left column
- Cover space reserved (grid placeholder)
- Hover lifts card

Open http://localhost:1313/series/timelapse/ and verify:
- Single episode visible

- [ ] **Step 3: Commit**

```bash
git add themes/maxatlas/layouts/series/term.html
git commit -m "feat: add series term page with episodes sorted by date desc"
```

---

### Task 9: GitHub Actions workflow

**Files:**
- Modify: `.github/workflows/static.yml`

- [ ] **Step 1: Replace the existing workflow**

`.github/workflows/static.yml`:
```yaml
name: Deploy Hugo site to Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v3
        with:
          hugo-version: "latest"
          extended: true

      - name: Build
        run: hugo --minify

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v5
```

- [ ] **Step 2: Verify local build**

```bash
hugo --minify
ls public/
```
Expected output includes: `index.html`, `posts/`, `series/`, `about/`, `tags/`, `css/` (minified).

- [ ] **Step 3: Commit and push**

```bash
git add .github/workflows/static.yml
git commit -m "feat: update GitHub Actions to build Hugo and deploy public/"
git push origin main
```

Expected: GitHub Actions triggers, Hugo builds successfully, site live at `https://maxatlas.github.io/`.
