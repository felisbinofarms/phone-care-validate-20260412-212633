import Foundation
import SwiftData

@Model
final class BatterySnapshot {
    var id: UUID = UUID()
    var date: Date = Date()

    /// Battery level 0-1.
    var level: Double = 0

    var isCharging: Bool = false

    /// Maps to `ProcessInfo.ThermalState.rawValue`.
    var thermalState: Int = 0

    /// Maximum battery capacity as reported by the system (0-1), if available.
    var maxCapacity: Double?

    var isLowPowerMode: Bool = false

    // MARK: - Retention

    /// Snapshots older than this many days should be purged.
    static let retentionDays: Int = 365

    // MARK: - Init

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        level: Double = 0,
        isCharging: Bool = false,
        thermalState: Int = 0,
        maxCapacity: Double? = nil,
        isLowPowerMode: Bool = false
    ) {
        self.id = id
        self.date = date
        self.level = level
        self.isCharging = isCharging
        self.thermalState = thermalState
        self.maxCapacity = maxCapacity
        self.isLowPowerMode = isLowPowerMode
    }
}
