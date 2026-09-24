import AppKit
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selection: SidebarDestination? = .inbox
    @Published private(set) var inboxCount = 0

    @AppStorage(PreferenceKey.showFloatingCard) var showFloatingCard = true
    @AppStorage(PreferenceKey.showInboxCount) var showInboxCount = true
    @AppStorage(PreferenceKey.extractText) var extractText = true
    @AppStorage(PreferenceKey.detectLinks) var detectLinks = true
    @AppStorage(PreferenceKey.detectQRCodes) var detectQRCodes = true

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
