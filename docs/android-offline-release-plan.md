# Android Offline Release Plan

**Status:** Implemented locally; production and physical Android validation pending
**Priority:** High
**Scope:** GitHub issue #5, Android installation and no-signal use
**Created:** 2026-08-07
**Reviewed:** 2026-08-07

---

## Decision

Resolve issue #5 with a tested, installable Progressive Web App (PWA). Do not
make a native Android release, Play Store listing, custom domain, or new backup
system a prerequisite.

The release should replace Flutter's generated service worker with a
source-controlled Workbox build that:

- precaches every functional web release file;
- excludes source maps and symbol files;
- works with every renderer included in the Flutter build;
- updates through the existing `flutter_service_worker.js` URL;
- preserves sessions during cache migration; and
- is verified on a physical Android phone in airplane mode.

This deliberately favors a roughly 28.3 MB complete offline cache over a smaller,
device-specific cache. The complete cache is modest for an installed app and
avoids renderer detection, first-load cache races, and an `Offline ready`
subsystem in the first release.

Native Flutter Android remains a viable follow-up, not part of closing this
issue.

---

## Decision Defaults

| Decision | Default |
|---|---|
| Delivery | Hardened PWA first |
| Public URL | Use the branded Azure custom domain |
| Flutter version | Keep CI on 3.38.3 for this release |
| Service worker | Workbox `generateSW` |
| Worker URL | Overwrite `build/web/flutter_service_worker.js` |
| Offline contents | All functional build files; exclude `.symbols` and `.map` |
| Update behavior | Install in the background; activate at a clean launch, never during an active dialog |
| Browser target | Current Chrome for Android |
| Native APK | Separate follow-up only if demand remains |
| Google Play and TWA | Deferred |

### Canonical Origin Rule

Only one URL should be advertised. The canonical URL is:

```text
https://juiceroll.curlyquote.com/
```

The custom domain is a DNS CNAME to
`lemon-pebble-0a8b6550f.3.azurestaticapps.net`. Azure serves the branded origin
directly over HTTPS; it is not an HTTP redirect.

After users install the PWA, changing origins becomes a data migration. Browser
sessions and service-worker state do not move automatically. Use the existing
session export/import flow if a later origin change is unavoidable.

---

## Evidence Behind the Decision

### Pre-Implementation Baseline

- Flutter CI is pinned to 3.38.3 in
  `.github/workflows/azure-static-web-apps.yml`.
- The app's oracle logic, table data, and abstract images are local.
- Sessions use `shared_preferences`; no application server is involved.
- The home screen exposes 24 user actions. The preset registry contains 21
  oracle objects, while the home screen also includes other flows such as the
  dice utility. Acceptance should refer to the 24 home-screen actions, not
  "24 presets."
- There is no `android/` platform directory and no downloadable APK release.
- No web-only Dart imports were detected in `lib/`, so native Android remains a
  low-risk future option.
- `web/manifest.json` contained placeholder text, Flutter colors, and default
  Flutter icons.
- `staticwebapp.config.json` was at the repository root while CI deployed only
  `build/web`. Azure requires the configuration in the deployed output root.
- The previous configuration declared the unused `node:18` API runtime even
  though this app has no API.

### Browser Test: Current Release

A local release build was loaded under service-worker control:

1. The first online load cached 9 shell resources.
2. No abstract images were present in Cache Storage.
3. An unvisited abstract image failed while offline.
4. The app shell itself reloaded offline.
5. Accessibility mode attempted to fetch Noto Sans Math and Noto Sans Symbols
   from `fonts.gstatic.com`.

This proves the current release is partially offline, not travel-ready.

### Browser Test: Generated Full Download

Flutter's generated worker accepts a `downloadOffline` message. Sending it in
the same build produced these results:

| Measurement | Result |
|---|---:|
| Cache entries before | 9 |
| Cache entries after | 92 |
| Abstract images cached | 60 of 60 |
| Total cached bytes | 32,746,321 |
| Symbol-file bytes | 5,762,623 |
| Offline reload after download | Passed |
| Previously uncached abstract image offline | HTTP 200, 11,865 bytes |

Excluding symbol files leaves about 27 MB of functional release content. That
is small enough to cache completely and removes the need to determine whether a
specific phone chose CanvasKit, Chromium CanvasKit, Skwasm, or a heavy fallback.

