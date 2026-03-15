---
name: draft-issue
description: Generate an issue draft for a feature
argument-hint: [details]
---

Generate an issue for a feature. See if the issue contains installing or adding new dependencies or scaffolding files using install generators. Mark those steps as human todos. Using the rails generate for migrations and models are not human todos. Running migrations are not human todos.

Move it to a markdown file `docs/issues/FEATURE.local.md`. See `docs/issues/issue.example.md` for an example issue format.

Every system test is expensive. Pick only one critical path to test as a system test. Write the system and integration test cases using Gherkin. Use third-person point of view for Gherkin test cases. Do not use literal URLs ("/session/new") but path or page names ("sign-in page"). Authorization and authentication testing is not part of integration tests but controller tests. Controller tests are not included in the issue description.

Details:
$ARGUMENTS
