# Social Media Meta Tags — Design Spec

**Date:** 2026-04-14  
**Status:** Approved

## Goal

Add Open Graph and Twitter Card meta tags to every page of the maxatlas Hugo site so that links shared on social platforms (Facebook, LinkedIn, Mastodon, Discord, Slack, Twitter/X, etc.) render with a rich preview: title, description, and image.

## Scope

- All page types: home, post, series index, series term, tag list, about
- No Twitter/X account handle — `twitter:site` tag omitted
- No dynamic image generation — static cover images and one fallback

---

## Files

| File | Action |
|------|--------|
| `themes/maxatlas/layouts/partials/og.html` | **Create** — all OG/Twitter logic |
| `themes/maxatlas/layouts/partials/head.html` | **Edit** — add `{{ partial "og.html" . }}` |
| `static/og-default.avif` | **Add** — fallback image (1200×630 px, provided by user) |

---

## Logic

### Image resolution (in order)

1. `cover.*` from the current page's Page Bundle (posts only) — resolved via `.Resources.GetMatch "cover.*"`
2. `static/og-default.avif` — used for all other pages and posts without a cover

The absolute image URL is built with `absURL`.

### OG type

| Condition | `og:type` |
|-----------|-----------|
| Post page (`.IsPage` and section = `posts`) | `article` |
| Everything else | `website` |

### Description resolution (in order)

1. `.Description` from frontmatter (explicit override)
2. `.Summary` (Hugo auto-excerpt, ~70 words from content)
3. `site.Params.description` (global fallback)

---

## Tags Generated

### Open Graph (all pages)

```html
<meta property="og:title"       content="…">
<meta property="og:description" content="…">
<meta property="og:type"        content="website | article">
<meta property="og:url"         content="…">
<meta property="og:image"       content="…">
<meta property="og:site_name"   content="MaxAtlas">
```

### Open Graph (posts only — additional)

```html
<meta property="article:published_time" content="2026-04-06T00:00:00Z">
<meta property="article:tag"            content="game">
<meta property="article:tag"            content="unity">
<!-- one tag per entry in .Params.tags -->
```

### Twitter Cards (all pages)

```html
<meta name="twitter:card"        content="summary_large_image">
<meta name="twitter:title"       content="…">
<meta name="twitter:description" content="…">
<meta name="twitter:image"       content="…">
```

---

## Constraints

- Use `absURL` (not `relURL`) for `og:image` and `og:url` — social crawlers require absolute URLs.
- The fallback image `static/og-default.avif` must be 1200×630 px (standard OG image ratio).
- `og:description` and `twitter:description` should be capped at ~200 characters to avoid truncation; Hugo's `.Summary` already does this naturally.
- No changes to content files or frontmatter schema required — all fields (`description`, `tags`, `series`, `date`) already exist.