The generated `downloadOffline` path is evidence and an emergency fallback, not
the recommended production solution. It has no completion response, includes
unneeded symbol files, relies on deprecated Flutter behavior, and its message
handler does not extend the service-worker event lifetime with `waitUntil`.

### Toolchain Verification

The following command is supported by the pinned Flutter 3.38.3 toolchain:

```bash
flutter build web --release --pwa-strategy=none
```

The verified output contains a zero-byte
`build/web/flutter_service_worker.js`, and the generated bootstrap does not
configure service-worker registration. This gives the Workbox build an
unambiguous handoff:

1. Flutter emits a release without caching logic.
2. Workbox overwrites the zero-byte worker at the existing URL.
3. Juice Roll registers that worker explicitly.

Using the existing URL simplifies migration for users already controlled by
Flutter's generated worker.

### Implemented Result

- Node 20, Workbox 7.4.1, and Playwright 1.62.1 are pinned in `package-lock.json`.
- `npm run build:web` builds Flutter with `--pwa-strategy=none`, generates the
  Workbox worker, stages Azure configuration, and verifies the output.
- The current precache contains 96 functional files totaling 28,306,950 bytes,
  including all 60 abstract images and all renderer variants.
- Flutter is configured to use bundled CanvasKit rather than `gstatic.com`.
- Roboto, Roboto Mono, Noto Sans Symbols, and Noto Sans Symbols 2 are bundled
  with their Apache/OFL license files.
- The installed app has Juice Roll metadata, colors, favicon, and maskable
  icons.
- CI builds and tests the PWA before Azure deployment.
- Playwright verifies all 24 home-screen actions offline with normal HTTP cache
  disabled and zero third-party requests in desktop Chromium and a Pixel 7
  Android browser profile.
- Playwright also verifies clean offline reload, every precached URL, legacy
  worker takeover, and byte-for-byte preservation of Juice Roll session data.

Legacy Flutter Cache Storage entries may remain after upgrade. They are
harmless, do not affect worker ownership or sessions, and can be reclaimed by
the browser. Automatic deletion was intentionally omitted after synthetic
lifecycle testing showed it added complexity without improving user behavior.

---

## Scope

### Required to Close Issue #5

- Juice Roll name, description, colors, and icons in the installed app.
- One documented production URL.
- A source-controlled offline build step.
- All functional release resources available offline.
- No required third-party network request after installation.
- Chrome installation instructions requiring no coding or sideloading.
- A real Android airplane-mode test.
- A tested update from the old generated worker to the new worker.
- Session persistence through normal application and worker updates.

### Explicitly Deferred

- Google Play publication.
- Trusted Web Activity or PWABuilder packaging.
- Capacitor or another web wrapper.
- A native APK.
- An in-app install prompt.
- A detailed offline status dashboard.
- Automatic cross-origin session migration.
- File-based session backup; existing clipboard JSON remains available.
- Samsung Internet, iOS Safari, and broad browser certification.
- Cloud accounts, synchronization, or a backend.

These can become separate issues. They should not enlarge the critical path for
a user who asked for a browser link that works without signal.

---

## Definition of Done

The PWA release is complete only when all items pass:

- [ ] Android Chrome offers installation with Juice Roll branding.
- [x] A clean online visit installs and activates the Workbox worker.
- [x] Disabling the normal HTTP cache does not affect offline startup.
- [ ] The installed app cold-starts in airplane mode.
- [x] Each of the 24 home-screen actions opens offline.
- [ ] Representative roll paths from every dialog complete offline.
- [x] All 60 abstract images return successfully offline.
- [x] Accessibility mode has no missing required glyphs or controls.
- [x] Creating a session and roll survives close/reopen and worker update.
- [x] The old generated Flutter worker upgrades to Workbox without a reload
      loop.
- [ ] Production `Cache-Control` headers match the documented policy.
- [ ] README and issue #5 point to the same production URL.
- [ ] A nontechnical tester completes the published Android instructions.

Clearing Chrome site data or uninstalling the PWA can still remove local
sessions. The issue response must state this and recommend the existing session
export before travel.

---

## Target Build

