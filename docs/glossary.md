# Glossary

Important domain terms for the Rocket training platform.

---

**Account Admin** — A user with `client_admin: true` who belongs to exactly one client organization. Can manage the organization's name, invite trainers, and deactivate or remove trainers within their account. Cannot access another client's data.

**Active Storage** — The Rails framework used for file attachments throughout the application. Configured with Google Cloud Storage (GCS) as the backend service.

**Client** — A tenant organization in the multi-tenant system (also referred to as a "client account"). Each client has one account admin and one or more trainers. Managed by super admins.

**Direct Upload** — A file upload method where files are sent directly from the browser to Google Cloud Storage using Active Storage's signed URL feature, bypassing the Rails server.

**Exercise** — Rich text content associated with a master training, authored using the Trix editor and stored via Action Text. Supports headings, bold, italic, lists, links, image attachments, and code formatting.

**Exercise Snapshot** — An immutable HTML copy of an exercise's rich text body captured at the time a training session is generated. Stored on the `exercise_snapshots` table as sanitized HTML.

**Invitation Flow** — The process by which an account admin adds a new trainer to their organization. The system creates the trainer's account with `status: pending_password_change` and sends an invitation email containing a signed, time-limited link for the trainer to set their own password.

**Master Training** — A reusable training template created and owned by a trainer. Contains slides, prerequisite assets, and exercises. Multiple training sessions can be generated from a single master training at different points in time.

**Password Gate** — The password entry page shown at `/s/:slug/unlock` when a training session is password-protected. Participants must submit the correct password before the session content is revealed.

**Prerequisite Asset** — A file of any type (PDF, video, ZIP, etc.) attached to a master training that participants are expected to review or download before the training session begins.

**Prerequisite Asset Snapshot** — An immutable reference to a prerequisite asset file captured in a version snapshot at the time a training session is generated.

**Session** — See *Training Session*.

**Session Cookie** — An HTTP-only cookie set for 24 hours when a participant successfully unlocks a password-protected training session. Grants continued access to the session view without re-entering the password.

**Session Slug** — A short, URL-safe base64 string (8 characters) auto-generated for each training session. Used as the unique identifier in the public session URL (`/s/:slug`).

**Session View** — The public-facing page at `/s/:slug` that renders a training session's snapshot content. No login is required (unless the session is password-protected). The view is read-only with no editing capabilities.

**Slide** — A presentation file (PDF or PPTX) attached to a master training. Uploaded via Active Storage's direct upload flow to GCS.

**Slide Snapshot** — An immutable reference to a slide file captured in a version snapshot at the time a training session is generated.

**Snapshot Service** — A Rails service object that atomically creates all snapshot records (version, slide snapshots, prerequisite asset snapshots, and exercise snapshots) within a single database transaction whenever a training session is generated.

**Status** — A user status enum with three values: `active` (can log in normally), `inactive` (soft-deactivated by an account admin; cannot log in), and `pending_password_change` (newly invited trainer who must set a password before accessing the application).

**Status Pill** — A color-coded inline badge displayed in the trainer roster to indicate a trainer's current status. Green indicates `active`, red indicates `inactive`, and yellow indicates `pending_password_change`.

**Super Admin** — A global system administrator identified by `super_admin: true` on the User model. Not associated with any client organization. Can create and delete client accounts.

**Training Session** — A generated, shareable instance of a master training based on a specific version snapshot. Identified by a unique session slug. Can optionally be password-protected. Deleting a session does not affect the master training or other sessions.

**Trainer** — A user belonging to exactly one client organization who creates master trainings, manages training content (slides, prerequisite assets, exercises), and generates training sessions.

**Trainer Roster** — The page at `/account/trainers` where account admins can view all non-admin users in their organization. Displays each trainer's email and a color-coded status pill.

**Trix Editor** — The rich text editor used for authoring exercise content, provided by Rails' Action Text library. Produces sanitized HTML output.

**Version Snapshot** — An immutable record of a master training's complete state at the moment a training session is generated. Captures the title, description, and ordered lists of slide file references, prerequisite asset references, and rendered exercise HTML. Editing the master training after a session is generated does not alter any existing version snapshots.
