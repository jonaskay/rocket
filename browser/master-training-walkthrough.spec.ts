import { test, expect } from '@playwright/test';
import path from 'path';
import fs from 'fs';

const BASE_URL = 'http://localhost:3000';
const SCREENSHOTS_DIR = path.join(__dirname, '../docs/issues/70');

const TRAINER_EMAIL = 'trainer1@acme.com';
const TRAINER_PASSWORD = 'password';

test.use({
  baseURL: BASE_URL,
  viewport: { width: 1280, height: 800 },
  video: { mode: 'on', dir: SCREENSHOTS_DIR },
});

async function screenshot(page: any, name: string) {
  await page.screenshot({ path: path.join(SCREENSHOTS_DIR, `${name}.png`) });
}

test('Master Training walkthrough', async ({ page }) => {
  fs.mkdirSync(SCREENSHOTS_DIR, { recursive: true });

  // Step 1: Sign-in page
  await page.goto(`${BASE_URL}/session/new`);
  await page.getByRole('textbox', { name: /email/i }).fill(TRAINER_EMAIL);
  await page.getByRole('textbox', { name: /password/i }).fill(TRAINER_PASSWORD);
  await screenshot(page, '01-sign-in');

  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('**/master_trainings');

  // Step 2: Index showing existing master trainings
  await expect(page.getByRole('heading', { name: 'Master Trainings' })).toBeVisible();
  await screenshot(page, '02-master-trainings-index');

  // Step 3: Navigate to new training form
  await page.getByRole('link', { name: 'New Master Training' }).click();
  await page.waitForURL('**/master_trainings/new');
  await expect(page.getByRole('heading', { name: 'New Master Training' })).toBeVisible();
  await screenshot(page, '03-new-master-training-form-empty');

  // Step 4: Submit with blank title to trigger validation error
  await page.getByRole('textbox', { name: 'Title' }).fill('');
  await page.getByRole('button', { name: 'Create Master Training' }).click();
  await expect(page.locator('ul li')).toBeVisible();
  await screenshot(page, '04-validation-error-blank-title');

  // Step 5: Fill in valid title and description
  await page.getByRole('textbox', { name: 'Title' }).fill('Ergonomics Workshop');
  await page.getByRole('textbox', { name: 'Description' }).fill(
    'Hands-on ergonomics training to reduce workplace injuries and improve posture.'
  );
  await screenshot(page, '05-new-form-filled');

  // Step 6: Submit and land on index with success notice
  await page.getByRole('button', { name: 'Create Master Training' }).click();
  await page.waitForURL('**/master_trainings');
  await expect(page.getByText('Master training created')).toBeVisible();
  await screenshot(page, '06-created-success');

  // Step 7: Click Edit on the newly created training
  const newRow = page.getByRole('row', { name: /Ergonomics Workshop/ }).first();
  await newRow.getByRole('link', { name: 'Edit' }).click();
  await page.waitForURL('**/edit');
  await expect(page.getByRole('heading', { name: 'Edit Master Training' })).toBeVisible();
  await screenshot(page, '07-edit-form-prefilled');

  // Step 8: Update title and description
  const titleInput = page.getByRole('textbox', { name: 'Title' });
  await titleInput.clear();
  await titleInput.fill('Ergonomics & Posture Workshop');

  const descInput = page.getByRole('textbox', { name: 'Description' });
  await descInput.clear();
  await descInput.fill('Updated ergonomics training with revised exercises, posture drills, and new equipment guidelines.');
  await screenshot(page, '08-edit-form-updated');

  // Step 9: Save and verify success
  await page.getByRole('button', { name: 'Save changes' }).click();
  await page.waitForURL('**/master_trainings');
  await expect(page.getByText('successfully updated')).toBeVisible();
  await screenshot(page, '09-updated-success');

  // Step 10: Final index state
  await expect(page.getByRole('cell', { name: 'Ergonomics & Posture Workshop' })).toBeVisible();
  await screenshot(page, '10-final-index');
});