```text
Flutter source
    -> flutter build web --release --pwa-strategy=none
    -> Workbox generateSW
    -> corrected staticwebapp.config.json copied into build/web
    -> build-contract tests
    -> browser offline tests
    -> Azure Static Web Apps
```

### Expected Source Changes

```text
.github/workflows/azure-static-web-apps.yml
package.json
package-lock.json
tool/pwa/generate-service-worker.mjs
tool/pwa/test-build.mjs
web/index.html
web/manifest.json
web/icons/*
staticwebapp.config.json
README.md
```

The exact browser-test location can follow the chosen Playwright setup. Avoid
adding a custom service-worker source file unless the Workbox spike proves that
`generateSW` cannot satisfy the update lifecycle.

---

## Milestone 0: Prove the Workbox Build

This is the first implementation slice. It is a technical spike with a binary
outcome, not a broad product change.

### Tasks

- [x] Add pinned Node and Workbox development dependencies.
- [x] Build Flutter with `--pwa-strategy=none`.
- [x] Run Workbox `generateSW` with
      `swDest: build/web/flutter_service_worker.js`.
- [x] Precache all functional release files.
- [x] Exclude `.symbols`, `.map`, the Azure config, and the worker itself.
- [x] Set `maximumFileSizeToCacheInBytes` above the largest required Wasm file;
      the current largest is about 7.1 MB.
- [x] Inline the Workbox runtime unless measurement shows a reason not to.
- [x] Give Workbox caches a Juice Roll-specific prefix.
- [x] Record generated file count, byte count, and all Workbox warnings.
- [x] Register the worker from `web/index.html`.
- [x] Remove Flutter's current aggressive `controllerchange` reload behavior.
- [x] Test a clean install and an update from the current generated worker.

### Candidate Workbox Policy

Use `generateSW`, not `injectManifest`, because Juice Roll currently needs
precache, navigation fallback, cleanup, and a standard update lifecycle rather
than custom service-worker features.

Candidate settings:

| Setting | Direction |
|---|---|
| `globDirectory` | `build/web` |
| `swDest` | `build/web/flutter_service_worker.js` |
| `globPatterns` | Functional HTML, JS, JSON, Wasm, images, manifests, fonts, shaders, and notices |
| `globIgnores` | Symbols, maps, worker output, Azure config |
| `maximumFileSizeToCacheInBytes` | At least 10 MB, then tighten from measured output |
| `navigateFallback` | `index.html` |
| `cleanupOutdatedCaches` | Enabled |
| `clientsClaim` | Enabled after migration test |
| `skipWaiting` | Disabled; activate at a clean launch |
| `inlineWorkboxRuntime` | Enabled for a self-contained worker |

The spike must print and test the actual manifest. Do not treat this table as
correct merely because the build succeeds.

### Pass Gate

Proceed only if all are true:

- The generated worker precaches all functional files.
- The total remains reasonable for a one-time Android installation.
- No Workbox warning is ignored without explanation.
- A clean offline reload works with the browser HTTP cache disabled.
- Abstract images render offline.
- Old-to-new worker migration completes without deleting Local Storage.
- A second generated Workbox version updates successfully.

If this spike fails, the fallback is to use the verified generated
`downloadOffline` path temporarily while a smaller custom worker is designed.
That fallback must be labeled temporary and must retain an airplane-mode test.

---

## Milestone 1: Make the PWA Release-Ready

### 1. Product Identity

Replace placeholder PWA metadata:

- `name`: `Juice Roll`
- `short_name`: `Juice Roll`
- A concise description of the oracle and dice app
- Theme and background colors from the Juice Roll theme
- Stable `id`, `scope`, and `start_url`
- Purpose-built 192 px, 512 px, and maskable icons
- Matching favicon and Apple touch icon

Add the one canonical app URL to README and the GitHub repository About field.
A custom domain and QR code are optional polish, not release gates.

### 2. Font and External-Request Audit

Do not blindly replace every Unicode character. The repository contains many
meaningful arrows, bullets, multiplication signs, Fate symbols, and a small
number of emoji.

Instead:

1. Run all 24 home-screen actions from a clean online browser context.
2. Record every request to a third-party origin.
3. Identify which strings trigger Noto Sans Math or Noto Sans Symbols.
4. Prefer bundling the observed OFL-licensed fallback font when many meaningful
   strings need it.
