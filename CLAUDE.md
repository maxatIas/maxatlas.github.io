# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Local development (recommended during active writing)
hugo server --buildDrafts --buildFuture

# Production build
hugo --gc --minify

# Create a new post (creates as draft by default)
hugo new posts/YYYY/YYYY-MM-DD-slug/index.md

# Convert images to AVIF (requires ImageMagick)
./scripts/convert-media.sh                              # all posts + static/
./scripts/convert-media.sh content/posts/2026/my-post  # single post
```

The dev server runs at `http://localhost:1313/` with live reload.

## Architecture

This is a Hugo static site with a fully custom theme (`themes/maxatlas/`) — a cyberpunk/neon aesthetic. The theme is **not** a submodule; it lives directly in the repo and is the primary place for layout and style changes.

**Content model:**

- Posts use **Page Bundles** at `content/posts/YYYY/YYYY-MM-DD-slug/index.md`. All assets (images, video) for a post go in the same folder.
- `cover.*` (any extension, typically `.avif`) in a Page Bundle is auto-detected and shown as both thumbnail and article banner.
- Series are a Hugo taxonomy (`content/series/<slug>/_index.md`). Posts reference a series via `series: ["slug"]` and `episode: N` frontmatter.
- The `about/index.md` page uses `showMeta: false` to suppress date and reading time.

**Theme layout flow:**

- `baseof.html` is the shell (nav + footer); `single.html` and `list.html` fill the `main` block.
- `single.html` handles: cover image with scanline overlay, article meta, tags/series badges, content, and series prev/next navigation.
- `series/term.html` renders the episode list for a given series.
- Custom shortcodes: `{{< video src="file.mp4" >}}` for self-hosted video, `{{< youtube ID >}}` for YouTube.

**Deployment:** GitHub Actions (`.github/workflows/hugo.yml`) builds with Hugo extended v0.160.1 and deploys to GitHub Pages on every push to `main`, on a daily schedule (08:00 UTC), and on manual trigger.

## Frontmatter Reference

| Field | Required | Notes |
|-------|----------|-------|
| `title` | yes | Displayed in cards and article header |
| `date` | yes | `YYYY-MM-DD`; future dates hidden unless `--buildFuture` |
| `draft` | no | Default `false`; hidden unless `--buildDrafts` |
| `tags` | no | Rendered as cyan badges |
| `series` | no | Slug list, e.g. `["astronight"]` |
| `episode` | if series set | Integer; used for ordering and prev/next nav |
| `showMeta` | no | Set `false` to hide date and reading time |
