import assert from 'node:assert/strict';
import { readdir, readFile, stat } from 'node:fs/promises';
import path from 'node:path';

const buildDirectory = 'build/web';
const workerName = 'flutter_service_worker.js';
const configName = 'staticwebapp.config.json';

async function listFiles(directory, relativeDirectory = '') {
  const entries = await readdir(path.join(directory, relativeDirectory), {
    withFileTypes: true,
  });
  const files = [];

  for (const entry of entries) {
    const relativePath = path.posix.join(relativeDirectory, entry.name);
    if (entry.isDirectory()) {
      files.push(...await listFiles(directory, relativePath));
    } else if (!relativePath.split('/').some((part) => part.startsWith('.'))) {
      files.push(relativePath);
    }
  }

  return files.sort();
}

function hasPrecacheEntry(worker, file) {
  const serializedFile = JSON.stringify(file);
  return worker.includes(`url:${serializedFile}`)
    || worker.includes(`"url":${serializedFile}`);
}

const files = await listFiles(buildDirectory);
const workerPath = path.join(buildDirectory, workerName);
const worker = await readFile(workerPath, 'utf8');
assert(worker.length > 0, 'The generated service worker is empty.');

const excludedFiles = files.filter((file) =>
  file === workerName
  || file === configName
  || file.endsWith('.map')
  || file.endsWith('.symbols')
);
const requiredFiles = files.filter((file) => !excludedFiles.includes(file));

for (const file of requiredFiles) {
  assert(hasPrecacheEntry(worker, file), `Missing precache entry: ${file}`);
}
for (const file of excludedFiles) {
  assert(!hasPrecacheEntry(worker, file), `Excluded file was precached: ${file}`);
}

for (const file of [
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',
  'assets/assets/fonts/Roboto-Regular.ttf',
  'assets/assets/fonts/RobotoMono-Variable.ttf',
  'assets/assets/fonts/NotoSansSymbols-Regular.otf',
  'assets/assets/fonts/NotoSansSymbols2-Regular.otf',
]) {
  assert(requiredFiles.includes(file), `Missing required offline runtime file: ${file}`);
}

const abstractIcons = requiredFiles.filter((file) =>
  file.startsWith('assets/assets/images/abstract_icons/')
  && file.endsWith('.png')
);
assert.equal(abstractIcons.length, 60, 'Expected all 60 abstract icon images.');

const requiredSizes = await Promise.all(
  requiredFiles.map(async (file) => (await stat(path.join(buildDirectory, file))).size),
);
assert(
  Math.max(...requiredSizes) <= 10 * 1024 * 1024,
  'A required file exceeds Workbox maximumFileSizeToCacheInBytes.',
);

const sourceConfig = await readFile('staticwebapp.config.json', 'utf8');
const stagedConfig = await readFile(path.join(buildDirectory, configName), 'utf8');
assert.equal(stagedConfig, sourceConfig, 'The staged Azure config is out of date.');
assert(
  Buffer.byteLength(sourceConfig) <= 20 * 1024,
  'Azure Static Web Apps config exceeds its 20 KB limit.',
);
const azureConfig = JSON.parse(sourceConfig);
const workerRoute = azureConfig.routes.find((route) =>
  route.route === '/flutter_service_worker.js'
);
assert.equal(
  workerRoute?.headers?.['cache-control'],
  'no-cache, no-store, must-revalidate',
  'The service worker must never use a long-lived HTTP cache.',
);
assert.equal(azureConfig.platform, undefined, 'This static app must not declare an API runtime.');

const index = await readFile(path.join(buildDirectory, 'index.html'), 'utf8');
assert.equal(
  index.match(/navigator\.serviceWorker\.register\(['"]flutter_service_worker\.js['"]/g)?.length ?? 0,
  1,
  `Expected exactly one ${workerName} registration in index.html.`,
);
assert(
  index.includes("updateViaCache: 'none'"),
  'Service worker registration must bypass the HTTP cache.',
);

const bootstrap = await readFile(path.join(buildDirectory, 'flutter_bootstrap.js'), 'utf8');
assert(
  bootstrap.includes("canvasKitBaseUrl: 'canvaskit'"),
  'Flutter must use the bundled CanvasKit runtime.',
);

const manifest = JSON.parse(
  await readFile(path.join(buildDirectory, 'manifest.json'), 'utf8'),
);
assert.equal(manifest.name, 'Juice Roll');
assert.equal(manifest.short_name, 'Juice Roll');
assert.equal(manifest.display, 'standalone');
const iconDeclarations = new Set(
  manifest.icons.map((icon) => `${icon.sizes}:${icon.purpose ?? 'any'}`),
);
for (const declaration of ['192x192:any', '512x512:any', '192x192:maskable', '512x512:maskable']) {
  assert(iconDeclarations.has(declaration), `Missing manifest icon: ${declaration}`);
}

const totalBytes = requiredSizes.reduce((sum, size) => sum + size, 0);
console.log(
  `Verified ${requiredFiles.length} precached files (${totalBytes} bytes), including 60 abstract icons.`,
);