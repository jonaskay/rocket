const { chromium } = require('@playwright/test');
const path = require('path');
const fs = require('fs');

const BASE_URL = 'http://localhost:3000';
const DOCS_DIR = path.join(__dirname);

async function screenshot(page, name) {
  const filePath = path.join(DOCS_DIR, `${name}.png`);
  await page.screenshot({ path: filePath, fullPage: true });
  console.log(`Screenshot saved: ${name}.png`);
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

  // --- Step 1: Sign in page ---
  console.log('Step 1: Sign in');
  await page.goto(`${BASE_URL}/session/new`);
  await page.waitForSelector('input[name="email_address"]');
  await screenshot(page, '01-sign-in');

  // --- Step 2: Fill credentials ---
  console.log('Step 2: Fill credentials');
  await page.fill('input[name="email_address"]', 'admin@acme.com');
  await page.fill('input[type="password"]', 'password');
  await screenshot(page, '02-sign-in-filled');

  await page.click('input[type="submit"]');
  await page.waitForLoadState('networkidle');

  // --- Step 3: Account Settings (landing page after sign-in) ---
  console.log('Step 3: Account Settings');
  await screenshot(page, '03-account-settings');

  // --- Step 4: Navigate to Trainer Roster ---
  console.log('Step 4: Navigate to Trainer Roster');
  await page.click('text=Trainer Roster');
  await page.waitForURL(`${BASE_URL}/account/trainers`);
  await page.waitForLoadState('networkidle');
  await screenshot(page, '04-trainer-roster');

  // --- Step 5: Click Remove on trainer1@acme.com ---
  console.log('Step 5: Click Remove button');
  const trainerEmail = 'trainer1@acme.com';
  const trainerRow = page.locator('tr', { hasText: trainerEmail });

  // Register dialog handler before clicking (accept without screenshot to avoid timeout)
  page.once('dialog', async (dialog) => {
    console.log(`  Confirmation dialog: "${dialog.message()}"`);
    await dialog.accept();
  });

  await trainerRow.locator('button', { hasText: 'Remove' }).click();

  // --- Step 6: Success flash after removal ---
  console.log('Step 6: Wait for success flash');
  await page.waitForSelector('text=has been removed', { timeout: 10000 });
  await screenshot(page, '05-trainer-removed');

  // Close and save video
  await page.close();
  await context.close();
  await browser.close();

  // Rename the video to walkthrough.webm
  const files = fs.readdirSync(DOCS_DIR)
    .filter(f => f.endsWith('.webm') && f !== 'walkthrough.webm')
    .map(f => ({ name: f, mtime: fs.statSync(path.join(DOCS_DIR, f)).mtimeMs }))
    .sort((a, b) => b.mtime - a.mtime);

  if (files.length > 0) {
    const src = path.join(DOCS_DIR, files[0].name);
    const dest = path.join(DOCS_DIR, 'walkthrough.webm');
    if (fs.existsSync(dest)) fs.unlinkSync(dest);
    fs.renameSync(src, dest);
    console.log('Video saved as walkthrough.webm');
  }

  console.log('Walkthrough complete!');
})();
