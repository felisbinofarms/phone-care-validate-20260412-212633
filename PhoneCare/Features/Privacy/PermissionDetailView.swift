import SwiftUI

struct PermissionDetailView: View {
    let permissionType: PermissionType
    @Environment(PermissionManager.self) private var permissionManager

    private var status: PermissionStatus {
        permissionManager.status(for: permissionType)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.lg) {
                // Status card
                statusCard

                // Educational content
                EducationalContentView(permissionType: permissionType)

                // Action
                actionSection
            }
            .padding(.horizontal, PCTheme.Spacing.md)
            .padding(.top, PCTheme.Spacing.md)
            .padding(.bottom, PCTheme.Spacing.xl)
        }
        .background(Color.pcBackground)
        .navigationTitle(permissionType.displayName)
    }

    // MARK: - Status Card

    private var statusCard: some View {
        CardView {
            HStack(spacing: PCTheme.Spacing.md) {
                Image(systemName: iconForPermission)
                    .font(.title2)
                    .foregroundStyle(statusColor)
                    .frame(width: 44, height: 44)
                    .background(statusColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: PCTheme.Radius.sm))
                    .voiceOverHidden()

                VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                    Text(permissionType.displayName)
                        .typography(.headline)

                    HStack(spacing: PCTheme.Spacing.xs) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                            .voiceOverHidden()

                        Text(statusText)
                            .typography(.subheadline, color: .pcTextSecondary)
                    }
                }

                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(permissionType.displayName): \(statusText)")
    }

    // MARK: - Action

    private var actionSection: some View {
        VStack(spacing: PCTheme.Spacing.sm) {
            if status == .denied || status == .authorized {
                Button("Open Settings") {
                    permissionManager.openSettings()
                }
                .primaryCTAStyle()
                .accessibilityHint("Opens the Settings app where you can change this permission")
            }

            Text("Permissions can only be changed in the Settings app.")
                .typography(.footnote, color: .pcTextSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Helpers

    private var iconForPermission: String {
        switch permissionType {
        case .camera:       return "camera.fill"
        case .microphone:   return "mic.fill"
        case .location:     return "location.fill"
        case .contacts:     return "person.crop.circle.fill"
        case .photos:       return "photo.fill"
        case .calendar:     return "calendar"
        case .reminders:    return "checklist"
        case .bluetooth:    return "wave.3.right"
        case .localNetwork: return "network"
        case .health:       return "heart.fill"
        case .tracking:     return "hand.raised.fill"
        }
    }

    private var statusColor: Color {
        switch status {
        case .authorized:     return .pcAccent
        case .denied:         return .pcTextSecondary
        case .notDetermined:  return .pcTextSecondary
        case .restricted:     return .pcTextSecondary
        case .limited:        return .pcAccent
        }
    }

    private var statusText: String {
        switch status {
        case .authorized:     return "Allowed"
        case .denied:         return "Denied"
        case .notDetermined:  return "Not Set"
        case .restricted:     return "Restricted"
        case .limited:        return "Limited"
        }
    }
}
