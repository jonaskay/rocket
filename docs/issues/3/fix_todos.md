# Issue #3 — Super Admin Authentication: Fix Todos

## Validation Results

- **Tests**: 18/18 pass, 0 failures, 0 errors
- **Rubocop**: No offenses
- **Herb lint**: No issues

## Acceptance Criteria

All acceptance criteria from the issue are met:

- [x] Login form at `/session/new` with email field, password field, and forgot-password link
- [x] Valid super admin credentials redirect to admin home page
- [x] Admin home page accessible only to authenticated super admins
- [x] `/admin` while signed out redirects to login page
- [x] Logout destroys session and redirects away from protected content
- [x] Revisiting `/admin` after logout redirects to login page
- [x] Non-admin users redirected away from `/admin` with a flash notice
- [x] Login form rendered at generator-provided route (`/session/new`)
- [x] Password reset routes reachable from login page

## Bugs

- [ ] **`config/database.yml` has accidental change**
  The development database name was changed from `rocket_development` to `rocket_development_tmp`. This is clearly a local development artifact and must be reverted before merging.

## Test gaps

- [ ] **Missing integration test for admin user with return_url flow**
  There is no test covering: admin visits `/admin` while unauthenticated → redirected to login → logs in → redirected back to `/admin` via the stored `return_to_after_authenticating` URL. The existing `admin user is redirected to admin home after login` test only covers the fallback (no return_url set). Adding this test would verify the return_url path works correctly for admin users.

- [ ] **`after_authentication_url` does not filter non-admin return URLs for admin users**
  The method correctly strips `/admin` return URLs for non-admin users (line 30 of `sessions_controller.rb`), but does not apply the inverse filter for admin users. If an admin's `return_to_after_authenticating` points to a non-admin path (e.g., `/up`), they will be redirected there instead of the admin namespace. This may be intentional, but given the issue states "super admins must be confined to the `/admin` namespace", consider filtering non-admin return URLs for admin users (similar to how admin return URLs are filtered for non-admin users) and adding a test for this case.

## Minor improvements

_None._
