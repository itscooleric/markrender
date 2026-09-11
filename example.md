# MarkRender Example

A compact sample document used both for demonstration and CI smoke testing.

> Markdown remains the source of truth. HTML and PDF are disposable renderings.

## What it handles

- headings and ordinary prose
- **bold**, *italic*, and `inline code`
- fenced code blocks
- tables
- blockquotes
- task lists
- local images and links

## Example table

| Artifact | Purpose | Output |
|---|---|---|
| Markdown | Source | `.md` |
| HTML | Browser/shareable | `.html` |
| PDF | Fixed document | `.pdf` |

## Example code

```bash
docker compose run --rm render example.md both
```

## Checklist

- [x] Dark HTML
- [x] Dark PDF
- [x] One CSS theme
- [x] Dockerized toolchain
