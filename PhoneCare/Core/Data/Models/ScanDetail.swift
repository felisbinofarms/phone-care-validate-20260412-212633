import Foundation
import SwiftData

@Model
final class ScanDetail {
    var id: UUID = UUID()

    /// Category grouping, e.g. "storage", "photos", "contacts", "battery", "privacy".
    var category: String = ""

    /// Specific detail within the category, e.g. "duplicatePhotos", "blurryPhotos".
    var detailType: String = ""

    var value: Double = 0
    var unit: String = ""
    var sizeInBytes: Int64 = 0

    // MARK: - Relationship

    var scanResult: ScanResult?

    // MARK: - Init

    init(
        id: UUID = UUID(),
        category: String = "",
        detailType: String = "",
        value: Double = 0,
        unit: String = "",
        sizeInBytes: Int64 = 0,
        scanResult: ScanResult? = nil
    ) {
        self.id = id
        self.category = category
        self.detailType = detailType
        self.value = value
        self.unit = unit
        self.sizeInBytes = sizeInBytes
        self.scanResult = scanResult
    }
}
