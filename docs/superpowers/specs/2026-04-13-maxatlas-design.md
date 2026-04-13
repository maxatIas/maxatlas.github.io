# maxatlas — Hugo Site Design Spec

**Date:** 2026-04-13  
**Status:** Approved  

---

## Overview

A Hugo-powered blog for computer development articles, built with a fully custom theme named `maxatlas`. The aesthetic is **cyberpunk / neon** — dark background, cyan/magenta glows, green terminal code, monospace typography. The site is English-only and deployed to GitHub Pages.

---

## Design Tokens

### Color Palette

| Token             | Value     | Usage                        |
|-------------------|-----------|------------------------------|
| `--bg-base`       | `#0d0d1a` | Main background              |
| `--bg-surface`    | `#111128` | Cards, panels                |
| `--accent-cyan`   | `#00ffff` | Links, headings, active nav  |
| `--accent-magenta`| `#ff00ff` | Hover states, series tags    |
| `--accent-purple` | `#7b2fff` | Secondary accents            |
| `--text-primary`  | `#e2e8f0` | Body text                    |
| `--text-muted`    | `#64748b` | Dates, meta, excerpts        |
| `--border`        | `#1a2a3a` | Card borders, dividers       |
| `--code-text`     | `#39ff14` | Code blocks (neon green)     |
| `--code-bg`       | `#050505` | Code block background        |

### Typography

- **Headings:** Monospace (JetBrains Mono or Fira Code via Google Fonts), cyan with glow effect (`text-shadow: 0 0 10px rgba(0,255,255,0.4)`)
- **Body:** `system-ui, sans-serif` — 15px, line-height 1.7, `--text-primary`
- **Code inline/blocks:** Monospace, `--code-text` on `--code-bg`, left border `3px solid #39ff14`
- **Tags/UI labels:** Monospace, uppercase, letter-spacing 1px

### Tag Styles

- **Series tag:** `background:#1a0020; color:#ff00ff; border:1px solid #ff00ff44`
- **Regular tag:** `background:#001a1a; color:#00ffff; border:1px solid #00ffff44`

---

## Pages & Navigation

| Page       | URL              | Template                    |
|------------|------------------|-----------------------------|
| Homepage   | `/`              | `_default/list.html`        |
| Blog list  | `/posts/`        | `_default/list.html`        |
| Article    | `/posts/<slug>/` | `_default/single.html`      |
| Series index | `/series/`     | `series/list.html`          |
| Series page | `/series/<name>/`| `series/term.html`          |
| About      | `/about/`        | `_default/single.html`      |

**Navigation bar:** `MAXATLAS` logo (cyan glow) · Blog · Series · About  
Dark background (`#080810`), bottom border `1px solid #00ffff22`.

---

## Homepage Layout

Chronological list of posts (most recent first), paginated. No sidebar.

### Post Card

Each article renders as a horizontal card:

- **With cover:** image on the left (130px wide) + content on the right
- **Without cover:** same 130px space reserved (dark grid pattern `#080812`) + content on the right
- Cover image: auto-detected from `cover.*` in the article's Page Bundle directory
- **Border-left:** `3px solid #ff00ff` for series articles, `3px solid #00ffff` for standalone

**Hover effect:**
- Card: `transform: translateY(-2px) scale(1.01)` + `box-shadow: 0 6px 24px rgba(0,255,255,0.12)` + border brightens
- Cover image: inner `transform: scale(1.08)` with overflow clip (zoom without overflow)
- Transition: `0.2s ease` on card, `0.3s ease` on cover

**Card content:**
1. Date (`--text-muted`, monospace, 9px)
2. Title (`--text-primary`, 12px, bold)
3. Excerpt (`--text-muted`, 9px)
4. Tags: series tag (magenta) and/or regular tags (cyan)

---

## Article Page Layout

```
┌─────────────────────────────────────┐
│ NAV                                 │
├─────────────────────────────────────┤
│ COVER (full width, 16:9-ish)        │
├─────────────────────────────────────┤
│ TITLE (cyan glow, monospace)        │
│ DATE · READ TIME                    │
│ [AstroNight] [Rust] [WebGPU]        │  ← highlighted tags
├─────────────────────────────────────┤
│ BODY (system-ui, 15px, lh 1.7)     │
│   h2 (cyan glow, monospace)         │
│   code blocks (green terminal)      │
│   video embeds                      │
├─────────────────────────────────────┤
│ ← Episode 2    Episode 4 →          │  ← series nav (if in series)
└─────────────────────────────────────┘
```

