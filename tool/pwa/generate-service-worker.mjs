import { stat } from 'node:fs/promises';

import { generateSW } from 'workbox-build';

const buildDirectory = 'build/web';
const workerPath = `${buildDirectory}/flutter_service_worker.js`;

const generatedWorker = await stat(workerPath).catch(() => null);
if (generatedWorker == null || generatedWorker.size !== 0) {
  throw new Error(
    'Expected a zero-byte Flutter worker. Build with --pwa-strategy=none first.',
  );
}

const { count, size, warnings } = await generateSW({
  cacheId: 'juice-roll',
  cleanupOutdatedCaches: true,
  clientsClaim: true,
  globDirectory: buildDirectory,
  globIgnores: [
    '**/*.map',
    '**/*.symbols',
    'flutter_service_worker.js',
    'staticwebapp.config.json',
  ],
  globPatterns: ['**/*'],
  inlineWorkboxRuntime: true,
  maximumFileSizeToCacheInBytes: 10 * 1024 * 1024,
  navigateFallback: 'index.html',
  skipWaiting: false,
  sourcemap: false,
  swDest: workerPath,
});

if (warnings.length > 0) {
  throw new Error(`Workbox warnings:\n${warnings.join('\n')}`);
}

console.log(
  `Generated ${workerPath} with ${count} files (${size} bytes) in the precache.`,
);