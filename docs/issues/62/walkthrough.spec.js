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

  // --- Step 2: Fill trainer credentials ---
  console.log('Step 2: Fill trainer credentials');
  await page.fill('input[name="email_address"]', 'trainer1@acme.com');
  await page.fill('input[type="password"]', 'password');
  await screenshot(page, '02-sign-in-filled');

  await page.click('input[type="submit"]');
  await page.waitForURL(`${BASE_URL}/master_trainings`);
  await page.waitForLoadState('networkidle');

  // --- Step 3: Master Trainings Dashboard (with trainings) ---
  console.log('Step 3: Master Trainings Dashboard');
  await screenshot(page, '03-master-trainings-dashboard');

  // --- Step 4: Sign out as trainer ---
  console.log('Step 4: Sign out as trainer');
  const signOutButton = page.locator('button', { hasText: 'Sign out' })
    .or(page.locator('a', { hasText: 'Sign out' }));
  if (await signOutButton.count() > 0) {
    await signOutButton.first().click();
    await page.waitForURL(`${BASE_URL}/session/new`);
    await page.waitForLoadState('networkidle');
  } else {
    await page.goto(`${BASE_URL}/session`);
    await page.evaluate(() => {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '/session';
      const methodInput = document.createElement('input');
      methodInput.name = '_method';
      methodInput.value = 'DELETE';
      form.appendChild(methodInput);
      document.body.appendChild(form);
      form.submit();
    });
    await page.waitForURL(`${BASE_URL}/session/new`);
  }

  // --- Step 5: Sign in as client admin ---
  console.log('Step 5: Sign in as client admin');
  await page.goto(`${BASE_URL}/session/new`);
  await page.waitForSelector('input[name="email_address"]');
  await page.fill('input[name="email_address"]', 'admin@acme.com');
  await page.fill('input[type="password"]', 'password');
  await page.click('input[type="submit"]');
  await page.waitForLoadState('networkidle');
  await screenshot(page, '04-admin-redirected');

  // --- Step 6: Try to access Master Trainings as admin (should redirect) ---
  console.log('Step 6: Admin attempts to access master trainings');
  await page.goto(`${BASE_URL}/master_trainings`);
  await page.waitForLoadState('networkidle');
  await screenshot(page, '05-admin-access-denied');

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
