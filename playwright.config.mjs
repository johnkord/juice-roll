import { defineConfig, devices } from '@playwright/test';

const port = 4173;

export default defineConfig({
  expect: {
    timeout: 10_000,
  },
  fullyParallel: false,
  reporter: process.env.CI ? 'github' : 'list',
  projects: [
    {
      name: 'desktop-chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'android-chromium',
      use: { ...devices['Pixel 7'] },
    },
  ],
  testDir: 'test/pwa',
  timeout: 90_000,
  use: {
    baseURL: `http://127.0.0.1:${port}`,
    browserName: 'chromium',
    serviceWorkers: 'allow',
    trace: 'retain-on-failure',
  },
  webServer: {
    command: 'node tool/pwa/serve-build.mjs',
    port,
    reuseExistingServer: !process.env.CI,
    timeout: 15_000,
  },
  workers: 1,
});