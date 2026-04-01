import Foundation
import SwiftData

enum CleanupActionType: String, Codable, CaseIterable {
    case photoDelete
    case contactMerge
    case videoCompress
}

@Model
final class CleanupAction {
    var id: UUID = UUID()

    /// Stored as the raw value of `CleanupActionType`.
    var actionType: String = CleanupActionType.photoDelete.rawValue

    var itemCount: Int = 0
    var bytesFreed: Int64 = 0
    var timestamp: Date = Date()
    var undoDeadline: Date = Date()

    /// Serialised state needed to reverse the action.
    var undoData: Data?

    var isUndone: Bool = false

    // MARK: - Convenience

    var cleanupType: CleanupActionType {
        get { CleanupActionType(rawValue: actionType) ?? .photoDelete }
        set { actionType = newValue.rawValue }
    }

    var isUndoExpired: Bool {
        Date() > undoDeadline
    }

    var canUndo: Bool {
        !isUndone && !isUndoExpired && undoData != nil
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        actionType: CleanupActionType = .photoDelete,
        itemCount: Int = 0,
        bytesFreed: Int64 = 0,
        timestamp: Date = Date(),
        undoDeadline: Date = Date(),
        undoData: Data? = nil,
        isUndone: Bool = false
    ) {
        self.id = id
        self.actionType = actionType.rawValue
        self.itemCount = itemCount
        self.bytesFreed = bytesFreed
        self.timestamp = timestamp
        self.undoDeadline = undoDeadline
        self.undoData = undoData
        self.isUndone = isUndone
    }
}
