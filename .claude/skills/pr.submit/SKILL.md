---
name: pr.submit
description: Commit all changes and submit a pull request
argument-hint: [issue-number]
---

Stage and commit all changes to Git. Leave `fix_todos.md` and `human_todos.md` out from the commit if the files exist. Update `docs/feature_list.json`.

Submit current branch as a pull request for GitHub issue $ARGUMENTS. Add one sentence description, walkthrough video, acceptance criteria to the content, and a reference to the issue and nothing else.

If `docs/issues/$ARGUMENTS/fix_todos.md` and `docs/issues/$ARGUMENTS/human_todos.md` files exist, add them as separate comments to the pull request. After that, delete the files.