- **Cover:** full-width, `overflow:hidden`, scanline overlay for texture. Optional — only rendered if `cover.*` exists.
- **Tags:** Series tag (magenta) first, then regular tags (cyan), displayed as highlighted badges (same style as homepage cards).
- **Series navigation:** prev/next episode links, only shown for articles belonging to a series.

---

## Series Index Page (`/series/`)

- Page title: `// SERIES` (cyan glow)
- Same horizontal card layout as homepage
- Cover = series cover (`cover.*` in the series `_index.md` directory)
- Each card shows: series name (magenta), description, episode count, last updated date
- Sorted by most recently updated series

---

## Series Page (`/series/<name>/`)

- Header: breadcrumb · series title (magenta glow) · description · episode count + status
- Episode list sorted **most recent first** (reverse chronological)
- Each episode card: episode number badge (left column) · cover · title · date · excerpt
- Same hover effects as homepage cards (cover zoom + card lift)
- Cover space always reserved (empty grid placeholder if no `cover.*`)

---

## Content Structure (Hugo Page Bundles)

```
content/
├── posts/
│   ├── astronight-ep3/
│   │   ├── index.md        # article content
│   │   ├── cover.webp      # auto-detected cover
│   │   └── render-loop.webm
│   └── rust-lifetimes/
│       └── index.md        # no cover — space reserved
├── series/
│   ├── astronight/
│   │   ├── _index.md       # series title, description
│   │   └── cover.webp      # series cover
│   └── timelapse/
│       ├── _index.md
│       └── cover.avif
└── about/
    └── index.md
```

### Article Front Matter

```yaml
---
title: "The Rendering Pipeline"
date: 2026-04-10
series: ["astronight"]
episode: 3
tags: ["rust", "webgpu", "gamedev"]
---
```

---

## Hugo Configuration (`hugo.toml`)

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
```

---

## Theme Architecture (`themes/maxatlas/`)

```
themes/maxatlas/
├── layouts/
│   ├── _default/
│   │   ├── baseof.html       # base template (nav, head, footer)
│   │   ├── list.html         # homepage + /posts/
│   │   └── single.html       # article page
│   ├── series/
│   │   ├── list.html         # /series/ index
│   │   └── term.html         # /series/<name>/
│   ├── shortcodes/
│   │   └── video.html        # {{< video src="file.webm" >}}
│   └── partials/
│       ├── head.html         # <head>, CSS, fonts
│       ├── nav.html          # top navigation bar
│       └── post-card.html    # reusable card partial
└── assets/
    └── css/
        └── main.css          # CSS custom properties + all styles
```

### Cover Detection Logic (in `post-card.html`)

```go-html-template
{{ $cover := .Resources.GetMatch "cover.*" }}
<div class="cover{{ if not $cover }} empty{{ end }}">
  {{ if $cover }}
    <img src="{{ $cover.RelPermalink }}" alt="Cover">
  {{ end }}
</div>
```

### Video Shortcode (`shortcodes/video.html`)

```go-html-template
<video autoplay loop muted playsinline>
  <source src="{{ .Get "src" }}" type="video/webm">
</video>
```

YouTube is handled by Hugo's built-in `{{< youtube VIDEO_ID >}}` shortcode.

---

## Image Formats

- Preferred: **WebP** and **AVIF** for covers and inline images
- Hugo's built-in image processing pipeline can be used for resizing/optimization
- No special configuration required — files placed directly in Page Bundle directories

---

## GitHub Actions Workflow

The existing `static.yml` deploys raw HTML. It must be replaced with a Hugo build workflow:

1. Checkout repository
2. Install Hugo (latest extended version)
3. Run `hugo --minify`
4. Deploy `./public` to GitHub Pages

---

## Out of Scope

- Comments system (none)
- Search (none)
- Dark/light mode toggle (dark only)
- Multilingual support (English only)
- Analytics
