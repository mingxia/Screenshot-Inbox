import XCTest
@testable import ScreenshotInbox

final class ScreenshotInboxTests: XCTestCase {
    private func repository() throws -> ScreenshotRepository {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("sqlite")
        return try ScreenshotRepository(databaseURL: url)
    }

    private func item(url: URL = URL(fileURLWithPath: "/tmp/screenshot.png")) -> ScreenshotItem {
        ScreenshotItem(
            id: UUID(), fileURL: url, filename: url.lastPathComponent, createdAt: Date(timeIntervalSince1970: 1),
            importedAt: Date(timeIntervalSince1970: 2), width: 100, height: 80, fileSize: 42,
            sourceApp: nil, sourceBundleID: nil, ocrText: nil, detectedURLs: [], detectedQRPayloads: [],
            type: .screenshot, confidence: 1, status: .imported, isFavorite: false,
            archivedAt: nil, deletedAt: nil, analysisVersion: 0
        )
    }

    func testDatabaseInsertAndRead() async throws {
        let repository = try repository()
        let expected = item()
        XCTAssertTrue(try await repository.insert(expected))
        let items = try await repository.fetchAll()
        XCTAssertEqual(items, [expected])
    }

    func testDuplicateFileURLIsNotInserted() async throws {
        let repository = try repository()
        XCTAssertTrue(try await repository.insert(item()))
        XCTAssertFalse(try await repository.insert(item()))
        XCTAssertEqual(try await repository.fetchAll().count, 1)
    }

    func testStatusPersists() async throws {
        let repository = try repository()
        let expected = item()
        _ = try await repository.insert(expected)
        try await repository.updateStatus(id: expected.id, status: .analysisFailed)
        XCTAssertEqual(try await repository.fetchAll().first?.status, .analysisFailed)
    }

    func testURLExtractionFiltersAndDeduplicates() {
        let urls = ScreenshotAnalyzer.extractURLs(from: "See https://example.com/a and https://example.com/a, not ftp://example.com")
        XCTAssertEqual(urls.map(\.absoluteString), ["https://example.com/a"])
    }

    func testScreenshotExtensionsAreCaseInsensitive() {
        for name in ["one.png", "two.JPG", "three.jpeg", "four.HEIC"] {
            XCTAssertTrue(ScreenshotFolderWatcher.supports(URL(fileURLWithPath: name)))
        }
        for name in ["image.gif", "notes.txt", "png"] {
            XCTAssertFalse(ScreenshotFolderWatcher.supports(URL(fileURLWithPath: name)))
        }
    }

    func testNativeScreenshotMetadataIsStrongEvidence() {
        let result = candidateClassifier.classify(signals(
            nameMatches: false, screenshotMetadata: true, internetOrigin: false, isPNG: true
        ), observedAt: now)
        XCTAssertTrue(result.isLikelyScreenshot)
        XCTAssertTrue(result.reasons.contains(.screenshotMetadata))
    }

    func testBrowserDownloadPNGIsIgnoredEvenWhenRecentAndNamedLikeScreenshot() {
        let result = candidateClassifier.classify(signals(
            nameMatches: true, screenshotMetadata: false, internetOrigin: true, isPNG: true
        ), observedAt: now)
        XCTAssertFalse(result.isLikelyScreenshot)
        XCTAssertTrue(result.reasons.contains(.browserDownloadOrigin))
    }

    func testCopiedJPGIsIgnored() {
        let result = candidateClassifier.classify(signals(
            nameMatches: false, screenshotMetadata: false, internetOrigin: false, isPNG: false
        ), observedAt: now)
        XCTAssertFalse(result.isLikelyScreenshot)
    }

    func testLocalizedScreenshotFilenameIsRecognizedWithoutEnglishPrefix() {
        XCTAssertTrue(ScreenshotCandidateClassifier.matchesDefaultScreenshotFilename("截屏 2026-09-25 10.32.18"))
        let result = candidateClassifier.classify(signals(
            nameMatches: true, screenshotMetadata: false, internetOrigin: false, isPNG: true
        ), observedAt: now)
        XCTAssertTrue(result.isLikelyScreenshot)
    }

    func testFilenameAloneIsNotEnough() {
        var candidate = signals(nameMatches: true, screenshotMetadata: false, internetOrigin: false, isPNG: true)
        candidate = ScreenshotCandidateSignals(
            creationDate: now.addingTimeInterval(-120),
            hasScreenshotMetadata: candidate.hasScreenshotMetadata,
            hasInternetOrigin: candidate.hasInternetOrigin,
            filenameMatchesScreenshotPattern: candidate.filenameMatchesScreenshotPattern,
            isPNG: candidate.isPNG
        )
        XCTAssertFalse(candidateClassifier.classify(candidate, observedAt: now).isLikelyScreenshot)
    }

    private var candidateClassifier: ScreenshotCandidateClassifier { ScreenshotCandidateClassifier() }
    private var now: Date { Date(timeIntervalSince1970: 1_000) }

    private func signals(
        nameMatches: Bool,
        screenshotMetadata: Bool,
        internetOrigin: Bool,
        isPNG: Bool
    ) -> ScreenshotCandidateSignals {
        ScreenshotCandidateSignals(
            creationDate: now,
            hasScreenshotMetadata: screenshotMetadata,
            hasInternetOrigin: internetOrigin,
            filenameMatchesScreenshotPattern: nameMatches,
            isPNG: isPNG
        )
    }
}
