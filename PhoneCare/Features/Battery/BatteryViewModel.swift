import SwiftUI
import SwiftData

enum BatteryTimeRange: String, CaseIterable, Identifiable {
    case thirtyDays = "30 Days"
    case ninetyDays = "90 Days"
    case oneYear = "1 Year"

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .thirtyDays:  return 30
        case .ninetyDays:  return 90
        case .oneYear:     return 365
        }
    }
}

struct BatteryTip: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
}

@MainActor
@Observable
final class BatteryViewModel {

    // MARK: - State

    private(set) var currentLevel: Double = 0 // 0-1
    private(set) var isCharging: Bool = false
    private(set) var thermalState: Int = 0
    private(set) var isLowPowerMode: Bool = false
    private(set) var maxCapacity: Double?
    private(set) var snapshots: [BatterySnapshot] = []
    private(set) var tips: [BatteryTip] = []
    private(set) var isLoading: Bool = false

    var selectedTimeRange: BatteryTimeRange = .thirtyDays

    // MARK: - Computed

    var levelPercentage: Int {
        Int(currentLevel * 100)
    }

    var chargingStateText: String {
        if isCharging { return "Charging" }
        return "On Battery"
    }

    var chargingIcon: String {
        if isCharging { return "bolt.fill" }
        if currentLevel > 0.75 { return "battery.100percent" }
        if currentLevel > 0.5 { return "battery.75percent" }
        if currentLevel > 0.25 { return "battery.50percent" }
        return "battery.25percent"
    }

    var thermalStateText: String {
        switch thermalState {
        case 0: return "Normal"
        case 1: return "Slightly warm"
        case 2: return "Warm"
        case 3: return "Hot"
        default: return "Normal"
        }
    }

    var thermalStateColor: Color {
        switch thermalState {
        case 0, 1: return .pcAccent
        case 2: return .pcWarning
        case 3: return .pcWarning
        default: return .pcAccent
        }
    }

    var filteredSnapshots: [BatterySnapshot] {
        let cutoff = Calendar.current.date(
            byAdding: .day,
            value: -selectedTimeRange.days,
            to: Date()
        ) ?? Date()
        return snapshots.filter { $0.date >= cutoff }
    }

    var capacityText: String {
        if let cap = maxCapacity {
            return "\(Int(cap * 100))%"
        }
        return "Not available"
    }

    // MARK: - Load

    func load(dataManager: DataManager) {
        isLoading = true
        defer { isLoading = false }

        // Load current state from latest scan
        do {
            if let scan = try dataManager.latestScanResult() {
                currentLevel = scan.batteryLevel
                maxCapacity = scan.batteryHealth
            }

            // Load snapshot history
            snapshots = try dataManager.fetch(
                BatterySnapshot.self,
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )

            // Use most recent snapshot for current state details
            if let latest = snapshots.first {
                currentLevel = latest.level
                isCharging = latest.isCharging
                thermalState = latest.thermalState
                isLowPowerMode = latest.isLowPowerMode
                if let cap = latest.maxCapacity {
                    maxCapacity = cap
                }
            }

            tips = generateTips()
        } catch {
            // Show defaults
            tips = generateTips()
        }
    }

    // MARK: - Tips

    private func generateTips() -> [BatteryTip] {
        var result: [BatteryTip] = []

        if thermalState >= 2 {
            result.append(BatteryTip(
                id: "thermal",
                icon: "thermometer.sun.fill",
                title: "Phone is warm",
                description: "Try removing the case and moving to a cooler spot. Avoid using it while charging."
            ))
        }

        if !isLowPowerMode && currentLevel < 0.3 {
            result.append(BatteryTip(
                id: "lowPower",
                icon: "bolt.slash.fill",
                title: "Try Low Power Mode",
                description: "Low Power Mode reduces background activity and can help your battery last longer."
            ))
        }

        result.append(BatteryTip(
            id: "charging",
            icon: "battery.100percent.bolt",
            title: "Charge between 20% and 80%",
            description: "Keeping your battery in this range can help maintain its long-term health."
        ))

        result.append(BatteryTip(
            id: "brightness",
            icon: "sun.max.fill",
            title: "Use auto-brightness",
            description: "Auto-brightness adjusts your screen to save battery based on your surroundings."
        ))

        if let cap = maxCapacity, cap < 0.8 {
            result.append(BatteryTip(
                id: "replace",
                icon: "wrench.and.screwdriver.fill",
                title: "Battery capacity is low",
                description: "Your battery capacity is at \(Int(cap * 100))%. You may want to consider getting it replaced for better performance."
            ))
        }

        return result
    }
}
