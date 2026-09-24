import Foundation

struct ScreenshotAnalyzer {
    static let analysisVersion = 1

    private let repository: ScreenshotRepository
    private let ocr: OCRService

    init(repository: ScreenshotRepository, ocr: OCRService = OCRService()) {
        self.repository = repository
        self.ocr = ocr
    }

    func analyze(_ item: ScreenshotItem) async {
        do {
            try await repository.updateStatus(id: item.id, status: .analyzing)
            let text = try await ocr.recognizeText(in: item.fileURL)
            let urls = Self.extractURLs(from: text)
            try await repository.updateAnalysis(
                id: item.id, text: text, urls: urls, status: .ready, version: Self.analysisVersion
            )
            AppLogger.analysis.info("OCR completed for \(item.filename, privacy: .public)")
        } catch {
            AppLogger.analysis.error("OCR failed for \(item.filename, privacy: .public): \(error.localizedDescription, privacy: .public)")
            do { try await repository.updateStatus(id: item.id, status: .analysisFailed) } catch {
                AppLogger.database.error("Unable to persist OCR failure: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    static func extractURLs(from text: String) -> [URL] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        var seen = Set<String>()
        return detector.matches(in: text, options: [], range: range).compactMap { match in
            guard let url = match.url, let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
                  seen.insert(url.absoluteString).inserted else { return nil }
            return url
        }
    }
}
