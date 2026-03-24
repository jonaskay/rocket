const { chromium } = require("playwright");
const path = require("path");
const fs = require("fs");

const BASE_URL = "http://localhost:3000";
const DOCS_DIR = path.join(__dirname);
const VIDEO_PATH = path.join(DOCS_DIR, "walkthrough.webm");

async function screenshot(page, name, description) {
  const filepath = path.join(DOCS_DIR, `${name}.png`);
  await page.screenshot({ path: filepath, fullPage: true });
  console.log(`Screenshot saved: ${name}.png — ${description}`);
}

async function acceptNextDialog(page) {
  return new Promise((resolve) => {
    page.once("dialog", async (dialog) => {
      await dialog.accept();
      resolve();
    });
  });
}

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  // Clean up old walkthrough video if present
  if (fs.existsSync(VIDEO_PATH)) fs.unlinkSync(VIDEO_PATH);

  const browser = await chromium.launch({
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
  });

  const context = await browser.newContext({
    recordVideo: { dir: DOCS_DIR, size: { width: 1280, height: 800 } },
    viewport: { width: 1280, height: 800 },
  });

  const page = await context.newPage();

  try {
    // ── Step 1: Sign in as Acme Corp admin ────────────────────────────────
    await page.goto(`${BASE_URL}/session/new`);
    await page.fill('[name="email_address"]', "admin@acme.com");
    await page.fill('[name="password"]', "password");
    await screenshot(page, "01-sign-in", "Sign-in form filled as Acme Corp admin");

    await page.click('input[type="submit"]');
    await page.waitForURL(/account\/settings/);
    await sleep(600);

    // ── Step 2: Account settings ───────────────────────────────────────────
    await screenshot(page, "02-account-settings", "Account Settings — shows Acme Corp name only");

    // ── Step 3: Navigate to Trainer Roster ────────────────────────────────
    await page.click('a:has-text("Trainer Roster")');
    await page.waitForURL(/account\/trainers/);
    await sleep(600);
    await screenshot(page, "03-trainer-roster", "Trainer Roster — only Acme Corp trainers visible");

    // ── Step 4: Deactivate Alice Smith ────────────────────────────────────
    const aliceRow = page.locator("tr", { hasText: "trainer1@acme.com" });
    await screenshot(page, "04-before-deactivate", "Alice Smith is Active — Deactivate button visible");

    // Register dialog handler before clicking
    const dialogAccepted = acceptNextDialog(page);
    await aliceRow.locator('button:has-text("Deactivate")').click();
    await dialogAccepted;
    await page.waitForResponse((r) => r.url().includes("/account/trainers/") && r.status() < 400);
    await sleep(600);
    await screenshot(page, "05-alice-deactivated", "Alice Smith now shows Inactive status");

    // ── Step 5: Reactivate Alice Smith ────────────────────────────────────
    const aliceRowUpdated = page.locator("tr", { hasText: "trainer1@acme.com" });
    const dialogAccepted2 = acceptNextDialog(page);
    await aliceRowUpdated.locator('button:has-text("Reactivate")').click();
    await dialogAccepted2;
    await page.waitForResponse((r) => r.url().includes("/account/trainers/") && r.status() < 400);
    await sleep(600);
    await screenshot(page, "06-alice-reactivated", "Alice Smith restored to Active status");

    // ── Step 6: Remove Bob Jones ──────────────────────────────────────────
    const bobRow = page.locator("tr", { hasText: "trainer2@acme.com" });
    await screenshot(page, "07-before-remove-bob", "Bob Jones (Inactive) — Remove button visible");

    const dialogAccepted3 = acceptNextDialog(page);
    await bobRow.locator('button:has-text("Remove")').click();
    await dialogAccepted3;
    await page.waitForResponse((r) => r.url().includes("/account/trainers/") && r.status() < 400);
    await sleep(600);
    await screenshot(page, "08-bob-removed", "Bob Jones removed — no longer in roster");

    // ── Step 7: Update organization name ─────────────────────────────────
    await page.goto(`${BASE_URL}/account/settings/edit`);
    await page.waitForURL(/account\/settings/);
    await sleep(500);

    // Clear field and type new name
    await page.fill('[name="client[name]"]', "");
    await page.fill('[name="client[name]"]', "Acme Corp (Updated)");
    await screenshot(page, "09-edit-org-name", "Editing organization name — only Acme Corp is updated");

    await page.click('input[type="submit"]');
    await page.waitForURL(/account\/settings/);
    await sleep(600);
    await screenshot(page, "10-org-name-saved", "Organization name saved successfully");

    // Restore name
    await page.fill('[name="client[name]"]', "Acme Corp");
    await page.click('input[type="submit"]');
    await sleep(400);

    // ── Step 8: Sign out ──────────────────────────────────────────────────
    await page.click('button:has-text("Sign out")');
    await page.waitForURL(/session/);
    await sleep(400);
    await screenshot(page, "11-signed-out", "Signed out — session terminated");

    console.log("\nAll screenshots saved!");
  } finally {
    await context.close();
    await browser.close();

    // Rename the generated video to walkthrough.webm
    const videoFiles = fs
      .readdirSync(DOCS_DIR)
      .filter((f) => f.endsWith(".webm") && f !== "walkthrough.webm");
    if (videoFiles.length > 0) {
      fs.renameSync(path.join(DOCS_DIR, videoFiles[0]), VIDEO_PATH);
      console.log("Video saved: walkthrough.webm");
    }
  }
}

main().catch(console.error);
