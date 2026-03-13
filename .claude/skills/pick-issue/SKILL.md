---
name: pick-issue
description: Pick and issue to work on
argument-hint: [issue-number]
---

Pick GitHub issue $ARGUMENTS.

If the issue contains human todos, move them into `docs/issues/ISSUE_NUMBER/human_todos.md`. Use `docs/issues/1/human_todos.md` as a template.

Open a new Git branch for the issue (`issue-ISSUE_NUMBER-FEATURE`).
