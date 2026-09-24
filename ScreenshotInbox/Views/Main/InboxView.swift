import SwiftUI

struct InboxView: View {
    let destination: SidebarDestination
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if visibleItems.isEmpty {
                EmptyState(destination: destination)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 16)], spacing: 16) {
                        ForEach(visibleItems) { item in
                            ScreenshotGridItem(item: item, thumbnailURL: appState.thumbnailService.url(for: item.id))
                                .onTapGesture { appState.selectedScreenshotID = item.id }
                        }
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle(destination.title)
        .frame(minWidth: 400)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text(destination.title)
                    .font(.largeTitle.weight(.semibold))
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if destination == .inbox {
                Button("Mark All Done") {}
                    .disabled(true)
                    .help("There are no screenshots to archive")
            }
        }
        .padding(24)
    }

    private var subtitle: String {
        switch destination {
        case .inbox: "No screenshots need your attention"
        case .allScreenshots: "Every screenshot, in one place"
        case .favorites: "Screenshots you want to keep close"
        case .archive: "Screenshots you have handled"
        }
    }

    private var visibleItems: [ScreenshotItem] {
        switch destination {
        case .inbox: appState.screenshots.filter { $0.status != .archived }
        case .allScreenshots: appState.screenshots
        case .favorites: appState.screenshots.filter(\.isFavorite)
        case .archive: appState.screenshots.filter { $0.status == .archived }
        }
    }
}

private struct ScreenshotGridItem: View {
    let item: ScreenshotItem
    let thumbnailURL: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let image = NSImage(contentsOf: thumbnailURL) {
                    Image(nsImage: image).resizable().scaledToFill()
                } else {
                    Rectangle().fill(.quaternary).overlay { Image(systemName: "photo") }
                }
            }
            .frame(height: 120).clipped().clipShape(RoundedRectangle(cornerRadius: 8))
            Text(item.filename).font(.callout.weight(.medium)).lineLimit(1)
            Text(item.createdAt, style: .relative).font(.caption).foregroundStyle(.secondary)
        }
        .padding(10).background(.background).clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12).stroke(Color(nsColor: .separatorColor).opacity(0.5)) }
    }
}
