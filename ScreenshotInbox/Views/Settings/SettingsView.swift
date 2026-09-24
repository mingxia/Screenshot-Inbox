import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var launchAtLogin = false

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
                        Text(appState.folderAccess.displayPath)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Button(appState.folderAccess.folderURL == nil ? "Choose…" : "Change…") {
                            appState.chooseScreenshotFolder()
                        }
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
