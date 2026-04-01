import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {

    // MARK: - State

    var appearanceMode: AppearanceMode = .system
    var weeklyNotification: Bool = true
    var duplicateAlerts: Bool = true
    var batteryAlerts: Bool = true

    var showDeleteConfirmation: Bool = false
    var showDeleteFinalConfirmation: Bool = false
    var isDeleting: Bool = false
    var deleteComplete: Bool = false

    // MARK: - Load

    func load(dataManager: DataManager, appState: AppState) {
        appearanceMode = appState.appearanceMode

        do {
            let prefs = try dataManager.userPreferences()
            weeklyNotification = prefs.weeklyNotification
            duplicateAlerts = prefs.duplicateAlerts
            batteryAlerts = prefs.batteryAlerts
        } catch {
            // Use defaults
        }
    }

    // MARK: - Save

    func saveAppearance(appState: AppState) {
        appState.appearanceMode = appearanceMode
    }

    func saveNotifications(dataManager: DataManager) {
        do {
            let prefs = try dataManager.userPreferences()
            prefs.weeklyNotification = weeklyNotification
            prefs.duplicateAlerts = duplicateAlerts
            prefs.batteryAlerts = batteryAlerts
            try dataManager.saveContext()
        } catch {
            // Silent fail
        }
    }

    // MARK: - Delete All Data

    func deleteAllData(dataManager: DataManager) {
        isDeleting = true
        do {
            try dataManager.deleteAllData()
            deleteComplete = true
        } catch {
            // Show error state
        }
        isDeleting = false
    }

    // MARK: - App Info

    var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
