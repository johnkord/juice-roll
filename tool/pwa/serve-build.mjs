import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import path from 'node:path';

const port = Number.parseInt(process.env.PWA_TEST_PORT ?? '4173', 10);
const buildDirectory = path.resolve('build/web');

const contentTypes = new Map([
  ['.bin', 'application/octet-stream'],
  ['.frag', 'application/octet-stream'],
  ['.html', 'text/html; charset=utf-8'],
  ['.ico', 'image/x-icon'],
  ['.js', 'text/javascript; charset=utf-8'],
  ['.json', 'application/json; charset=utf-8'],
  ['.otf', 'font/otf'],
  ['.png', 'image/png'],
  ['.ttf', 'font/ttf'],
  ['.wasm', 'application/wasm'],
]);

const legacyWorker = `
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => event.waitUntil(self.clients.claim()));
`;

function sendText(response, statusCode, contentType, body, extraHeaders = {}) {
  response.writeHead(statusCode, {
    'Cache-Control': 'no-store',
    'Content-Type': contentType,
    ...extraHeaders,
  });
  response.end(body);
}

const server = createServer(async (request, response) => {
  const url = new URL(request.url ?? '/', `http://${request.headers.host}`);

  if (url.pathname === '/__pwa_test__/blank.html') {
    sendText(response, 200, 'text/html; charset=utf-8', '<!doctype html><title>PWA test</title>');
    return;
  }
  if (url.pathname === '/__pwa_test__/legacy-worker.js') {
    sendText(
      response,
      200,
      'text/javascript; charset=utf-8',
      legacyWorker,
      {'Service-Worker-Allowed': '/'},
    );
    return;
  }

  const requestedPath = decodeURIComponent(url.pathname === '/' ? '/index.html' : url.pathname);
  const filePath = path.resolve(buildDirectory, `.${requestedPath}`);
  if (!filePath.startsWith(`${buildDirectory}${path.sep}`)) {
    sendText(response, 403, 'text/plain; charset=utf-8', 'Forbidden');
    return;
  }

  let fileStats = await stat(filePath).catch(() => null);
  let resolvedPath = filePath;
  if (fileStats == null && request.headers.accept?.includes('text/html')) {
    resolvedPath = path.join(buildDirectory, 'index.html');
    fileStats = await stat(resolvedPath);
  }
  if (fileStats == null || !fileStats.isFile()) {
    sendText(response, 404, 'text/plain; charset=utf-8', 'Not found');
    return;
  }

  response.writeHead(200, {
    'Cache-Control': 'no-store',
    'Content-Length': fileStats.size,
    'Content-Type': contentTypes.get(path.extname(resolvedPath)) ?? 'application/octet-stream',
  });
  createReadStream(resolvedPath).pipe(response);
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Serving build/web at http://127.0.0.1:${port}`);
});

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, () => server.close(() => process.exit(0)));
}