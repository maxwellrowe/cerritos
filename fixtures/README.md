# Fixtures

Place published HTML files from Modern Campus in this folder for local frontend work.

Suggested structure:

- `fixtures/dept-home/sample.html`
- `fixtures/dept-inside/sample.html`
- `fixtures/landing/sample.html`
- `fixtures/photogallery/sample.html`

Notes:

- Save the final published HTML, not the `.pcf`.
- Keep linked assets in the main repo under `/_resources`.
- The preview app will rewrite root-relative `/_resources/...` and `/scripts/...` paths to local repo paths.
- `{{f:...}}` and similar Modern Campus tokens are stripped in preview mode, so published HTML is the best source.
