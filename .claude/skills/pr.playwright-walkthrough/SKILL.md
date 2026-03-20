---
name: pr.playwright-walkthrough
description: Generate a Playwright script for walking through the feature and record a video
argument-hint: [pull-request-number]
---

Read pull request #$ARGUMENTS and any related issue to understand the new feature.

Generate a Playwright Node.js script that walks through the feature end-to-end. The script must:
- Use `require('playwright')` (already available in the playwright container)
- Launch Chromium with `chromium.launch()`
- Create a context with `recordVideo: { dir: 'docs/issues/$ARGUMENTS/', size: { width: 1280, height: 720 } }`
- Navigate to `http://rails-app:3000` and walk through the feature step by step
- Call `await page.video().saveAs('docs/issues/$ARGUMENTS/walkthrough.webm')` before closing
- Close the context and browser when done

Save the script to `docs/issues/$ARGUMENTS/walkthrough.spec.js`.

Create the output directory if it does not exist:

```bash
mkdir -p docs/issues/$ARGUMENTS
```

Run the script in the playwright service container (the workspace is mounted at the same path inside the container):

```bash
docker compose -f .devcontainer/compose.yaml exec -w $(pwd) playwright node docs/issues/$ARGUMENTS/walkthrough.spec.js
```

Commit the video and add a link to it in the pull request body.
