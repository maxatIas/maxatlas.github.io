---
title: "Content Writing Guide"
date: 2007-04-22
draft: true
tags: ["meta", "guide"]
showMeta: false
---

This page is a quick reference for writing posts on this site. Keep it as a draft — it is for internal use only.

---

## Frontmatter

Every post starts with a YAML frontmatter block between `---` delimiters.

```yaml
---
title: "My Post Title"
date: 2026-04-22
draft: false
tags: ["unity", "game-design"]
series: ["my-series"]
episode: 1
showMeta: false
---
```

| Field | Required | Notes |
|-------|----------|-------|
| `title` | yes | Shown in cards and article header |
| `date` | yes | `YYYY-MM-DD` — future dates hidden in prod unless `--buildFuture` |
| `draft` | no | `true` hides the post in prod |
| `tags` | no | Rendered as cyan badges |
| `series` | no | Slug of the series, e.g. `["astronight"]` |
| `episode` | if series | Integer, used for ordering and prev/next nav |
| `showMeta` | no | Set `false` to hide date and reading time |

---

## Text Formatting

```markdown
**bold text**
*italic text*
~~strikethrough~~
`inline code`
```

**bold text**, *italic text*, ~~strikethrough~~, `inline code`

---

## Headings

```markdown
## Section heading
### Sub-section heading
#### Smaller heading
```

Use `##` for main sections. Avoid `#` (that is the article title). Go no deeper than `####`.

---

## Lists

**Unordered:**

```markdown
- First item
- Second item
  - Nested item
```

- First item
- Second item
  - Nested item

**Ordered:**

```markdown
1. First step
2. Second step
3. Third step
```

1. First step
2. Second step
3. Third step

**Ordered with sub-levels (a, b, c):**

Nested items still use numbers in the source — CSS renders sub-levels as `a. b. c.` automatically.

```markdown
1. First item
   1. Sub-item A
   2. Sub-item B
2. Second item
   1. Sub-item A
   2. Sub-item B
   3. Sub-item C
3. Third item
```

1. First item
   1. Sub-item A
   2. Sub-item B
2. Second item
   1. Sub-item A
   2. Sub-item B
   3. Sub-item C
3. Third item

---

## Links

**External link:**

```markdown
[Link text](https://example.com)
```

[Link text](https://example.com)

**Internal link — use `ref` to get a build-time checked URL:**

```markdown
[my previous AstroNight post]({{</* ref "posts/2026/2026-04-06-astronight-gameplay" */>}})
```

[my previous AstroNight post]({{< ref "posts/2026/2026-04-06-astronight-gameplay" >}})

Hugo will error at build time if the target page does not exist — which prevents silent broken links.

---

## Images

Place the image file in the post's folder (next to `index.md`), then reference it by filename:

```markdown
![Alt text](help.avif)
```

![A screenshot used as an example](help.avif)

A file named `cover.*` in the post folder is automatically used as the article banner and card thumbnail — no frontmatter needed.

Prefer AVIF format. Run the conversion script if you have JPG/PNG:

```bash
./scripts/convert-media.sh content/posts/2026/my-post
```

---

## Tables

```markdown
| Column A | Column B | Column C |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value 4  | Value 5  | Value 6  |
```

| Column A | Column B | Column C |
|----------|----------|----------|
| Value 1  | Value 2  | Value 3  |
| Value 4  | Value 5  | Value 6  |

**With alignment:**

```markdown
| Left     |  Centre  |    Right |
|:---------|:--------:|---------:|
| a        |    b     |        c |
```

| Left     |  Centre  |    Right |
|:---------|:--------:|---------:|
| a        |    b     |        c |

---

## Code

**Inline code** — wrap in single backticks:

```markdown
Use the `hugo server` command to preview.
```

Use the `hugo server` command to preview.

**Code block** — wrap in triple backticks and specify the language:

````markdown
```go
func main() {
    fmt.Println("Hello, world!")
}
```
````

```go
func main() {
    fmt.Println("Hello, world!")
}
```

Common language identifiers: `go`, `js`, `ts`, `python`, `bash`, `yaml`, `json`, `html`, `css`, `csharp`, `markdown`.

---

## Blockquotes

```markdown
> This is a blockquote.
> It can span multiple lines.
```

> This is a blockquote.
> It can span multiple lines.

---

## Horizontal Rule

```markdown
I'm a paragraph **above** the line.

---

I'm a paragraph **below** the line.
```

Use sparingly to separate major sections:

I'm a paragraph **above** the line.

---

I'm a paragraph **below** the line.

---

## Self-Hosted Video

Place a `.mp4` or `.webm` file in the post folder, then use the shortcode:

```markdown
{{</* video src="astronight-game.mp4" */>}}
```

The video plays silently on loop (autoplay, muted, no controls) — good for gameplay captures and timelapses.

{{< video src="/posts/2026/2026-04-06-astronight-gameplay/astronight-game.mp4" >}}

---

## YouTube Embed

Use the built-in Hugo shortcode with the video ID (the part after `?v=` in the URL):

```markdown
{{</* youtube dQw4w9WgXcQ */>}}
```

For `https://www.youtube.com/watch?v=dQw4w9WgXcQ`, the ID is `dQw4w9WgXcQ`.

{{< youtube dQw4w9WgXcQ >}}

---

## Series

To group posts into a series:

1. Create `content/series/my-series/_index.md`:

```yaml
---
title: "My Series"
description: "A short description shown on the series page."
---
```

2. In each episode's frontmatter:

```yaml
series: ["my-series"]
episode: 1
```

Episodes are ordered by `episode` number. Prev/next navigation appears automatically at the bottom of each post.

---

## Creating a New Post

```bash
hugo new posts/YYYY/YYYY-MM-DD-slug/index.md
```

This creates a draft. Set `draft: false` when ready to publish.

---

## Preview Locally

```bash
# Show drafts and future-dated posts
hugo server --buildDrafts --buildFuture
```

Open `http://localhost:1313/` in your browser. The page live-reloads on every save.
