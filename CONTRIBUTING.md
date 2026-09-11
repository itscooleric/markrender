# Contributing

MarkRender is intentionally small. Contributions are most useful when they preserve that property.

## Before opening a pull request

1. Keep the Markdown -> HTML -> PDF pipeline understandable.
2. Avoid adding a host runtime requirement when the behavior can remain inside Docker.
3. Avoid CDN or network dependencies in generated documents by default.
4. Keep HTML and PDF on the same CSS/theme path.
5. Run the smoke test locally:

```bash
docker compose build
docker compose run --rm render example.md both
test -s _rendered/example.html
test -s _rendered/example.pdf
```

## Pull requests

A focused PR should explain:

- what changed;
- why the change belongs in MarkRender;
- how it was tested;
- whether output appearance changed.

If appearance changes, include a short description or screenshot/PDF comparison where useful.
