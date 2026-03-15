---
name: review-fix
description: Review current fix for an issue
argument-hint: [issue-number]
---

Fix has been implemented for GitHub issue $ARGUMENTS.

Review and test the modified code. Do not fix anything. Submit findings as todos in a new markdown file `docs/issues/$ARGUMENTS/fix_todos.md`.  Use `docs/issues/1/fix_todos.example.md` as a template. Keep completed todos as is. Mark new findings under a new heading.
