# Use Juice Roll Offline on Android, iPhone, or iPad

**Last researched:** 2026-08-07
**App:** [Juice Roll](https://juiceroll.curlyquote.com/)

Juice Roll is a Progressive Web App (PWA). It installs from a browser, gets its
own Home Screen icon, and can run without Wi-Fi or cellular service after its
offline files finish downloading.

No Play Store, App Store, APK, developer account, or coding is required.

## What Works Offline

The offline package is about 28.3 MB and includes:

- all 24 Home Screen actions;
- all oracle tables and dice logic;
- all 60 Abstract images;
- fonts and rendering files;
- session creation, roll history, notes, and exploration state; and
- session export and import through the clipboard.

Links in the About screen that open GitHub or the Juice Oracle website still
need internet access. Everything needed to use Juice Roll itself is local.

## Before You Install

1. Use the exact app URL:
   `https://juiceroll.curlyquote.com/`
2. Connect to stable Wi-Fi or cellular data.
3. Keep at least 50 MB of device storage free. Juice Roll currently stores
   about 28.3 MB, and the browser needs some working room.
4. Update Chrome, Android, or iOS when practical.
5. Use a normal browser tab. Do not use Chrome Incognito or Safari Private
   Browsing for installation. Private sessions are not intended for durable
   site data.
6. If you already use Juice Roll in a browser, export important sessions first.
   The installed copy, especially on iPhone, should be treated as a separate
   storage container.

There is no download progress indicator in Juice Roll yet. Installation alone
does not prove that every offline file arrived. The airplane-mode test later in
this guide is the authoritative readiness check.

---

## Android: Install from Chrome

These steps follow Google Chrome's current Android web-app instructions.
Chrome's wording can vary slightly by phone or Chrome version.

1. Open **Chrome** in a normal tab.
2. Open [Juice Roll](https://juiceroll.curlyquote.com/).
3. Wait until the main grid of oracle buttons appears.
4. Leave the page open online for 1 to 2 minutes. On a slow connection, leave
   it longer. This gives the browser time to store the complete offline package.
5. Tap Chrome's three-dot **More** menu.
6. Tap **Install and create shortcut**. Some Chrome versions say **Install app**
   or **Add to Home screen**.
7. Tap **Install** and follow any remaining prompts.
8. Find the Juice Roll icon on the Home Screen or in the app launcher.
9. Open Juice Roll from that icon while still online.
10. Wait for the main grid, then leave it open online for another minute.
11. Complete the [airplane-mode test](#prove-it-works-offline) before relying on
    it during travel.

### Android Storage Setting

Chrome must be allowed to keep on-device site data. If offline files or sessions
do not survive a restart:

1. Open Chrome.
2. Tap **More** > **Settings**.
3. Under **Advanced**, tap **Site settings** > **On-device site data**.
4. Select **Allow sites to save data on your device**.
5. Reopen the installed Juice Roll icon while online, wait, and repeat the
   airplane-mode test.

Do not select **Delete data sites have saved to your device when you close all
windows** if you expect Juice Roll sessions to persist.

---

## iPhone or iPad: Install from Safari

Safari is the recommended route because Apple's current instructions expose the
**Open as Web App** setting directly. These instructions are based on current
iOS. Older versions use a similar Share-sheet flow, but labels may differ.

1. Open **Safari** in a normal, non-Private tab.
2. Open [Juice Roll](https://juiceroll.curlyquote.com/).
3. Wait until the main grid of oracle buttons appears.
4. Leave the Safari page open online for 1 to 2 minutes.
5. Tap Safari's **More** button, then **Share**. With some tab layouts, tap the
   **Share** button directly.
6. Scroll down and tap **Add to Home Screen**.
7. If **Add to Home Screen** is missing, scroll to the bottom, tap
   **Edit Actions**, and add **Add to Home Screen**.
8. Turn on **Open as Web App**.
9. Keep the name **Juice Roll**, then tap **Add**.
10. Return to the Home Screen and tap the new Juice Roll icon.
11. Keep this Home Screen copy open online for 1 to 2 minutes. This step matters:
    do not assume the installed app shares the Safari tab's cache or sessions.
12. Complete the [airplane-mode test](#prove-it-works-offline).

### Installing from Chrome on iPhone

Chrome on iPhone also supports **Share** > **Add to Home Screen**, and WebKit
supports Home Screen installation from third-party browsers on modern iOS.
Safari remains the recommended path because Apple's **Open as Web App** flow is
the least ambiguous.

### iPhone Lockdown Mode

Apple's current support page says Lockdown Mode restricts complex web
technologies. WebKit's implementation documentation specifically lists Service
Workers, Cache API, and CacheStorage among the restrictions. Juice Roll needs
those features for offline launch. If Lockdown Mode is enabled and Juice Roll
will not prepare or start offline:

1. Open Juice Roll in Safari while online.
2. Open Safari's **Page Menu**, then **More**.
3. Turn off **Lockdown Mode** for this website.
4. Reinstall or reopen the Home Screen app online and repeat the airplane-mode
   test.

Apple recommends excluding only websites you trust and only when necessary.

---

## Prove It Works Offline

Run this test at home, not for the first time after the trip begins.

1. While still online, open Juice Roll from its installed Home Screen icon.
2. Confirm the full oracle-button grid appears.
3. Tap **Dice**, make a test roll, and close the dialog.
4. Tap **Abstract**, tap **Roll 1d10 + 1d6**, and confirm an image appears in
   Roll History. The image is an especially useful check that the full asset
   package was stored.
5. Close Juice Roll from the app switcher so it is no longer running.
6. Turn on airplane mode.
7. Check that Wi-Fi is also off. Some phones remember a previous setting and
   leave Wi-Fi enabled while airplane mode is on.
8. Tap the installed Juice Roll icon again.
9. Confirm the main grid appears without a network-error page.
10. Make another Dice or oracle roll.
11. Close Juice Roll from the app switcher and open it once more while still
    offline.
12. Confirm both test rolls remain in Roll History.

If all twelve steps pass, that installed copy is ready for offline use.

Turn connectivity back on afterward. The offline files remain stored.

---

## Back Up Sessions Before Travel

Juice Roll has no account or cloud synchronization. Sessions live only in the
specific browser or installed web app where they were created.

Export each important session separately:

1. Open the installed Juice Roll app.
2. Tap the current session name in the top app bar.
3. In **Sessions**, find the session to back up.
4. Tap its circular **Details** icon (the `i` icon), not the Settings gear.
5. Tap **Export**.
6. Juice Roll copies that session as JSON text to the clipboard.
7. Immediately paste it into a new note or plain-text file you control.
8. Keep that backup separate from any explanatory text so it can be copied back
   exactly later.
9. Repeat for every important session.

The clipboard is temporary. Export is not complete until the JSON has been
pasted somewhere durable.

## Restore a Session

1. Open the note or text file containing one exported session.
2. Copy the complete JSON text and nothing else.
3. Open the installed Juice Roll app.
4. Tap the current session name in the top app bar.
5. Tap **Import** in the Sessions sheet.
6. Select the imported session if it does not open automatically.
7. Confirm its roll count and history before deleting the backup.

Clipboard export/import works offline. It is also the safest way to move a
session between Safari, an iPhone Home Screen installation, Chrome, or Android.

---

## How Updates Work

Juice Roll checks for a new app version when it is opened online.

Updates are silent. Juice Roll does not currently display an "update complete"
message.

1. Connect to the internet.
2. Open Juice Roll from its installed icon.
3. Leave it open for 1 to 2 minutes so any update can download.
4. Close every open Juice Roll app window and browser tab.
5. Reopen the installed icon.
6. Repeat the airplane-mode test before a long trip if the update was important.

The old offline version remains active while a replacement downloads. A new
service worker normally activates only after all pages using the old version
are closed. This avoids interrupting a roll or loading a mixture of old and new
files.

Updates are not required while traveling. Once the airplane-mode test passes,
the installed version can continue working without connectivity.

---

## Troubleshooting

### Android Does Not Show Install

1. Confirm the URL begins with `https://` and matches the app URL at the top of
   this guide.
2. Confirm Chrome is not in Incognito mode.
3. Wait for the main grid and leave the page open online for 1 to 2 minutes.
4. Reload once and check the **More** menu again.
5. Update Chrome.
6. Confirm **On-device site data** is allowed using the Android storage steps
   above.

Chrome may use **Install app**, **Install and create shortcut**, or **Add to Home
screen** depending on its version and device integration.

### iPhone Does Not Show Add to Home Screen

1. Use a normal Safari tab, not Private Browsing.
2. Open Safari's Share sheet.
3. Scroll to the bottom and tap **Edit Actions**.
4. Add **Add to Home Screen**, then try again.
5. Update iOS if **Open as Web App** is unavailable and the icon only opens a
   browser bookmark.

### The Icon Opens with a Browser Address Bar

The item may be a bookmark rather than an installed web app.

1. Back up sessions from that copy first.
2. Remove the Home Screen item.
3. Repeat the install steps.
4. On iPhone, make sure **Open as Web App** is on before tapping **Add**.

### Juice Roll Opens Online but Fails Offline

1. Reconnect to a stable network.
2. Open the installed icon, not an old browser bookmark.
3. Leave it open for at least 2 minutes.
4. Close every Juice Roll app window and browser tab.
5. Reopen it once while online.
6. Repeat the airplane-mode test and verify Wi-Fi is off.
7. Check available device storage.
8. On Android, confirm on-device site data is allowed.
9. On iPhone, check Lockdown Mode.
10. If it still fails, export sessions, remove the installed app, and install it
    again from the exact URL.

### Sessions Are Missing

- Make sure you opened the same installed icon. Browser tabs and Home Screen
  apps may use different storage containers.
- On iPhone, multiple Juice Roll icons can be installed with different names.
  Treat each as a separate copy.
- Clearing site data, deleting the web app, or reinstalling can remove sessions.
- Import the latest exported JSON backup.
- There is no automatic sync between devices.

### An Abstract Image Is Missing

The offline package probably did not finish installing. Reconnect, leave the
installed app open for at least 2 minutes, close all Juice Roll windows, reopen
online once, and repeat the complete airplane-mode test.

### An Update Seems Stuck

1. Connect to the internet and open Juice Roll.
2. Leave it open for 1 to 2 minutes.
3. Close the installed app and every browser tab showing Juice Roll.
4. Reopen the installed icon.

Do not clear browser data as the first troubleshooting step. That can erase
sessions.

### Device Storage Is Low

- Android: open **Settings** > **Storage**.
- iPhone: open **Settings** > **General** > **iPhone Storage**.

Free at least 50 MB, then reopen Juice Roll online and repeat the install or
airplane-mode preparation.

---

## Removing Juice Roll

Export important sessions first.

### Android

Google documents removal through **Settings** > **Apps** > **See all apps** >
**Juice Roll** > **Uninstall**. Launcher wording can vary by phone.

### iPhone or iPad

Touch and hold the Juice Roll Home Screen icon, then choose the removal option.
Depending on iOS and how it identifies the Home Screen item, the label can be
**Delete Bookmark**, **Remove App**, or **Delete App**.

Deleting the icon or clearing website data can also delete its local sessions
and offline files. Reinstalling does not restore them unless you import a
session backup.

---

## Storage and Privacy Notes

- Juice Roll does not upload sessions to a server.
- App files use Cache Storage; sessions use browser Local Storage through
  Flutter's SharedPreferences plugin.
- Browser storage is normally best-effort. Under severe storage pressure, a
  browser can evict site data. Installed or frequently used apps are generally
  better candidates for retention, but installation is not a backup.
- WebKit gives standalone Home Screen web apps the same large quota class as a
  browser app. Juice Roll's 28.3 MB package is small relative to that quota, but
  no quota prevents manual deletion.
- Chrome reports that automatic eviction is rare; manual clearing is a more
  common cause of data loss.
- Chrome Incognito removes site data when the Incognito session ends.
- iPhone Home Screen web apps are exempt from Safari's older seven-day
  script-storage cleanup rule, but can still lose data through deletion,
  storage pressure, or settings changes.

For valuable campaigns, keep a separate exported copy of each session.

---

## Verification Status

The offline release in this repository is automatically tested in desktop
Chromium and a Pixel 7 Android browser profile. The tests:

- disable normal HTTP caching;
- take the browser fully offline;
- open all 24 Home Screen actions;
- verify zero third-party runtime requests;
- fetch every offline package URL;
- verify all 60 Abstract images;
- confirm Chromium reports no PWA installability errors; and
- preserve a real session and roll history across service-worker migration.

A physical Android and iPhone/iPad check should still be completed for each
public release because browser emulation cannot reproduce every OS-level Home
Screen and storage behavior.

---

## Official Sources

- [Google Chrome Help: Use web apps on Android](https://support.google.com/chrome/answer/9658361?hl=en&co=GENIE.Platform%3DAndroid)
- [Google Chrome Help: Use web apps on iPhone and iPad](https://support.google.com/chrome/answer/9658361?hl=en&co=GENIE.Platform%3DiOS)
- [Google Chrome Help: On-device site data](https://support.google.com/chrome/answer/14114868?hl=en&co=GENIE.Platform%3DAndroid)
- [Google Chrome Help: Incognito data behavior](https://support.google.com/chrome/answer/95464?hl=en&co=GENIE.Platform%3DAndroid)
- [Google Chrome Help: Delete browsing data](https://support.google.com/chrome/answer/2392709?hl=en&co=GENIE.Platform%3DAndroid)
- [Android Help: Check and free storage](https://support.google.com/android/answer/7431795?hl=en)
- [Apple iPhone User Guide: Turn a website into an app](https://support.apple.com/guide/iphone/open-as-web-app-iphea86e5236/ios)
- [Apple iPhone User Guide: Add a website icon to the Home Screen](https://support.apple.com/guide/iphone/bookmark-a-website-iph42ab2f3a7/ios)
- [Apple iPhone User Guide: Private Browsing](https://support.apple.com/guide/iphone/browse-the-web-privately-iphb01fc3c85/ios)
- [Apple iPhone User Guide: Clear Safari data](https://support.apple.com/guide/iphone/clear-your-cache-and-cookies-iphacc5f0202/ios)
- [Apple iPhone User Guide: Remove apps](https://support.apple.com/guide/iphone/remove-apps-iph248b543ca/ios)
- [Apple Support: Lockdown Mode](https://support.apple.com/en-us/105120)
- [Apple iPhone User Guide: Manage iPhone storage](https://support.apple.com/guide/iphone/check-storage-iph47c931112/ios)
- [WebKit: Web apps on iOS and iPadOS](https://webkit.org/blog/13878/web-push-for-web-apps-on-ios-and-ipados/)
- [WebKit: Safari 16.4 Lockdown Mode restrictions](https://webkit.org/blog/13966/webkit-features-in-safari-16-4/#new-restrictions-in-lockdown-mode)
- [WebKit: Storage quotas, eviction, and persistence](https://webkit.org/blog/14403/updates-to-storage-policy/)
- [WebKit: Home Screen web apps and the seven-day storage policy](https://webkit.org/blog/10218/full-third-party-cookie-blocking-and-more/)
- [Chrome for Developers: Service-worker lifecycle](https://developer.chrome.com/docs/workbox/service-worker-lifecycle)
- [web.dev: Browser storage and eviction](https://web.dev/articles/storage-for-the-web)
- [web.dev: Persistent storage](https://web.dev/articles/persistent-storage)

Platform labels and policies can change. This guide was checked against the
official documentation available on 2026-08-07.