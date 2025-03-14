// @ts-check
import { test, expect } from '@playwright/test';

test('It is able to login and see the dashboard', async ({ page }) => {
  await page.goto('/')

  await page.getByRole('button', { name: 'Sign in' }).click()

  // Expect a title "to contain" a substring.
  await expect(page.locator('body')).toContainText('Dashboard')
})
