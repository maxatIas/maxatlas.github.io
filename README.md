# maxatlas.github.io

Personal website powered by [Hugo](https://gohugo.io/) with the custom **maxatlas** theme — a cyberpunk/neon aesthetic built for developer blogs.

**Live site:** https://max.pilato.fr/

---

## Requirements

- [Hugo](https://gohugo.io/installation/) **extended** v0.160.1+
- [ffmpeg](https://ffmpeg.org/) (optional — for media conversion, see `scripts/convert-media.sh`)

---

## Local Development

```bash
# Standard preview (published posts only)
hugo server

# Include draft posts
hugo server --buildDrafts

# Include posts with a future date
hugo server --buildFuture

# Both — recommended during active writing
hugo server --buildDrafts --buildFuture
```

The site is served at http://localhost:1313/ with live reload.

---

## Content Structure

```
content/
├── about/
│   └── index.md
├── posts/
│   └── yyyy/
│       └── yyyy-mm-dd-slug/
│           ├── index.md        ← article
│           ├── cover.jpg       ← optional cover image (auto-detected)
│           └── video.mp4       ← optional video asset
└── series/
    └── series-slug/
        └── _index.md           ← series description
```

### Folder naming convention

Every post lives in a **Page Bundle** following this pattern:

```
content/posts/yyyy/yyyy-mm-dd-slug/index.md
```

| Segment | Example | Description |
|---------|---------|-------------|
| `yyyy` | `2026` | Year (groups posts for easy navigation) |
| `yyyy-mm-dd` | `2026-04-13` | ISO date prefix (matches the `date` frontmatter) |
| `slug` | `astronight-gameplay` | Short, hyphenated descriptor |

Example: `content/posts/2026/2026-04-13-astronight-gameplay/index.md`

---

## Frontmatter Reference

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | **yes** | — | Post title displayed in cards and article header |
| `date` | date | **yes** | — | Publication date (`yyyy-mm-dd`). Posts with a future date are hidden unless `--buildFuture` is set |
| `draft` | bool | no | `false` | If `true`, post is hidden unless `--buildDrafts` is set |
| `tags` | list | no | `[]` | List of tags (rendered as cyan badges) |
| `series` | list | no | — | Slug of the series this post belongs to, e.g. `["astronight"]` |
| `episode` | int | if series set | — | Episode number within the series (used for ordering and display) |

Example:

```yaml
---
title: "AstroNight - Gameplay"
date: 2026-04-06
draft: false
tags: ["game", "unity"]
series: ["astronight"]
episode: 1
---
```

---

## Cover Images

Place a file named `cover.*` (any extension) inside the post's Page Bundle folder:

```
content/posts/2026/2026-04-06-astronight-gameplay/
├── index.md
└── cover.jpg      ← automatically detected and displayed
```

- Shown as a thumbnail on post cards (150 × 110 px, object-fit cover)
- Shown as a full-width banner at the top of the article page (16:9 ratio with scanline overlay)
- If no cover file is found, a dark grid placeholder is shown instead

---

## Adding a New Post

Use `hugo new` with the Page Bundle archetype:

```bash
hugo new posts/2026/2026-04-20-my-new-post/index.md
```

This creates `content/posts/2026/2026-04-20-my-new-post/index.md` pre-filled with the archetype from `archetypes/posts.md`. The post is created as `draft: true` by default.

To attach the post to a series, uncomment and fill in the `series` and `episode` fields.

---

## Series

A series is a Hugo taxonomy. To create a new series:

1. Add a folder under `content/series/`:

```
content/series/my-series/
└── _index.md
```

2. `_index.md` frontmatter:

```yaml
---
title: "My Series"
description: "A short description shown on the series index page."
---
```

3. In each episode's frontmatter:

```yaml
series: ["my-series"]
episode: 1
```

Series pages are available at `/series/` (index) and `/series/my-series/` (episode list).

---

## Video Embeds

Use the custom `video` shortcode for self-hosted WebM/MP4 files placed in the Page Bundle:

```markdown
{{< video src="my-clip.mp4" >}}
```

For YouTube:

```markdown
{{< youtube VIDEO_ID >}}
```

### Converting images to AVIF

```bash
./scripts/convert-media.sh              # converts all JPG/PNG under content/
./scripts/convert-media.sh content/posts/2026/my-post   # single post
```

---

## Deployment

The site deploys automatically to GitHub Pages on every push to `main` via `.github/workflows/static.yml`.

Build command: `hugo --minify`  
Output directory: `public/`
