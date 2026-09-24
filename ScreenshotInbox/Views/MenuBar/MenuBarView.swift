import AppKit
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Screenshot Inbox")
                    .font(.headline)
                Text(appState.attentionSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Label("Recent screenshots will appear here", systemImage: "photo.on.rectangle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 60)

            Divider()

            Button("Open Inbox", systemImage: "tray") {
                appState.openMainWindow()
            }
            .keyboardShortcut("o")

            Button("Quick Settings…", systemImage: "gearshape") {
                appState.openSettings()
            }

            Divider()

            Button("Quit Screenshot Inbox") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(16)
        .frame(width: 300)
    }
}
