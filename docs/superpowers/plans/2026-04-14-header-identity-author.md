# Header Identity & Author Block Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a configurable avatar+title+motto to the nav logo, and an author block (avatar, name, description) below the article date, both driven by `hugo.toml` params with per-post frontmatter override.

**Architecture:** Config params feed two Hugo partials (`nav.html`, `single.html`). CSS changes are confined to the single file `themes/maxatlas/assets/css/main.css`. No new files are created.

**Tech Stack:** Hugo templates (Go template syntax), TOML config, CSS custom properties.

---

## File Map

| File | Change |
|------|--------|
| `static/img/` | Commit untracked image files (max.avif, max-800x800.avif) |
| `hugo.toml` | Add `headerTitle`, `headerImg`, `motto`, `author`, `authorDesc`, `avatar` under `[params]` |
| `themes/maxatlas/layouts/partials/nav.html` | Replace static text logo with dynamic avatar+title+motto block |
| `themes/maxatlas/layouts/_default/single.html` | Add author block after `.article__meta` |
| `themes/maxatlas/assets/css/main.css` | Refactor `.nav__logo` styles; add `.nav__logo-img`, `.nav__logo-text`, `.nav__logo-title`, `.nav__logo-motto`, `.article__author`, `.author__avatar`, `.author__info`, `.author__name`, `.author__desc` |

> **Naming note:** `[params].description` is already used as the site tagline ("Dev articles with a gaming soul"). The author's description uses the key `authorDesc` to avoid collision. Per-post frontmatter also uses `authorDesc`.

---

## Task 0: Commit static images

**Files:**
- Commit: `static/img/max.avif`, `static/img/max-800x800.avif`

- [ ] **Step 1: Verify which images are present**

```bash
ls static/img/
```
Expected output includes: `max.avif`, `max-800x800.avif`

- [ ] **Step 2: Commit the images**

```bash
git add static/img/
git commit -m "feat: add avatar images to static/img"
```

---

## Task 1: Add params to hugo.toml

**Files:**
- Modify: `hugo.toml`

- [ ] **Step 1: Replace the `[params]` block**

Open `hugo.toml`. The current block is:
```toml
[params]
  description = "Dev articles with a gaming soul"
```

Replace with:
```toml
[params]
  description = "Dev articles with a gaming soul"

  # Nav identity
  headerTitle = "MAXATLAS"
  headerImg   = "/img/max-800x800.avif"
  motto       = "Game Developer"

  # Default author (overridable per post via frontmatter)
  author     = "Max Pilato"
  authorDesc = "Game Developer"
  avatar     = "/img/max-800x800.avif"
```

- [ ] **Step 2: Verify Hugo parses the config without errors**

Run:
```bash
hugo --gc --minify 2>&1 | head -20
```
Expected: build completes, zero `ERROR` lines. `WARN` about unused params is fine.

- [ ] **Step 3: Commit**

```bash
git add hugo.toml
git commit -m "feat: add header identity and author params to hugo.toml"
```

---

## Task 2: Nav header identity

**Files:**
- Modify: `themes/maxatlas/layouts/partials/nav.html`
- Modify: `themes/maxatlas/assets/css/main.css` (Nav section only)

### Nav template

- [ ] **Step 1: Replace nav.html**

Replace the entire content of `themes/maxatlas/layouts/partials/nav.html` with:

```html
<nav class="nav">
  <a class="nav__logo" href="{{ "/" | relURL }}">
    {{- with site.Params.headerImg }}
    <img src="{{ . }}" alt="{{ site.Params.headerTitle | default site.Title }}" class="nav__logo-img">
    {{- end }}
    <span class="nav__logo-text">
      <span class="nav__logo-title">{{ site.Params.headerTitle | default site.Title }}</span>
      {{- with site.Params.motto }}
      <span class="nav__logo-motto">{{ . }}</span>
      {{- end }}
    </span>
  </a>
  <ul class="nav__links">
    <li><a href="{{ "/posts/" | relURL }}"{{ if hasPrefix .RelPermalink "/posts" }} aria-current="page"{{ end }}>Blog</a></li>
    <li><a href="{{ "/series/" | relURL }}"{{ if hasPrefix .RelPermalink "/series" }} aria-current="page"{{ end }}>Series</a></li>
    <li><a href="{{ "/about/" | relURL }}"{{ if hasPrefix .RelPermalink "/about" }} aria-current="page"{{ end }}>About</a></li>
  </ul>
</nav>
```

### Nav CSS

- [ ] **Step 2: Replace the `/* ── Nav ── */` block in main.css**

Find the existing block (lines ~40–78):
```css
/* ── Nav ─────────────────────────────────────────────── */
.nav { ... }
.nav__logo { ... }   ← has text styles (font-family, color, text-shadow…)
.nav__links { ... }
.nav__links a { ... }
.nav__links a:hover, ... { ... }
```

Replace the entire Nav section with:

