import AppKit
import Foundation

actor ScreenshotImporter {
    private let repository: ScreenshotRepository
    private let thumbnails: ThumbnailService

    init(repository: ScreenshotRepository, thumbnails: ThumbnailService) {
        self.repository = repository
        self.thumbnails = thumbnails
    }

    func importScreenshot(at url: URL) async throws -> ScreenshotItem? {
        let values = try url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey, .isRegularFileKey])
        guard values.isRegularFile == true, ScreenshotFolderWatcher.supports(url) else { return nil }
        guard let image = NSImage(contentsOf: url), let representation = image.representations.first else { return nil }
        let item = ScreenshotItem(
            id: UUID(), fileURL: url.standardizedFileURL, filename: url.lastPathComponent,
            createdAt: values.creationDate ?? Date(), importedAt: Date(), width: representation.pixelsWide,
            height: representation.pixelsHigh, fileSize: Int64(values.fileSize ?? 0), sourceApp: nil,
            sourceBundleID: nil, ocrText: nil, detectedURLs: [], detectedQRPayloads: [], type: .screenshot,
            confidence: 1, status: .imported, isFavorite: false, archivedAt: nil, deletedAt: nil, analysisVersion: 0
        )
        guard try await repository.insert(item) else { return nil }
        do { try thumbnails.create(for: item) } catch {
            AppLogger.import.warning("Thumbnail creation failed: \(error.localizedDescription, privacy: .public)")
        }
        return item
    }
}
