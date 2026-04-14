# Social Links on About Page — Design Spec

**Date:** 2026-04-14
**Status:** Approved

## Overview

Add a row of social/profile icon links at the bottom of the About page. Links are defined in a standalone `data/socials.toml` file and rendered using Ionicons web components.

## Data

File: `data/socials.toml` (repo root, `data/` directory to be created).

Each link is an entry in the `[[socials]]` array:

```toml
# Icons: https://ionic.io/ionicons
[[socials]]
href   = "https://github.com/dadoonet"
target = "_blank"
icon   = "logo-github"
title  = "GitHub"
```

Fields per entry:

| Field    | Required | Notes                                      |
|----------|----------|--------------------------------------------|
| `href`   | yes      | Destination URL                            |
| `target` | yes      | Link target (`_blank` for external)        |
| `icon`   | yes      | Ionicons icon name                         |
| `title`  | yes      | Accessible label shown as tooltip          |

Hugo exposes the data as `site.Data.socials.socials`.

Initial entries: GitHub, X, Bluesky, LinkedIn, Stack Overflow, Elastic, Apple Podcast, Instagram (DJ Elky).

## Layout

New file: `layouts/about/single.html` (project root, not inside `themes/`).

Hugo automatically selects this layout for `content/about/index.md` over the theme's `_default/single.html`.

The file is a full copy of `themes/maxatlas/layouts/_default/single.html` with one addition: after the `.article__body` div and before the series nav block, inject the social links partial when data is present:

```html
{{ if site.Data.socials }}
<div class="social-links">
  {{ range site.Data.socials.socials }}
  <a href="{{ .href }}" target="{{ .target }}" title="{{ .title }}"
     class="social-link" rel="noopener noreferrer">
    <ion-icon name="{{ .icon }}"></ion-icon>
  </a>
  {{ end }}
</div>
{{ end }}
```

Ionicons is loaded via two CDN `<script>` tags placed at the bottom of `layouts/about/single.html`, just before the closing `{{ end }}` of the `main` block. This scopes the CDN load to the about page only:

```html
<script type="module" src="https://unpkg.com/ionicons@7/dist/ionicons/ionicons.esm.js"></script>
<script nomodule src="https://unpkg.com/ionicons@7/dist/ionicons/ionicons.js"></script>
```

## Styles

New CSS block appended to `themes/maxatlas/assets/css/main.css`:

```css
/* ── Social links (about page) ───────────────────────── */
.social-links {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border);
  margin-top: 1.5rem;
}

.social-link {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border: 1px solid rgba(0, 255, 255, 0.27);
  border-radius: 4px;
  color: var(--text-muted);
  font-size: 1.375rem;
  transition: color 0.15s ease, border-color 0.15s ease, box-shadow 0.15s ease;
}

.social-link:hover {
  color: var(--accent-cyan);
  border-color: var(--accent-cyan);
  box-shadow: var(--glow-cyan);
}
```

Visual style: square icon buttons, muted colour at rest, cyan glow on hover — consistent with existing nav and tag components.

## Files Changed

| Action | Path |
|--------|------|
| Create | `data/socials.toml` |
| Create | `layouts/about/single.html` |
| Edit   | `themes/maxatlas/assets/css/main.css` |

## Out of Scope

- Social links in the nav or footer (not requested).
- A Hugo config (`hugo.toml`) alternative for the data (TOML data file preferred).
