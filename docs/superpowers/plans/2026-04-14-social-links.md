# Social Links on About Page — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Display a row of Ionicons social-link buttons at the bottom of the About page, sourced from `data/socials.toml`.

**Architecture:** A new `data/socials.toml` file holds the link definitions. A project-level `layouts/about/single.html` (which takes precedence over the theme's `_default/single.html`) injects the social row after the article body and loads Ionicons via CDN scripts scoped to this page only. CSS is appended to the existing `themes/maxatlas/assets/css/main.css`.

**Tech Stack:** Hugo (data templates, layout override), Ionicons 7 (web components via unpkg CDN).

---

## File Map

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `data/socials.toml` | Social link definitions (href, icon, title, target) |
| Create | `layouts/about/single.html` | About-specific layout with social block + Ionicons CDN |
| Edit   | `themes/maxatlas/assets/css/main.css` | `.social-links` and `.social-link` styles |

---

### Task 1: Create the social links data file

**Files:**
- Create: `data/socials.toml`

- [ ] **Step 1: Create `data/socials.toml`**

```toml
# Social links — displayed at the bottom of the About page.
# Icons: https://ionic.io/ionicons
[[socials]]
href   = "https://github.com/dadoonet"
target = "_blank"
icon   = "logo-github"
title  = "GitHub"

[[socials]]
href   = "https://x.com/dadoonet"
target = "_blank"
icon   = "logo-x"
title  = "X"

[[socials]]
href   = "https://bsky.app/profile/pilato.fr"
target = "_blank"
icon   = "logo-twitter"
title  = "BlueSky"

[[socials]]
href   = "https://www.linkedin.com/in/dadoonet"
target = "_blank"
icon   = "logo-linkedin"
title  = "LinkedIn"

[[socials]]
href   = "https://stackoverflow.com/users/1432281/dadoonet"
target = "_blank"
icon   = "logo-stackoverflow"
title  = "Stack Overflow"

[[socials]]
href   = "https://elastic.co/"
target = "_blank"
icon   = "business"
title  = "Elastic"

[[socials]]
href   = "https://podcasts.apple.com/fr/podcast/dj-elky-mixes/id959495351"
target = "_blank"
icon   = "musical-notes"
title  = "Podcast"

[[socials]]
href   = "https://www.instagram.com/dj_elky"
target = "_blank"
icon   = "logo-instagram"
title  = "DJ Elky"
```

- [ ] **Step 2: Verify Hugo can parse the data file**

Run:
```bash
hugo --gc --minify 2>&1 | head -20
```

Expected: build completes with `0 errors` (warnings about drafts are fine). If you see `Error: ... data/socials.toml`, check TOML syntax.

- [ ] **Step 3: Commit**

```bash
git add data/socials.toml
git commit -m "feat: add social links data file"
```

---

### Task 2: Create the about-specific layout with social block

**Files:**
- Create: `layouts/about/single.html`
- Reference (read-only): `themes/maxatlas/layouts/_default/single.html`

Hugo's lookup order means `layouts/about/single.html` (project root) beats `themes/maxatlas/layouts/_default/single.html` for the page at `content/about/index.md` whose `Type` resolves to `about`.

- [ ] **Step 1: Create `layouts/about/` directory and `single.html`**

Create `layouts/about/single.html` with the following content (copied from the theme's `single.html` and extended with the social block after `.article__body` and Ionicons scripts at the end of the `main` block):

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

<script type="module" src="https://unpkg.com/ionicons@7/dist/ionicons/ionicons.esm.js"></script>
<script nomodule src="https://unpkg.com/ionicons@7/dist/ionicons/ionicons.js"></script>
{{ end }}
```

- [ ] **Step 2: Verify the build still succeeds**

Run:
```bash
hugo --gc --minify 2>&1 | head -20
```

Expected: `0 errors`. If you see a template error mentioning `layouts/about/single.html`, check for unclosed `{{ if }}` or `{{ range }}` blocks.

- [ ] **Step 3: Verify the about page HTML contains the social block**

Run:
```bash
grep -A 5 "social-links" public/about/index.html
```

Expected output (8 `<a>` tags containing `ion-icon` elements):
```
<div class="social-links">

      <a href="https://github.com/dadoonet" target="_blank" title="GitHub"
         class="social-link" rel="noopener noreferrer">
        <ion-icon name="logo-github"></ion-icon>
```

- [ ] **Step 4: Verify Ionicons scripts are present in the about page only**

Run:
```bash
grep "ionicons" public/about/index.html
grep "ionicons" public/index.html
```

Expected: first command shows 2 script tags; second command produces no output.

- [ ] **Step 5: Commit**

```bash
git add layouts/about/single.html
git commit -m "feat: add about layout with social links block"
```

---

### Task 3: Add social links CSS

**Files:**
- Edit: `themes/maxatlas/assets/css/main.css` (append to end of file)

- [ ] **Step 1: Append the social links styles to `themes/maxatlas/assets/css/main.css`**

Add this block at the very end of the file:

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

- [ ] **Step 2: Rebuild and verify the CSS is included**

Run:
```bash
hugo --gc --minify 2>&1 | head -5
find public/ -name "*.css" -exec grep -l "social-link" {} \;
```

Expected: build with `0 errors`; `find` prints at least one CSS file path (the minified `main.css` processed by Hugo's asset pipeline).

- [ ] **Step 3: Commit**

```bash
git add themes/maxatlas/assets/css/main.css
git commit -m "feat: add social link styles to theme CSS"
```

---

### Task 4: Visual verification

- [ ] **Step 1: Start the dev server**

Run:
```bash
hugo server --buildDrafts --buildFuture
```

- [ ] **Step 2: Open the about page**

Navigate to `http://localhost:1313/about/` in a browser.

Expected:
- A row of square icon buttons appears below the article text, separated by a thin border line.
- Icons are visible (rendered by Ionicons web components — requires network access).
- Icons are muted grey at rest.
- On hover: icon turns cyan, border turns cyan, a glow appears.
- No icons appear on any other page (e.g. `/posts/`, `/`).

- [ ] **Step 3: Verify no regressions on other pages**

Check `http://localhost:1313/` (post list) and any existing post. Confirm layout is unchanged and no extra scripts are loaded.
