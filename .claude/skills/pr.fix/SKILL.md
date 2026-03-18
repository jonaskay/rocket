---
name: pr.fix
description: Fix failing jobs in a pull request
argument-hint: [pull-request-number]
---

Pull request #$ARGUMENTS has failing jobs. Fix them.

If `system-test` is failing, it's likely caused by flaky tests. Make sure tests are using `visit_and_confirm` instead of bare `visit`, `click_link_and_confirm` instead of bare `click_link`, and `click_button_and_confirm` instead of bare `click_button` to navigate to pages to assert page has loaded before continuing.
