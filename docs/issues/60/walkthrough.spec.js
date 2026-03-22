const { chromium } = require('@playwright/test');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'http://localhost:3000';
const DOCS_DIR = path.join(__dirname);

async function screenshot(page, name) {
  const filePath = path.join(DOCS_DIR, `${name}.png`);
  await page.screenshot({ path: filePath, fullPage: true });
  console.log(`Screenshot: ${name}.png`);
}

(async () => {
  const browser = await chromium.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    recordVideo: {
      dir: DOCS_DIR,
      size: { width: 1280, height: 800 },
    },
  });

  const page = await context.newPage();

  // --- Step 1: Sign in ---
  console.log('Step 1: Sign in');
  await page.goto(`${BASE_URL}/session/new`);
  await page.waitForSelector('input[name="email_address"]');
  await screenshot(page, '01-sign-in');

  await page.fill('input[name="email_address"]', 'admin@acme.com');
  await page.fill('input[name="password"]', 'password');
  await screenshot(page, '02-sign-in-filled');

  await page.click('input[type="submit"]');
  await page.waitForLoadState('networkidle');
  await screenshot(page, '03-account-settings');

  // --- Step 2: Navigate to Trainer Roster ---
  console.log('Step 2: Navigate to Trainer Roster');
  await page.click('text=Trainer Roster');
  await page.waitForURL(`${BASE_URL}/account/trainers`);
  await page.waitForLoadState('networkidle');
  await screenshot(page, '04-trainer-roster');

  // --- Step 3: Invite Trainer form ---
  console.log('Step 3: Invite Trainer form');
  await page.click('text=Invite Trainer');
  await page.waitForLoadState('networkidle');
  await screenshot(page, '05-invite-trainer-form');

  await page.fill('input[name="user[first_name]"]', 'Grace');
  await page.fill('input[name="user[last_name]"]', 'Hopper');
  await page.fill('input[name="user[email_address]"]', 'grace@acme.com');
  await screenshot(page, '06-invite-form-filled');

  // Cancel back to roster
  await page.click('text=Cancel');
  await page.waitForURL(`${BASE_URL}/account/trainers`);
  await page.waitForLoadState('networkidle');

  // --- Step 4: Deactivate an active trainer ---
  // Use bob@acme.com (currently Active in dev DB)
  console.log('Step 4: Deactivate trainer');
  const activeTrainerEmail = 'bob@acme.com';
  const activeRow = page.locator('tr', { hasText: activeTrainerEmail });

  page.once('dialog', dialog => {
    console.log(`  Dialog accepted: ${dialog.message().substring(0, 60)}`);
    dialog.accept();
  });

  await activeRow.locator('button', { hasText: 'Deactivate' }).click();
  await page.waitForSelector('div:has-text("deactivated")', { timeout: 10000 });
  await screenshot(page, '07-trainer-deactivated');

  // --- Step 5: Reactivate the trainer ---
  console.log('Step 5: Reactivate trainer');
  const inactiveRow = page.locator('tr', { hasText: activeTrainerEmail });

  page.once('dialog', dialog => {
    console.log(`  Dialog accepted: ${dialog.message().substring(0, 60)}`);
    dialog.accept();
  });

  await inactiveRow.locator('button', { hasText: 'Reactivate' }).click();
  await page.waitForSelector('div:has-text("reactivated")', { timeout: 10000 });
  await screenshot(page, '08-trainer-reactivated');

  // --- Step 6: Remove a trainer (trainer1 is currently inactive) ---
  console.log('Step 6: Remove trainer');
  const removeTrainerEmail = 'trainer1@acme.com';
  const removeRow = page.locator('tr', { hasText: removeTrainerEmail });

  page.once('dialog', dialog => {
    console.log(`  Dialog accepted: ${dialog.message().substring(0, 60)}`);
    dialog.accept();
  });

  await removeRow.locator('button', { hasText: 'Remove' }).click();
  await page.waitForSelector('div:has-text("removed")', { timeout: 10000 });
  await screenshot(page, '09-trainer-removed');

  // Close context and save video
  await page.close();
  await context.close();
  await browser.close();

  // Rename the newly created video file to walkthrough.webm
  const files = fs.readdirSync(DOCS_DIR)
    .filter(f => f.endsWith('.webm') && f !== 'walkthrough.webm')
    .map(f => ({ name: f, mtime: fs.statSync(path.join(DOCS_DIR, f)).mtimeMs }))
    .sort((a, b) => b.mtime - a.mtime); // newest first

  if (files.length > 0) {
    const videoFile = path.join(DOCS_DIR, files[0].name);
    const dest = path.join(DOCS_DIR, 'walkthrough.webm');
    if (fs.existsSync(dest)) fs.unlinkSync(dest);
    fs.renameSync(videoFile, dest);
    console.log('Video saved as walkthrough.webm');
  }

  console.log('Walkthrough complete!');
})();
