# Local Frontend Preview

This repo uses Modern Campus `.pcf` and XSLT 3.0, which cannot be faithfully rendered with PHP's built-in `XSLTProcessor`.

Instead of rendering `.pcf` files locally, use published HTML fixtures for frontend development.

## Start the preview server

From the repo root:

```bash
php -S 127.0.0.1:8080 -t preview preview/router.php
```

Then open:

```text
http://127.0.0.1:8080/?fixture=sample-home.html
```

## Add real fixtures

1. Publish a representative page from Modern Campus.
2. Save the final HTML into `fixtures/`.
3. Open it with:

```text
http://127.0.0.1:8080/?fixture=path/to/file.html
```

Examples:

```text
http://127.0.0.1:8080/?fixture=dept-home/home.html
http://127.0.0.1:8080/?fixture=dept-inside/about.html
http://127.0.0.1:8080/?fixture=landing/program.html
```

## What the preview app does

- reads saved fixture HTML from `fixtures/`
- rewrites `/_resources/...` links to local `../_resources/...`
- rewrites `/scripts/...` links to local `../scripts/...`
- injects a small preview banner so it's obvious you are viewing a fixture

## Raw mode

To see the fixture without path rewriting or banner injection:

```text
http://127.0.0.1:8080/?fixture=sample-home.html&mode=raw
```

## Recommended workflow

- iterate locally against fixtures for layout, CSS, JS, and component work
- update XSL/includes after the frontend direction is stable
- validate final behavior in Modern Campus preview/publish