5. Replace isolated decorative characters only when that is smaller and keeps
   the same meaning.
6. Repeat with Flutter accessibility enabled and then offline.

The release gate is visual and functional: no required text, symbol, image, or
control may depend on a network request. Merely seeing a failed optional font
request is not enough to declare the flow broken, but it must be understood and
documented.

### 3. Azure Configuration

Correct `staticwebapp.config.json` before copying it into `build/web`:

- Remove the unused `platform.apiRuntime` setting.
- Add exact routes before broader wildcards so
  `flutter_service_worker.js` uses `no-cache, no-store, must-revalidate` and
  cannot inherit a long-lived JavaScript rule.
- Use `no-cache, must-revalidate` for `index.html`, `flutter_bootstrap.js`, and
  `main.dart.js`; all have stable filenames.
- Remove the current one-year immutable rule for every `*.js` file.
- Keep navigation fallback for direct online requests.
- Keep required Wasm MIME handling only if Azure does not already provide it.

Add an explicit CI copy step after the Flutter and Workbox builds. Verify the
deployed headers with `curl`; checking the source JSON is not sufficient.

### 4. Update Lifecycle

The current page reloads as soon as a new worker takes control. Replace that
behavior.

For the first release:

- install updates in the background;
- let a running app continue on its active worker;
- activate a waiting worker at the next clean app launch;
- reload at most once before Flutter begins active work; and
- never clear `shared_preferences` or all origin storage during cache cleanup.

An in-app `Update ready` prompt can be added later. It is not required if the
next-launch path is reliable and tested.

### 5. User Instructions

The tested Android flow should remain short:

1. Open the canonical URL in Chrome while online.
2. Wait for Juice Roll to finish its first load.
3. Open Chrome's menu and choose `Install and create shortcut`, then `Install`.
4. Open the installed app online once.
5. Before travel, enable airplane mode and confirm the app opens and rolls.
6. Export important sessions before clearing browser data or uninstalling.

Do not claim installation alone proves offline readiness. The real airplane-mode
check remains part of the instructions until a build-specific readiness signal
is implemented.

---

## Milestone 2: Validate and Roll Out

### Build-Contract Tests

CI must fail when any contract changes unexpectedly:

- [x] Flutter emits a zero-byte generated worker before Workbox runs.
- [x] Workbox replaces it with a nonempty worker.
- [x] `web/index.html` references exactly one worker registration.
- [x] The precache manifest contains every required build file.
- [x] All 60 abstract images are included.
- [x] No `.symbols` or `.map` file is included.
- [x] No required file exceeds the configured Workbox size limit.
- [x] `staticwebapp.config.json` exists in `build/web`.
- [x] Workbox reports no unexplained warning.

### Browser Automation

Use Playwright against the release build served on localhost:

1. Start with a clean browser context.
2. Load online and wait for worker installation.
3. Assert the expected worker and cache inventory.
4. Disable the browser HTTP cache.
5. Set the browser context offline and reload.
6. Open each of the 24 home-screen actions.
7. Exercise representative text, image, dialog, and session writes.
8. Request every required precache URL while offline.
9. Confirm a real abstract image renders.
10. Enable accessibility and check required glyphs and controls.
11. Restore networking and test an N to N+1 worker update.

The automated test should report required failed requests by URL instead of
failing on every optional browser or accessibility probe.

### Physical Android Gate

On one current Android phone with Chrome:

- install from the canonical production-equivalent URL;
- cold-start in airplane mode;
- open all home-screen actions;
- roll an Abstract result and see its image;
- create a session and verify it after force-close/reopen;
- install the next worker version without losing that session; and
- follow the exact issue instructions as a nontechnical user would.

One physical test is required. A broad Android version and browser matrix is a
future quality improvement, not a blocker for this issue.

### Deployment

Prefer an Azure preview or separate canary only if its deployment credentials
and workflow already exist. The unused `brave-pond` resource is not a release
dependency merely because it exists.

Before announcing production:

1. Deploy the exact tested artifact.
2. Verify root, worker, JS, Wasm, and manifest response headers.
3. Upgrade one production-origin test session from the old worker.
4. Repeat the physical airplane-mode test.
5. Publish the issue response and README instructions.

