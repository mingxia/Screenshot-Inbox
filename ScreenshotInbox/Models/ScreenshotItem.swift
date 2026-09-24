import Foundation

struct ScreenshotItem: Identifiable, Equatable, Sendable {
    enum ItemType: String, Sendable { case screenshot, unknown }
    enum Status: String, Sendable { case imported, analyzing, ready, analysisFailed, archived, deleted }

    let id: UUID
    let fileURL: URL
    let filename: String
    let createdAt: Date
    let importedAt: Date
    let width: Int
    let height: Int
    let fileSize: Int64
    let sourceApp: String?
    let sourceBundleID: String?
    var ocrText: String?
    var detectedURLs: [URL]
    var detectedQRPayloads: [String]
    let type: ItemType
    var confidence: Double
    var status: Status
    var isFavorite: Bool
    var archivedAt: Date?
    var deletedAt: Date?
    var analysisVersion: Int
}
