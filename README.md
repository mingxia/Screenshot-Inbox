# Screenshot Inbox

> Your screenshots were taken for a reason.

Screenshot Inbox is a local-first, native macOS utility for the moment after a screenshot is taken. It will turn screenshots created with macOS (`⌘⇧3`, `⌘⇧4`, and `⌘⇧5`) into actionable inbox items without replacing the system capture experience.

## Current milestone: Phase 1

The current implementation is the application shell:

- a native SwiftUI window with a three-column layout;
- Inbox, All Screenshots, Favorites, and Archive navigation;
- a calm Inbox Zero state;
- a lightweight menu bar experience with inbox count and quick settings;
- native Settings for general, screenshot, analysis, and privacy preferences.

Screenshot discovery and importing intentionally begin in Phase 2. The UI currently uses an empty local application state and makes no network requests.

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

Phase 1 requests no special permissions. It does not use Screen Recording or Accessibility APIs. Phase 2 will use a user-selected screenshot directory and persist access using a security-scoped bookmark where sandbox access requires it.

## Local data

Phase 1 stores preferences in the app's standard `UserDefaults` container. Future phases will store the SQLite database and thumbnail cache under:

```text
~/Library/Application Support/Screenshot Inbox/
```

Screenshots and extracted content will remain on the Mac. The project has no account, backend, analytics SDK, or telemetry.

## Known limitations

- Screenshot folder selection is presented but disabled until Phase 2 adds sandbox-safe directory access.
- The inbox is intentionally empty; watching, import, thumbnails, OCR, QR detection, actions, floating cards, and search are subsequent vertical slices.
- Launch at login is displayed as an upcoming preference and remains disabled until it is connected to Service Management.

## Tests

Phase 1 is a UI shell with no domain pipeline yet. Starting in Phase 2, automated tests will cover screenshot detection and duplicate prevention; later slices will cover importing, actions, URL extraction, status transitions, and database operations.
