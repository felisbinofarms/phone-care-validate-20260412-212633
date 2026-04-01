import Foundation
import Photos
import UIKit
import OSLog

// MARK: - Duplicate Group

struct DuplicateGroup: Sendable, Identifiable {
    let id: String
    let assetIdentifiers: [String]
    let suggestedKeepIdentifier: String
    let estimatedSavingsBytes: Int64

    var count: Int { assetIdentifiers.count }

    var duplicateIdentifiers: [String] {
        assetIdentifiers.filter { $0 != suggestedKeepIdentifier }
    }
}

// MARK: - Photo Analysis Result

struct PhotoAnalysisResult: Sendable {
    let totalPhotos: Int
    let duplicateGroups: [DuplicateGroup]
    let screenshotIdentifiers: [String]
    let largeVideoIdentifiers: [String]
    let blurryIdentifiers: [String]

    var duplicateCount: Int {
        duplicateGroups.reduce(0) { $0 + $1.count - 1 }
    }

    var estimatedDuplicateSavings: Int64 {
        duplicateGroups.reduce(0) { $0 + $1.estimatedSavingsBytes }
    }

    var screenshotCount: Int { screenshotIdentifiers.count }
    var largeVideoCount: Int { largeVideoIdentifiers.count }
    var blurryCount: Int { blurryIdentifiers.count }
}

// MARK: - Photo Analyzer

@MainActor
@Observable
final class PhotoAnalyzer {

    // MARK: - State

    private(set) var result: PhotoAnalysisResult?
    private(set) var isAnalyzing: Bool = false
    private(set) var progress: Double = 0.0
    private(set) var statusMessage: String = ""

    // MARK: - Configuration

    /// Minimum video file size to flag as "large" (50 MB)
    private let largeVideoThreshold: Int64 = 50 * 1024 * 1024

    /// Time proximity for duplicate detection (within 2 seconds)
    private let duplicateDateProximity: TimeInterval = 2.0

    // MARK: - Private

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PhoneCare", category: "PhotoAnalyzer")

    // MARK: - Analyze

    func analyze() async -> PhotoAnalysisResult {
        isAnalyzing = true
        progress = 0.0
        statusMessage = "Scanning photos..."

        defer {
            isAnalyzing = false
            progress = 1.0
        }

        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            let emptyResult = PhotoAnalysisResult(
                totalPhotos: 0,
                duplicateGroups: [],
                screenshotIdentifiers: [],
                largeVideoIdentifiers: [],
                blurryIdentifiers: []
            )
            result = emptyResult
            return emptyResult
        }

        // Run heavy work off the main actor
        let analysisResult = await Task.detached { [largeVideoThreshold, duplicateDateProximity] in
            await Self.performAnalysis(
                largeVideoThreshold: largeVideoThreshold,
                duplicateDateProximity: duplicateDateProximity
            )
        }.value

