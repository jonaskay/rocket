---
name: pr.submit
description: Commit all changes and submit a pull request
argument-hint: [issue-number]
---

Stage and commit all changes to Git. Leave `fix_todos.md` and `human_todos.md` out from the commit if the files exist. Update `docs/feature_list.json`.

Submit current branch as a pull request for GitHub issue $ARGUMENTS. Add one sentence description, impact level, link to the walkthrough demo (`docs/issues/$ARGUMENTS/demo.md`), and acceptance criteria to the content, and a reference to the issue and nothing else.

Impact level has three categories and measures the possibility of the app breaking for end users:
1. High impact: Changes to existing controllers and class methods that can cause existing features to break. Migrations contain data destroying actions.
2. Medium impact: Changes contain only new controllers and class methods. Existing features are likely not to break.
3. Low impact: All of the changes are limited to development environments and test runs. Features remain untouched.

If `docs/issues/$ARGUMENTS/fix_todos.md` and `docs/issues/$ARGUMENTS/human_todos.md` files exist, add them as separate comments to the pull request. After that, delete the files.
