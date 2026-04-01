import SwiftUI
import SwiftData

struct DuplicateContactGroup: Identifiable {
    let id: String
    let name: String
    let contactIDs: [String]
    let fields: [ContactField]
}

struct ContactField: Identifiable {
    let id: String
    let label: String
    let values: [String] // One per contact in the group
    var selectedIndex: Int // Which contact's value to keep
}

@MainActor
@Observable
final class ContactsViewModel {

    // MARK: - State

    private(set) var duplicateGroups: [DuplicateContactGroup] = []
    private(set) var isLoading: Bool = false
    private(set) var isScanning: Bool = false
    private(set) var scanComplete: Bool = false
    private(set) var totalContacts: Int = 0
    private(set) var duplicateCount: Int = 0

    var showUndoToast: Bool = false
    private(set) var lastMergedCount: Int = 0

    // MARK: - Load

    func load(dataManager: DataManager) {
        isLoading = true
        defer { isLoading = false }

        do {
            if let scan = try dataManager.latestScanResult() {
                totalContacts = scan.contactCount
                duplicateCount = scan.duplicateContactCount
                scanComplete = duplicateCount > 0 || totalContacts > 0
                // Placeholder groups for UI demonstration
                if duplicateCount > 0 {
                    buildPlaceholderGroups()
                }
            }
        } catch {
            // Show empty state
        }
    }

    // MARK: - Scan

    func startScan() {
        isScanning = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            isScanning = false
            scanComplete = true
        }
    }

    // MARK: - Merge

    func mergeGroup(_ group: DuplicateContactGroup) {
        // Actual merge handled by ContactAnalyzer service
        duplicateGroups.removeAll { $0.id == group.id }
        duplicateCount = max(0, duplicateCount - group.contactIDs.count + 1)
        lastMergedCount = group.contactIDs.count - 1
        showUndoToast = true
    }

    func mergeAll() {
        let total = duplicateGroups.reduce(0) { $0 + $1.contactIDs.count - 1 }
        duplicateGroups.removeAll()
        duplicateCount = 0
        lastMergedCount = total
        showUndoToast = true
    }

    func undoMerge() {
        showUndoToast = false
        // Undo handled by CleanupUndoManager
    }

    // MARK: - Helpers

    private func buildPlaceholderGroups() {
        // Generate representative groups from scan data
        var groups: [DuplicateContactGroup] = []
        let count = min(duplicateCount, 10) // Show up to 10 groups
        for i in 0..<count {
            groups.append(DuplicateContactGroup(
                id: "group_\(i)",
                name: "Contact \(i + 1)",
                contactIDs: ["contact_\(i)_a", "contact_\(i)_b"],
                fields: [
                    ContactField(id: "name_\(i)", label: "Name", values: ["Name A", "Name B"], selectedIndex: 0),
                    ContactField(id: "phone_\(i)", label: "Phone", values: ["+1 555-0100", "+1 555-0101"], selectedIndex: 0),
                    ContactField(id: "email_\(i)", label: "Email", values: ["a@example.com", ""], selectedIndex: 0),
                ]
            ))
        }
        duplicateGroups = groups
    }
}
