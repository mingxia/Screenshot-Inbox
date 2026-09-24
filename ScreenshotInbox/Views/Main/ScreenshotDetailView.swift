import AppKit
import SwiftUI

struct ScreenshotDetailView: View {
    let item: ScreenshotItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(nsImage: NSImage(contentsOf: item.fileURL) ?? NSImage())
                    .resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 10))
                Text(item.filename).font(.headline)
                LabeledContent("Size", value: "\(item.width) × \(item.height)")
                LabeledContent("Imported", value: item.importedAt.formatted())
                Divider()
                HStack {
                    Text("Extracted Text").font(.headline)
                    Spacer()
                    Button("Copy Text", systemImage: "doc.on.doc") { copy(item.ocrText ?? "") }
                        .disabled(item.ocrText?.isEmpty != false)
                }
                if let text = item.ocrText, !text.isEmpty {
                    Text(text).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(item.status == .analyzing ? "Extracting text…" : "No text was detected.")
                        .foregroundStyle(.secondary)
                }
                if !item.detectedURLs.isEmpty {
                    Divider()
                    Text("Links").font(.headline)
                    ForEach(item.detectedURLs, id: \.absoluteString) { url in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(url.absoluteString).textSelection(.enabled).lineLimit(2)
                            HStack {
                                Button("Open Link") { NSWorkspace.shared.open(url) }
                                Button("Copy Link") { copy(url.absoluteString) }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(minWidth: 260)
    }

    private func copy(_ value: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        AppLogger.action.info("Copied screenshot text to the pasteboard")
    }
}