---

## Rollback

Service workers outlive a bad server deployment, so rollback is part of the
release rather than an afterthought.

- Retain the previous tested web artifact.
- Keep the Workbox worker URL unchanged across releases.
- Give Juice Roll caches a stable, app-specific prefix.
- Delete only app cache entries during cleanup.
- Never delete Local Storage as part of worker rollback.
- Test a cleanup worker that can replace a broken worker at the same URL.
- Verify an existing session after rollback.

If a new worker fails during its atomic precache install, the existing active
worker should continue serving the app. Treat this as a failed deployment and
do not force activation.

---

## Risks

| Risk | Mitigation |
|---|---|
| A missing file makes atomic precache fail | Build-contract test every manifest entry before deploy |
| Stable entry filenames serve stale code | Revalidate entry files and use Workbox revisions |
| Old Flutter worker conflicts with Workbox | Use `--pwa-strategy=none`, overwrite the same worker URL, and test migration |
| Full cache grows unexpectedly | Print count/bytes in CI and require review above a set threshold |
| External fallback font fails offline | Audit actual requests and bundle the required licensed font or replace isolated glyphs |
| Browser data is cleared | Keep local-storage limitation visible and recommend session export |
| Origin changes later | Advertise one URL and use export/import for migration |
| Worker update reloads active work | Activate only at clean launch and remove unconditional reload code |
| Licensing is missed in new assets | Record licenses for app icons, fonts, and existing CC BY-NC-SA material |

---

## Deferred Follow-Ups

### Offline Status and Persistence

Add only if users need more confidence than the airplane-mode check:

- a compact build-specific `Offline ready` state;
- `navigator.storage.persist()` with denial handled normally;
- cached file count and byte diagnostics; and
- an explicit `Verify offline use` action.

This requires a current-build sentinel. `navigator.serviceWorker.ready` alone is
not enough during migration because it can resolve for an older active worker.

### File Backup

The existing clipboard JSON is enough for issue #5. A later improvement can
export a dated `.json` file through Web Share with a browser-download fallback.
The same format should be used by a future native app.

### Native Flutter Android

Open a separate implementation issue when one of these triggers occurs:

- users cannot install or retain the PWA reliably;
- multiple users request an APK or Play Store listing;
- browser storage loss becomes a recurring support problem; or
- native Android capabilities become a product requirement.

The likely first slice is:

```bash
flutter create --platforms=android --org <permanent.reverse.domain> .
flutter build apk --release
```

Then configure the permanent package ID, icons, signing, plugin behavior, and a
tag-based GitHub Release containing one signed universal APK and checksum.
Google Play is a separate distribution decision. A TWA and Capacitor remain
inferior to the real Flutter Android target for this app.

---

## Issue Reply After Release

Use this only after the physical Android gate passes:

> Juice Roll is now installable and tested for offline use on Android. No coding
> is required.
>
> 1. While connected to the internet, open `<canonical URL>` in Chrome.
> 2. Tap Chrome's three-dot menu.
> 3. Tap "Install and create shortcut," then "Install."
> 4. Open the installed app online once.
> 5. Before your trip, enable airplane mode and confirm Juice Roll opens and
>    rolls normally.
>
> Sessions stay on your device. Export important sessions before uninstalling
> the app or clearing Chrome's site data, because either action can remove local
> sessions.

---

## References

- [Flutter Web FAQ: service workers and cache headers](https://docs.flutter.dev/platform-integration/web/faq#how-do-i-configure-a-service-worker)
- [Workbox build modes](https://developer.chrome.com/docs/workbox/modules/workbox-build)
- [Chrome Help: install a web app on Android](https://support.google.com/chrome/answer/9658361?hl=en&co=GENIE.Platform%3DAndroid)
- [Azure Static Web Apps configuration](https://learn.microsoft.com/azure/static-web-apps/configuration)
- [MDN: persistent storage](https://developer.mozilla.org/docs/Web/API/StorageManager/persist)

Recheck version-sensitive guidance when Flutter or Workbox is upgraded. This
plan was verified against Flutter 3.38.3 while current Flutter documentation
describes a toolchain that no longer generates a managed worker by default.