        // Update progress on main actor through the stages
        progress = 1.0
        statusMessage = "Photo scan complete"
        result = analysisResult
        return analysisResult
    }

    // MARK: - Progress Updates (called from within analyze)

    func updateProgress(_ value: Double, message: String) {
        progress = value
        statusMessage = message
    }

    // MARK: - Cache Support

    func saveCache(to dataManager: DataManager, analysisResult: PhotoAnalysisResult) async {
        // Get the current library change token
        let changeToken: Data? = nil // PHPhotoLibrary change token requires registration

        let duplicateGroupIDs = analysisResult.duplicateGroups.map { $0.assetIdentifiers }

        let cache = PhotoScanCache(
            libraryChangeToken: changeToken,
            duplicateGroups: duplicateGroupIDs,
            screenshotIDs: analysisResult.screenshotIdentifiers,
            blurryIDs: analysisResult.blurryIdentifiers,
            largeVideoIDs: analysisResult.largeVideoIdentifiers,
            totalScannedCount: analysisResult.totalPhotos,
            scanDate: Date()
        )

        do {
            // Delete old caches first
            try dataManager.deleteAll(PhotoScanCache.self)
            try dataManager.save(cache)
            logger.info("Photo scan cache saved.")
        } catch {
            logger.error("Failed to save photo scan cache: \(error.localizedDescription)")
        }
    }

    // MARK: - Static Analysis (runs off main actor)

    private static func performAnalysis(
        largeVideoThreshold: Int64,
        duplicateDateProximity: TimeInterval
    ) async -> PhotoAnalysisResult {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.includeAllBurstAssets = false
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let allAssets = PHAsset.fetchAssets(with: fetchOptions)
        let totalCount = allAssets.count

        guard totalCount > 0 else {
            return PhotoAnalysisResult(
                totalPhotos: 0,
                duplicateGroups: [],
                screenshotIdentifiers: [],
                largeVideoIdentifiers: [],
                blurryIdentifiers: []
            )
        }

        // Collect asset metadata for grouping
        struct AssetInfo: Sendable {
            let identifier: String
            let creationDate: Date?
            let mediaType: PHAssetMediaType
            let mediaSubtypes: PHAssetMediaSubtype
            let pixelWidth: Int
            let pixelHeight: Int
            let estimatedFileSize: Int64
        }

        var assetInfos: [AssetInfo] = []
        assetInfos.reserveCapacity(totalCount)

        for i in 0..<totalCount {
            let asset = allAssets.object(at: i)

            // Estimate file size from resources
            var estimatedSize: Int64 = 0
            let resources = PHAssetResource.assetResources(for: asset)
            for resource in resources {
                if let size = resource.value(forKey: "fileSize") as? Int64 {
                    estimatedSize += size
                }
            }

            // Fallback estimate if no resource size available
            if estimatedSize == 0 {
                let pixelCount = Int64(asset.pixelWidth * asset.pixelHeight)
                estimatedSize = asset.mediaType == .video
                    ? pixelCount * 4  // rough video estimate
                    : pixelCount * 3  // rough photo estimate (RGB bytes)
            }

            assetInfos.append(AssetInfo(
                identifier: asset.localIdentifier,
                creationDate: asset.creationDate,
                mediaType: asset.mediaType,
                mediaSubtypes: asset.mediaSubtypes,
                pixelWidth: asset.pixelWidth,
                pixelHeight: asset.pixelHeight,
                estimatedFileSize: estimatedSize
            ))
        }

        // 1. Screenshots
        let screenshots = assetInfos.filter { $0.mediaSubtypes.contains(.photoScreenshot) }
        let screenshotIDs = screenshots.map(\.identifier)

        // 2. Large videos
        let largeVideos = assetInfos.filter {
            $0.mediaType == .video && $0.estimatedFileSize > largeVideoThreshold
        }
        let largeVideoIDs = largeVideos.map(\.identifier)

        // 3. Blurry detection (simplified: small pixel dimensions for photos)
        let blurryThresholdPixels = 500 * 500
        let blurryPhotos = assetInfos.filter {
            $0.mediaType == .image
            && !$0.mediaSubtypes.contains(.photoScreenshot)
            && ($0.pixelWidth * $0.pixelHeight) < blurryThresholdPixels
            && $0.pixelWidth > 0
        }
        let blurryIDs = blurryPhotos.map(\.identifier)

        // 4. Duplicate detection: group by similar file size + creation date proximity
        let photos = assetInfos.filter { $0.mediaType == .image && !$0.mediaSubtypes.contains(.photoScreenshot) }

        var duplicateGroups: [DuplicateGroup] = []
        var processedIdentifiers: Set<String> = []

        // Group by approximate file size (within 5% tolerance)
        let sizeTolerance: Double = 0.05

        for i in 0..<photos.count {
            let photo = photos[i]
            guard !processedIdentifiers.contains(photo.identifier) else { continue }
            guard photo.estimatedFileSize > 0 else { continue }

            var group: [AssetInfo] = [photo]

            for j in (i + 1)..<photos.count {
                let candidate = photos[j]
                guard !processedIdentifiers.contains(candidate.identifier) else { continue }
                guard candidate.estimatedFileSize > 0 else { continue }

                // Check file size similarity
                let sizeDiff = abs(Double(photo.estimatedFileSize) - Double(candidate.estimatedFileSize))
                let maxSize = Double(max(photo.estimatedFileSize, candidate.estimatedFileSize))
                guard maxSize > 0 && (sizeDiff / maxSize) <= sizeTolerance else { continue }

                // Check creation date proximity
                if let date1 = photo.creationDate, let date2 = candidate.creationDate {
                    let timeDiff = abs(date1.timeIntervalSince(date2))
                    guard timeDiff <= duplicateDateProximity else { continue }
                } else {
                    // If either lacks a date, skip
                    continue
                }

                // Check same dimensions
                guard photo.pixelWidth == candidate.pixelWidth
                   && photo.pixelHeight == candidate.pixelHeight else { continue }

                group.append(candidate)
            }

            if group.count >= 2 {
                // Suggest keeping the one with highest pixel count (or first if tied)
                let best = group.max(by: {
                    ($0.pixelWidth * $0.pixelHeight) < ($1.pixelWidth * $1.pixelHeight)
                }) ?? group[0]

                let savings = group
                    .filter { $0.identifier != best.identifier }
                    .reduce(Int64(0)) { $0 + $1.estimatedFileSize }

                let dupGroup = DuplicateGroup(
                    id: UUID().uuidString,
                    assetIdentifiers: group.map(\.identifier),
                    suggestedKeepIdentifier: best.identifier,
                    estimatedSavingsBytes: savings
                )
                duplicateGroups.append(dupGroup)

                for info in group {
                    processedIdentifiers.insert(info.identifier)
                }
            }
        }

        return PhotoAnalysisResult(
            totalPhotos: totalCount,
            duplicateGroups: duplicateGroups,
            screenshotIdentifiers: screenshotIDs,
            largeVideoIdentifiers: largeVideoIDs,
            blurryIdentifiers: blurryIDs
        )
    }
}
