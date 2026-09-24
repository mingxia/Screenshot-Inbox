import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var launchAtLogin = false

    private var desktopPath: String {
        FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first?.path ?? "~/Desktop"
    }

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch Screenshot Inbox at login", isOn: $launchAtLogin)
                    .disabled(true)
                    .help("Launch at login will be connected in a later milestone")
                Toggle("Show floating card after screenshot", isOn: $appState.showFloatingCard)
                Toggle("Show Inbox count in menu bar", isOn: $appState.showInboxCount)
            }

            Section("Screenshots") {
                LabeledContent("Screenshot folder") {
                    HStack {
                        Text(desktopPath)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Button("Change…") {}
                            .disabled(true)
                            .help("Folder selection arrives with screenshot detection")
                    }
                }
            }

            Section("Analysis") {
                Toggle("Extract text from screenshots", isOn: $appState.extractText)
                Toggle("Detect links", isOn: $appState.detectLinks)
                Toggle("Detect QR codes", isOn: $appState.detectQRCodes)
            }

            Section("Privacy") {
                Label("Screenshot analysis happens on this Mac.", systemImage: "lock.shield")
                Text("Screenshot Inbox does not upload your screenshots.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(.vertical, 8)
    }
}
