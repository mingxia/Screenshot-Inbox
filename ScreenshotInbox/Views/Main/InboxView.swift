import SwiftUI

struct InboxView: View {
    let destination: SidebarDestination

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            EmptyState(destination: destination)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
