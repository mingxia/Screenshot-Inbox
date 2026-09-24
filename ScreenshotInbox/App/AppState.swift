import AppKit
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selection: SidebarDestination? = .inbox
    @Published private(set) var inboxCount = 0
    @Published private(set) var screenshots: [ScreenshotItem] = []
    @Published var selectedScreenshotID: UUID?
    let folderAccess: ScreenshotFolderAccess
    let thumbnailService: ThumbnailService
    private let repository: ScreenshotRepository
    private let importer: ScreenshotImporter
    private let analyzer: ScreenshotAnalyzer
    private var watcher: ScreenshotFolderWatcher!
    private var didOfferFolderSelection = false

    @AppStorage(PreferenceKey.showFloatingCard) var showFloatingCard = true
    @AppStorage(PreferenceKey.showInboxCount) var showInboxCount = true
    @AppStorage(PreferenceKey.extractText) var extractText = true
    @AppStorage(PreferenceKey.detectLinks) var detectLinks = true
    @AppStorage(PreferenceKey.detectQRCodes) var detectQRCodes = true

    init() {
        let folderAccess = ScreenshotFolderAccess()
        self.folderAccess = folderAccess
        let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Screenshot Inbox", isDirectory: true)
        try? FileManager.default.createDirectory(at: applicationSupport, withIntermediateDirectories: true)
        do {
            repository = try ScreenshotRepository(databaseURL: applicationSupport.appendingPathComponent("ScreenshotInbox.sqlite"))
        } catch {
            fatalError("Unable to open local screenshot database: \(error)")
        }
        thumbnailService = ThumbnailService(cacheDirectory: applicationSupport.appendingPathComponent("Thumbnails", isDirectory: true))
        importer = ScreenshotImporter(repository: repository, thumbnails: thumbnailService)
        analyzer = ScreenshotAnalyzer(repository: repository)
        watcher = ScreenshotFolderWatcher { [weak self] url in
            Task { await self?.importAndRefresh(url) }
        }
        if let url = folderAccess.folderURL {
            watcher.start(watching: url)
        }
        Task { await refresh() }
    }

    func chooseScreenshotFolder() {
        if let url = folderAccess.chooseFolder() {
            watcher.start(watching: url)
        }
        objectWillChange.send()
    }

    func offerFolderSelectionIfNeeded() {
        guard folderAccess.folderURL == nil, !didOfferFolderSelection else { return }
        didOfferFolderSelection = true
        chooseScreenshotFolder()
    }

    var selectedScreenshot: ScreenshotItem? {
        screenshots.first { $0.id == selectedScreenshotID }
    }

    func refresh() async {
        do {
            screenshots = try await repository.fetchAll()
            inboxCount = screenshots.filter { $0.status != .archived && $0.status != .deleted }.count
        } catch {
            AppLogger.database.error("Unable to load screenshots: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func importAndRefresh(_ url: URL) async {
        do {
            guard let item = try await importer.importScreenshot(at: url) else { return }
            AppLogger.import.info("Imported screenshot: \(item.fileURL.path, privacy: .public)")
            await refresh()
            Task {
                await analyzer.analyze(item)
                await refresh()
            }
        } catch {
            AppLogger.import.error("Screenshot import failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    var menuBarLabel: String {
        showInboxCount && inboxCount > 0 ? "Screenshot Inbox · \(inboxCount)" : "Screenshot Inbox"
    }

    var attentionSummary: String {
        switch inboxCount {
        case 0: "No screenshots need attention"
        case 1: "1 screenshot needs attention"
        default: "\(inboxCount) screenshots need attention"
        }
    }

    func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first(where: { !($0 is NSPanel) })?.makeKeyAndOrderFront(nil)
    }

    func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
