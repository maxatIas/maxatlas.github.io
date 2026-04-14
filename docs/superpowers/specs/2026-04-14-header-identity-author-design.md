# Design: Header Identity & Author Block

**Date:** 2026-04-14  
**Status:** Approved

## Summary

Two independent features for the Hugo theme:

1. **Nav header identity** — display an avatar image, site title, and motto in the navbar logo area.
2. **Author block in articles** — display avatar, name, and description just below the article date, with per-post frontmatter override.

---

## Config Structure

Add to `hugo.toml` under `[params]`:

```toml
[params]
  # Nav identity (site branding, separate from author)
  headerTitle = "MAXATLAS"
  headerImg   = "/img/max-800x800.avif"
  motto       = "Game Developer"

  # Default author (overridable per post via frontmatter)
  author      = "Max Pilato"
  description = "Game Developer"
  avatar      = "/img/max-800x800.avif"
```

The nav identity and author are intentionally separate: `headerTitle` is a brand/handle, `author` is the real name shown in article bylines.

### Per-post frontmatter override

Any of the three author fields can be overridden in a post's frontmatter:

```yaml
author: "Guest Author"
description: "Indie dev"
avatar: "/img/guest.avif"
```

Fallback chain: frontmatter value → `site.Params` global value → omit the element (never render broken UI).

---

## Feature 1: Nav Header Identity

### Layout

The `.nav__logo` anchor becomes a flex container:

```
[avatar 36px]  MAXATLAS          ← .nav__logo-title  (accent-cyan, monospace, glow)
               Game Developer    ← .nav__logo-motto  (text-muted, 0.75rem)
```

- Avatar: `36px × 36px`, `border-radius: 50%`, `2px solid` ring in `--accent-cyan` with `box-shadow: var(--glow-cyan)`
- `headerImg` absent → avatar element not rendered, title+motto only
- `motto` absent → motto line not rendered

### Files changed

- `hugo.toml` — add params
- `themes/maxatlas/layouts/partials/nav.html` — replace static text logo with dynamic block
- `themes/maxatlas/assets/css/main.css` — add `.nav__logo-img`, `.nav__logo-title`, `.nav__logo-motto` styles

---

## Feature 2: Author Block in Articles

### Layout

Inserted in `single.html` immediately after `.article__meta` (date · reading time):

```
[avatar 40px]  Max Pilato        ← .author__name   (text-primary, 0.875rem, semi-bold)
               Game Developer    ← .author__desc   (text-muted, 0.8125rem)
```

- Avatar: `40px × 40px`, `border-radius: 50%`, same cyan ring style
- If `avatar` resolves to empty string → avatar `<img>` not rendered
- If both `author` and `avatar` are absent → entire block hidden

### Frontmatter resolution (Hugo template logic)

```
authorName := coalesce(.Params.author, site.Params.author)
authorDesc := coalesce(.Params.description, site.Params.description)
authorAvatar := coalesce(.Params.avatar, site.Params.avatar)
```

### Files changed

- `themes/maxatlas/layouts/_default/single.html` — add author block after `.article__meta`
- `themes/maxatlas/assets/css/main.css` — add `.article__author`, `.author__avatar`, `.author__name`, `.author__desc` styles

---

## Out of Scope

- Multi-author support (YAGNI for a personal blog)
- Author archive/listing page
- Social links or extra author metadata
