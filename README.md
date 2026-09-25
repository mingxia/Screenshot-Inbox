# Screenshot Inbox

> Your screenshots were taken for a reason.

Screenshot Inbox is a local-first, native macOS utility for the moment after a screenshot is taken. It will turn screenshots created with macOS (`⌘⇧3`, `⌘⇧4`, and `⌘⇧5`) into actionable inbox items without replacing the system capture experience.

## Current milestone: Phase 7

The application now implements the local capture-to-action workflow:

- sandbox-safe screenshot-folder selection and an event-driven folder watcher;
- automatic SQLite import, persistent records, and thumbnail caching;
- a database-backed Inbox that refreshes as screenshots arrive;
- on-device Apple Vision OCR plus local URL extraction;
- local QR detection and deterministic screenshot classification;
- contextual actions, Archive, Favorites, safe Trash, and Inbox Zero;
- a non-activating queued floating action card and recent menu-bar items.

The application makes no network requests and never modifies or relocates source screenshots.

## Requirements

- macOS 13.0 or later
- Xcode 15 or later

macOS 13 is the minimum deployment target because the shell uses `MenuBarExtra`. No newer OS-only API is currently required.

## Build and run

1. Open `ScreenshotInbox.xcodeproj` in Xcode.
2. Select the **ScreenshotInbox** scheme and **My Mac** destination.
3. Press **Run** (`⌘R`).

Or build from Terminal on macOS:

```sh
xcodebuild -project ScreenshotInbox.xcodeproj \
  -scheme ScreenshotInbox \
  -destination 'platform=macOS' build
```

## Architecture

The project starts with boundaries that later vertical slices can extend without moving filesystem, analysis, database, or action logic into views:

```text
ScreenshotInbox/
├── App/          # lifecycle and shared observable state
├── Models/       # domain and navigation types
├── Services/     # filesystem, analysis, and action services (Phase 2+)
├── Database/     # SQLite repositories and migrations (Phase 3+)
├── Views/        # main window, menu bar, settings, and components
└── Utilities/    # constants and unified logging
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for implementation notes and planned module boundaries.

## Permissions

The app uses a user-selected screenshot directory and persists access with a security-scoped bookmark. It does not request Screen Recording or Accessibility access.

## Local data

Folder bookmarks are stored in `UserDefaults`; the SQLite database and thumbnail cache are stored under:

```text
~/Library/Application Support/Screenshot Inbox/
```

Screenshots and extracted content will remain on the Mac. The project has no account, backend, analytics SDK, or telemetry.

## Known limitations

- Screenshot source-app attribution is not available from ordinary image files and remains empty.
- OCR quality depends on Apple Vision and the source image; failed OCR remains imported and is marked accordingly.
- Candidate metadata differs across macOS versions and filesystems, so conservative detection can occasionally miss a screenshot.
- Search, AI understanding, cloud sync, and managed libraries are intentionally outside this milestone.

## Tests

The unit-test target covers candidate and content classification, action generation, schema migration, workflow persistence, Trash failure ordering, duplicate prevention, URL extraction, and extension filtering.
