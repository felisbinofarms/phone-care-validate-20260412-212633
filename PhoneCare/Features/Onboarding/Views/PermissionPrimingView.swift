import SwiftUI

struct PermissionPrimingView: View {
    let permissionManager: PermissionManager
    let onContinue: () -> Void
    let onBack: () -> Void

    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                title: "A couple quick permissions",
                subtitle: "To find duplicate photos and contacts, we need your permission. Your data stays on your phone.",
                onBack: onBack
            )

            ScrollView {
                VStack(spacing: PCTheme.Spacing.lg) {
                    // Photos permission card
                    PermissionExplanationCard(
                        icon: "photo.fill",
                        iconColor: .pcPrimary,
                        title: "Photo Library",
                        explanation: "We look at your photos to find duplicates and screenshots. We never upload or share your photos."
                    )

                    // Contacts permission card
                    PermissionExplanationCard(
                        icon: "person.crop.circle.fill",
                        iconColor: .pcAccent,
                        title: "Contacts",
                        explanation: "We check your contacts for duplicates and help you merge them. Your contacts stay private."
                    )

                    // Privacy note
                    HStack(spacing: PCTheme.Spacing.sm) {
                        Image(systemName: "lock.fill")
                            .font(.footnote)
                            .foregroundStyle(Color.pcAccent)

                        Text("Everything happens on your device. Nothing is sent to our servers.")
                            .typography(.footnote, color: .pcTextSecondary)
                    }
                    .padding(.horizontal, PCTheme.Spacing.md)
                }
                .padding(.horizontal, PCTheme.Spacing.md)
                .padding(.top, PCTheme.Spacing.lg)
            }

            Spacer()

            // CTA
            VStack(spacing: PCTheme.Spacing.sm) {
                Button {
                    Task {
                        await requestPermissions()
                    }
                } label: {
                    if isRequesting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Continue")
                    }
                }
                .primaryCTAStyle()
                .disabled(isRequesting)
            }
            .padding(.horizontal, PCTheme.Spacing.lg)
            .padding(.bottom, PCTheme.Spacing.lg)
        }
    }

    private func requestPermissions() async {
        isRequesting = true
        defer { isRequesting = false }

        // Request photos first, then contacts
        await permissionManager.requestPermission(for: .photos)
        await permissionManager.requestPermission(for: .contacts)

        onContinue()
    }
}

// MARK: - Permission Explanation Card

private struct PermissionExplanationCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let explanation: String

    var body: some View {
        HStack(alignment: .top, spacing: PCTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(iconColor)
                .frame(width: 48, height: 48)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                Text(title)
                    .typography(.headline)

                Text(explanation)
                    .typography(.subheadline, color: .pcTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(PCTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PCTheme.Radius.lg)
                .fill(Color.pcSurface)
        )
        .accessibilityElement(children: .combine)
    }
}
