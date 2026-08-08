import { expect, test } from '@playwright/test';

const workerPath = '/flutter_service_worker.js';
const legacyCacheNames = [
  'flutter-app-cache',
  'flutter-app-manifest',
  'flutter-temp-cache',
];

async function waitForWorkbox(page) {
  await page.waitForFunction(async (expectedPath) => {
    const registration = await navigator.serviceWorker.getRegistration();
    return registration?.active?.scriptURL.endsWith(expectedPath)
      && navigator.serviceWorker.controller?.scriptURL.endsWith(expectedPath);
  }, workerPath);
}

async function getPrecacheDetails(page) {
  return page.evaluate(async () => {
    const cacheNames = await caches.keys();
    const cacheName = cacheNames.find((name) => name.startsWith('juice-roll-precache-'));
    if (cacheName == null) return null;

    const cache = await caches.open(cacheName);
    const requests = await cache.keys();
    const paths = requests.map((request) => new URL(request.url).pathname);
    return {
      cacheName,
      count: requests.length,
      abstractIconCount: paths.filter((path) =>
        path.startsWith('/assets/assets/images/abstract_icons/')
      ).length,
    };
  });
}

async function enableFlutterSemantics(page) {
  const placeholder = page.getByRole('button', { name: 'Enable accessibility' });
  const usesTouchOverlay = await placeholder.evaluate((element) => {
    const bounds = element.getBoundingClientRect();
    return bounds.width > 1 && bounds.height > 1;
  });

  if (usesTouchOverlay) {
    await placeholder.click({ force: true });
  } else {
    await placeholder.evaluate((element) => element.click());
  }
  await page.getByRole('button', { name: 'Details', exact: true }).waitFor();
}

test('opens every home-screen action offline without third-party requests', async ({ context, page }) => {
  const externalRequests = new Map();
  let currentAction = 'Startup';
  page.on('request', (request) => {
    const url = new URL(request.url());
    if (url.origin !== 'http://127.0.0.1:4173') {
      externalRequests.set(url.href, currentAction);
    }
  });

  await page.goto('/');
  await waitForWorkbox(page);
  await page.locator('flutter-view').waitFor();
  await expect.poll(
    async () => (await getPrecacheDetails(page))?.abstractIconCount ?? 0,
    { timeout: 30_000 },
  ).toBe(60);

  const cdpSession = await context.newCDPSession(page);
  await cdpSession.send('Network.enable');
  await cdpSession.send('Network.setCacheDisabled', { cacheDisabled: true });
  await context.setOffline(true);

  await enableFlutterSemantics(page);

  const actionLabels = [
    'Details', 'Immerse', 'Fate', 'Scene',
    'Expect', 'Scale', 'Interrupt', 'Meaning',
    'Name', 'Random', 'Quest', 'Challenge',
    'Price', 'Wilderness', 'Monster', 'NPC',
    'Dialog', 'Settlement', 'Treasure', 'Dungeon',
    'Location', 'NPC Talk', 'Abstract', 'Dice',
  ];

  try {
    for (const label of actionLabels) {
      currentAction = label;
      await page.getByRole('button', { name: label, exact: true }).click();
      await page.waitForTimeout(100);

      const openDialog = page.locator('[role="dialog"], [role="alertdialog"]');
      if (await openDialog.count()) {
        const closeButton = page.getByRole('button', { name: /^(Cancel|Close)$/ }).last();
        if (await closeButton.count()) {
          await closeButton.click();
        } else {
          await page.keyboard.press('Escape');
        }
      }
    }
  } finally {
    await context.setOffline(false);
  }

  currentAction = 'Settled';
  await page.waitForTimeout(500);
  expect(
    [...externalRequests]
      .map(([url, action]) => ({ action, url }))
      .sort((left, right) => left.url.localeCompare(right.url)),
  ).toEqual([]);
});

