# MarkRender

[![CI](https://github.com/itscooleric/markrender/actions/workflows/ci.yml/badge.svg)](https://github.com/itscooleric/markrender/actions/workflows/ci.yml)

Render Markdown into a **self-contained dark HTML document** and a matching **dark PDF** with one Dockerized toolchain.

HTML is the canonical rendered artifact. The PDF is generated from that same HTML and CSS, so there is one theme to maintain and one source document to write.

## Why MarkRender

MarkRender is meant for briefs, agendas, POA&Ms, reports, notes, technical write-ups, and other documents where Markdown is the source of truth but a polished shareable artifact is useful.

- Markdown in; HTML, PDF, or both out
- intentionally dark HTML **and** dark PDF
- self-contained HTML with resolvable resources embedded
- Dockerized Pandoc + WeasyPrint toolchain
- no LaTeX, Node, browser automation, or host document tooling
- VS Code tasks included
- works on amd64 and arm64 Docker hosts
- local CSS theme; no CDN assets
- source directory structure preserved under `_rendered/`

## Quick start

Requirements: Docker with Compose v2.

```bash
git clone https://github.com/itscooleric/markrender.git
cd markrender
docker compose build
docker compose run --rm render example.md both
```

Outputs:

```text
_rendered/example.html
_rendered/example.pdf
```

## Commands

Render HTML + PDF:

```bash
docker compose run --rm render example.md both
```

PDF only:

```bash
docker compose run --rm render example.md pdf
```

HTML only:

```bash
docker compose run --rm render example.md html
```

Render every Markdown file beneath a directory:

```bash
docker compose run --rm render docs both
```

Render the whole repository:

```bash
docker compose run --rm render . both
```

## Use MarkRender from another repository

The wrapper in `bin/markrender` mounts your **current working directory** into the renderer while keeping the Docker configuration here.

From another project:

```bash
/path/to/markrender/bin/markrender docs/proposal.md both
```

For a convenient global command, symlink it somewhere already on your `PATH`:

```bash
ln -s /path/to/markrender/bin/markrender ~/.local/bin/markrender
```

Then, from any repository:

```bash
markrender docs/proposal.md both
```

The output lands in that repository's `_rendered/` directory.

## VS Code

This repository includes tasks for:

- `Markdown: Render current file (HTML + PDF)`
- `Markdown: Render current file (PDF only)`
- `Markdown: Render all (HTML + PDF)`
- `Markdown: Build renderer image`

Use **Tasks: Run Task** with a Markdown file open.

For another repository, if `markrender` is on your `PATH`, a minimal task is:

```json
{
  "label": "Markdown: Render current file",
  "type": "shell",
  "command": "markrender \"${relativeFile}\" both",
  "options": { "cwd": "${workspaceFolder}" },
  "problemMatcher": []
}
```

## How it works

```text
Markdown
   |
   v
 Pandoc
   |
   v
self-contained HTML  <--- browser/shareable artifact
   |
   v
WeasyPrint
   |
   v
 dark PDF
```

The image currently pins:

- Pandoc `3.10.1`
- WeasyPrint `70.0`

Version pins live as Docker build arguments in `compose.yaml` and `Dockerfile`.

## Theme

Edit `theme-dark.css` to change the palette, typography, page margins, or paper size.

The default PDF size is US Letter:

```css
@page {
  size: Letter;
}
```

For A4:

```css
@page {
  size: A4;
}
```

The generated PDF has a real dark page background; it does not depend on the PDF viewer's dark-mode setting.

## Output directory

By default, generated artifacts are written beneath:

```text
_rendered/
```

The source path is preserved. For example:

```text
docs/briefs/proposal.md
```

becomes:

```text
_rendered/docs/briefs/proposal.html
_rendered/docs/briefs/proposal.pdf
```

Override the container output root with `OUTPUT_DIR` if needed.

## Local resources and network access

For portable HTML, Pandoc embeds resources it can resolve. Prefer local images and assets for deterministic/offline rendering.

If a Markdown document references remote resources, the renderer may need network access while building the document. MarkRender itself does not require CDN assets.

## Security note

MarkRender is a renderer, **not a sandbox for hostile documents**. Only render Markdown/HTML you trust, especially when a repository contains files that should not be incorporated into output. The container can read the directory mounted at `/work` and rendering engines may resolve resources referenced by the document.

## Slides

MarkRender intentionally targets documents, not slide semantics. For Markdown-first presentations, use a dedicated tool such as Marp rather than forcing one layout model to do both jobs.

## Contributing

Small fixes and focused improvements are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## License

MIT. See [`LICENSE`](LICENSE).