```css
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
  display: flex;
  align-items: center;
  gap: 0.5rem;
  text-decoration: none;
}

.nav__logo-img {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: 2px solid var(--accent-cyan);
  box-shadow: var(--glow-cyan);
  object-fit: cover;
  flex-shrink: 0;
}

.nav__logo-text {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.nav__logo-title {
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 1.125rem;
  font-weight: 700;
  color: var(--accent-cyan);
  text-shadow: var(--glow-cyan);
  letter-spacing: 0.125rem;
}

.nav__logo-motto {
  font-family: monospace;
  font-size: 0.6875rem;
  color: var(--text-muted);
  letter-spacing: 0.0625rem;
}

.nav__links {
  display: flex;
  gap: 1.25rem;
  list-style: none;
}

.nav__links a {
  font-family: monospace;
  font-size: 0.8125rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.0625rem;
  transition: color 0.15s ease;
}

.nav__links a:hover,
.nav__links a[aria-current="page"] { color: var(--accent-cyan); }
```

- [ ] **Step 3: Verify build**

```bash
hugo --gc --minify 2>&1 | head -20
```
Expected: zero `ERROR` lines.

- [ ] **Step 4: Visual check**

```bash
hugo server --buildDrafts --buildFuture
```
Open `http://localhost:1313/`. Verify:
- Avatar appears as a small circle with cyan ring in the top-left
- "MAXATLAS" title is in cyan monospace next to the avatar
- "Game Developer" appears below in muted grey
- Blog / Series / About links are still present and functional
- Active page link highlights in cyan

Kill the server (`Ctrl-C`).

- [ ] **Step 5: Commit**

```bash
git add themes/maxatlas/layouts/partials/nav.html themes/maxatlas/assets/css/main.css
git commit -m "feat: add avatar, title, and motto to nav header"
```

---

## Task 3: Author block in articles

**Files:**
- Modify: `themes/maxatlas/layouts/_default/single.html`
- Modify: `themes/maxatlas/assets/css/main.css` (append new section)

### Article template

- [ ] **Step 1: Add author block to single.html**

Open `themes/maxatlas/layouts/_default/single.html`. Find the `.article__meta` block:

```html
    {{ if ne .Params.showMeta false }}
    <div class="article__meta">
      {{ .Date.Format "January 2, 2006" }} · {{ .ReadingTime }} min read
    </div>
    {{ end }}
```

Replace with:

```html
    {{ if ne .Params.showMeta false }}
    <div class="article__meta">
      {{ .Date.Format "January 2, 2006" }} · {{ .ReadingTime }} min read
    </div>
    {{ end }}

    {{- $authorName   := .Params.author     | default site.Params.author -}}
    {{- $authorDesc   := .Params.authorDesc | default site.Params.authorDesc -}}
    {{- $authorAvatar := .Params.avatar     | default site.Params.avatar -}}
    {{ if or $authorName $authorAvatar }}
    <div class="article__author">
      {{ if $authorAvatar }}
      <img src="{{ $authorAvatar }}" alt="{{ $authorName }}" class="author__avatar">
      {{ end }}
      <div class="author__info">
        {{ if $authorName }}<span class="author__name">{{ $authorName }}</span>{{ end }}
        {{ if $authorDesc }}<span class="author__desc">{{ $authorDesc }}</span>{{ end }}
      </div>
    </div>
    {{ end }}
```

### Author CSS

- [ ] **Step 2: Append author styles to main.css**

At the end of `themes/maxatlas/assets/css/main.css`, append:

```css
/* ── Article author ──────────────────────────────────── */
.article__author {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  margin-bottom: 0.875rem;
}

.author__avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 2px solid var(--accent-cyan);
  box-shadow: var(--glow-cyan);
  object-fit: cover;
  flex-shrink: 0;
}

.author__info {
  display: flex;
  flex-direction: column;
  line-height: 1.3;
}

.author__name {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--text-primary);
}

.author__desc {
  font-family: monospace;
  font-size: 0.8125rem;
  color: var(--text-muted);
}
```

- [ ] **Step 3: Verify build**

```bash
hugo --gc --minify 2>&1 | head -20
```
Expected: zero `ERROR` lines.

- [ ] **Step 4: Visual check**

```bash
hugo server --buildDrafts --buildFuture
```
Open any article at `http://localhost:1313/posts/`. Verify:
- Below the date/reading-time line: circular avatar with cyan ring, "Max Pilato" in white, "Game Developer" in grey
- The author block does **not** appear on the About page (which uses `showMeta: false` — the block is gated independently, but check it doesn't leak)

Kill the server (`Ctrl-C`).

- [ ] **Step 5: Test frontmatter override**

Open any post's `index.md` and temporarily add:
```yaml
author: "Guest Author"
authorDesc: "Indie dev"
avatar: "/img/max.avif"
```
Run `hugo server --buildDrafts --buildFuture`, open that post, verify the override values appear. Revert the frontmatter change when done.

- [ ] **Step 6: Commit**

```bash
git add themes/maxatlas/layouts/_default/single.html themes/maxatlas/assets/css/main.css
git commit -m "feat: add author block below article date with config fallback"
```
