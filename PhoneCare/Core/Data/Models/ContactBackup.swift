import Foundation
import SwiftData

@Model
final class ContactBackup {
    var id: UUID = UUID()

    /// Archived CNContact data for the original contact before merge.
    var originalContactData: Data = Data()

    /// The identifier of the contact that was kept after the merge.
    var mergedContactID: String = ""

    var mergeDate: Date = Date()
    var undoDeadline: Date = Date()
    var isRestored: Bool = false

    // MARK: - Retention

    /// Contact backups older than this many days should be purged.
    static let retentionDays: Int = 30

    // MARK: - Convenience

    var canRestore: Bool {
        !isRestored && Date() <= undoDeadline
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        originalContactData: Data = Data(),
        mergedContactID: String = "",
        mergeDate: Date = Date(),
        undoDeadline: Date? = nil,
        isRestored: Bool = false
    ) {
        self.id = id
        self.originalContactData = originalContactData
        self.mergedContactID = mergedContactID
        self.mergeDate = mergeDate
        self.undoDeadline = undoDeadline ?? Calendar.current.date(
            byAdding: .day,
            value: ContactBackup.retentionDays,
            to: mergeDate
        ) ?? mergeDate
        self.isRestored = isRestored
    }
}