test('installs a complete release and reloads offline', async ({ context, page }) => {
  await page.goto('/');
  await waitForWorkbox(page);

  await expect(page).toHaveTitle('Juice Roll');
  await page.locator('flutter-view').waitFor();

  const cdpSession = await context.newCDPSession(page);
  const manifest = await cdpSession.send('Page.getAppManifest');
  expect(manifest.errors).toEqual([]);
  const installabilityErrors = await cdpSession.send('Page.getInstallabilityErrors');
  expect(installabilityErrors.installabilityErrors).toEqual([]);

  await expect.poll(
    async () => (await getPrecacheDetails(page))?.abstractIconCount ?? 0,
    { timeout: 30_000 },
  ).toBe(60);
  const precache = await getPrecacheDetails(page);
  expect(precache).not.toBeNull();
  expect(precache.count).toBeGreaterThan(80);

  await page.evaluate(() => {
    localStorage.setItem('juice_roll_offline_probe', 'preserved');
  });

  await cdpSession.send('Network.enable');
  await cdpSession.send('Network.setCacheDisabled', { cacheDisabled: true });
  await context.setOffline(true);

  try {
    await page.reload({ waitUntil: 'domcontentloaded' });
    await page.locator('flutter-view').waitFor();
    await expect(page).toHaveTitle('Juice Roll');

    const offlineResult = await page.evaluate(async () => {
      const cacheName = (await caches.keys()).find((name) =>
        name.startsWith('juice-roll-precache-')
      );
      const cache = await caches.open(cacheName);
      const requests = await cache.keys();
      const results = await Promise.all(requests.map(async (request) => {
        try {
          const url = new URL(request.url);
          url.search = '';
          const response = await fetch(url);
          return response.ok ? null : request.url;
        } catch {
          return request.url;
        }
      }));

      return {
        failedUrls: results.filter((url) => url != null),
        probe: localStorage.getItem('juice_roll_offline_probe'),
      };
    });

    expect(offlineResult.failedUrls).toEqual([]);
    expect(offlineResult.probe).toBe('preserved');
  } finally {
    await context.setOffline(false);
  }
});

test('migrates the generated Flutter worker without clearing sessions', async ({ context, page }) => {
  await page.goto('/__pwa_test__/blank.html');
  await page.evaluate(async () => {
    await navigator.serviceWorker.register('/__pwa_test__/legacy-worker.js', {
      scope: '/',
      updateViaCache: 'none',
    });
    await navigator.serviceWorker.ready;
  });
  await page.reload();
  await page.waitForFunction(() =>
    navigator.serviceWorker.controller?.scriptURL.endsWith('/__pwa_test__/legacy-worker.js')
  );

  await page.evaluate(async (cacheNames) => {
    localStorage.setItem('juice_roll_migration_probe', 'preserved');
    await Promise.all(cacheNames.map((cacheName) => caches.open(cacheName)));
  }, legacyCacheNames);

  await page.goto('/');
  await page.waitForFunction(async (expectedPath) => {
    const registration = await navigator.serviceWorker.getRegistration();
    return registration?.waiting?.scriptURL.endsWith(expectedPath);
  }, workerPath);

  await enableFlutterSemantics(page);
  await page.getByRole('button', { name: 'Scale', exact: true }).click();
  await expect.poll(
    () => page.evaluate(() =>
      Object.entries(localStorage)
        .filter(([key]) => key.startsWith('flutter.juice_roll_session_'))
        .map(([, value]) => {
          const storedValue = JSON.parse(value);
          const session = typeof storedValue === 'string'
            ? JSON.parse(storedValue)
            : storedValue;
          return session.history.length;
        })
        .reduce((total, count) => total + count, 0)
    ),
  ).toBeGreaterThan(0);

  await expect.poll(
    () => page.evaluate(() =>
      Object.keys(localStorage).filter((key) => key.startsWith('flutter.juice_roll_')).length
    ),
  ).toBeGreaterThan(0);
  const sessionSnapshot = await page.evaluate(() =>
    Object.fromEntries(
      Object.entries(localStorage).filter(([key]) => key.startsWith('flutter.juice_roll_')),
    )
  );

  await page.close();
  await new Promise((resolve) => setTimeout(resolve, 500));

  const nextPage = await context.newPage();
  await nextPage.goto('/');
  await waitForWorkbox(nextPage);

  const migrationResult = await nextPage.evaluate(async () => ({
    cacheNames: await caches.keys(),
    probe: localStorage.getItem('juice_roll_migration_probe'),
    sessions: Object.fromEntries(
      Object.entries(localStorage).filter(([key]) => key.startsWith('flutter.juice_roll_')),
    ),
  }));
  expect(
    migrationResult.cacheNames.some((cacheName) =>
      cacheName.startsWith('juice-roll-precache-')
    ),
  ).toBe(true);
  expect(migrationResult.probe).toBe('preserved');
  expect(migrationResult.sessions).toEqual(sessionSnapshot);
});