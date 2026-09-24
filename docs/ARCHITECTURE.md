# Architecture Notes

## Guiding boundaries

Screenshot Inbox uses a vertical-slice approach while keeping its long-lived responsibilities separate:

- **Views** render state and forward user intent. They do not inspect screenshot content or decide which actions should exist.
- **App state** owns presentation-level selection and user preferences.
- **Services** will own filesystem watching, importing, Vision analysis, action generation, file operations, and thumbnails.
- **Database repositories** will own SQLite persistence and FTS5 queries.
- **Models** will remain independent from SwiftUI wherever possible.

The Phase 1 shell deliberately contains no placeholder network layer. Screenshot data will never need to leave the device.

## Screenshot detection (Phase 2)

The screenshot directory service will resolve the configured directory and retain a security-scoped bookmark. A filesystem-event-driven watcher will observe that directory rather than poll it. Candidate PNG, JPEG, and HEIC files will be checked for recency and stable size before being passed to the importer. Database identity will provide durable duplicate prevention.

Changing the configured directory will stop the existing watcher before a new watcher starts. Existing files will not be imported by default.

## Vision pipeline (Phase 4–5)

Analysis will run away from the main actor. OCR and barcode requests will be independent enhancements: either may fail without preventing the preliminary screenshot record from appearing in the inbox. URL extraction will combine `NSDataDetector`, URL validation, and a conservative fallback for domain-like text. Analysis results will be persisted before the UI and floating card are updated.

No OCR text or image content will be written to logs or telemetry.

## Database design (Phase 3 and Phase 8)

SQLite will store one canonical screenshot record. Status, creation time, type, and favorite state will be indexed. URL and QR payload arrays can initially be encoded as JSON. An FTS5 external-content index will cover filename, OCR text, detected URLs, source app, and type.

Archiving changes only record state and never moves the original file. Deletion will use the system Trash and mark the record deleted only after a safe file operation. Missing original files remain representable through cached thumbnails.

## File access model (Phase 2)

The app sandbox will grant user-selected read/write access to the screenshot directory. Access will be restored from a security-scoped bookmark at launch and balanced with `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()`. Screenshot Inbox will not request Screen Recording permission because macOS remains responsible for capture.

## Floating panel (Phase 7)

The floating card will be an `NSPanel` configured as non-activating so it cannot steal focus. It will appear near the lower-right corner of the active screen, host a SwiftUI card, and dismiss after a short delay. Pointer hover will suspend the timeout. Its three primary actions will come from `ActionEngine`; the panel will not reproduce classification rules.
