# Banner Feature Design

**Date:** 2026-04-14  
**Status:** Approved

## Overview

A three-level banner system for the Hugo site. A single partial evaluates a priority chain and injects a banner image between the nav and the `<main>` block on any page.

## Priority Chain

Sources are evaluated in order; the first match wins:

1. **Frontmatter `banner:`** — any page can declare a banner URL directly. Optional `banner_dest:` makes the image a clickable link.
2. **Page bundle `banner.*`** — a `banner.*` file co-located with the page's `index.md` (or `_index.md` for the homepage). Detected via Hugo's `.Resources.GetMatch`.
3. **Global `static/img/banner.*`** — shown on every page if no higher-priority source is found. Detected with `os.FileExists` across known extensions (`avif`, `webp`, `jpg`, `jpeg`, `png`).

## Architecture

### New file: `themes/maxatlas/layouts/partials/banner.html`

Evaluates the priority chain and emits the banner HTML. Called from `baseof.html`.

**Logic (pseudo-code):**

```
bannerURL = ""
bannerDest = ""

if .Params.banner:
    bannerURL  = .Params.banner
    bannerDest = .Params.banner_dest   # optional

else if .Resources.GetMatch "banner.*":
    bannerURL = resource.RelPermalink

else:
    for ext in [avif, webp, jpg, jpeg, png]:
        if os.FileExists("static/img/banner.{ext}"):
            bannerURL = "/img/banner.{ext}"
            break

if bannerURL:
    emit <div class="site-banner">
        [if bannerDest: <a href="{bannerDest}" target="_blank" rel="noopener">]
        <img src="{bannerURL}" alt="Banner" class="site-banner__img">
        [if bannerDest: </a>]
    </div>
```

### Modified file: `themes/maxatlas/layouts/_default/baseof.html`

Add `{{ partial "banner.html" . }}` between `{{ partial "nav.html" . }}` and `<main>`.

### Modified file: `themes/maxatlas/assets/css/main.css`

New block added after the `.nav` section:

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

## Frontmatter Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `banner` | string (URL) | no | Banner image URL |
| `banner_dest` | string (URL) | no | Click destination (only used when `banner` is set) |

## Homepage Setup

`content/_index.md` does not exist yet and must be created. A `content/banner.*` file placed alongside it will be auto-detected via `.Resources.GetMatch` (branch bundle resources).

## Visual Behaviour

- Banner constrained to content width (680px max)
- Image max-height: 300px — scales proportionally, never cropped (`object-fit` not needed; natural `max-width`/`max-height` with `width/height: auto` achieves this)
- No scanlines overlay
- Centered horizontally within the content column
- Clickable only when `banner_dest` is set

## Files Changed

| File | Change |
|------|--------|
| `themes/maxatlas/layouts/partials/banner.html` | New |
| `themes/maxatlas/layouts/_default/baseof.html` | Add one partial call |
| `themes/maxatlas/assets/css/main.css` | Add `.site-banner` styles |
| `content/_index.md` | New (optional, for homepage bundle banner) |
