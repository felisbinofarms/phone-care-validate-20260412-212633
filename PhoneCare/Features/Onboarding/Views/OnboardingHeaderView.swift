import SwiftUI

/// Shared header used across onboarding question screens.
struct OnboardingHeaderView: View {
    let title: String
    let subtitle: String
    let onBack: (() -> Void)?

    init(title: String, subtitle: String, onBack: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.onBack = onBack
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
            // Back button
            if let onBack {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: PCTheme.Spacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.medium))
                        Text("Back")
                            .font(.body)
                    }
                    .foregroundStyle(Color.pcPrimary)
                }
                .accessibleTapTarget()
                .accessibilityLabel("Go back")
            }

            // Title
            Text(title)
                .typography(.title1)
                .fixedSize(horizontal: false, vertical: true)
                .voiceOverHeading()

            // Subtitle
            Text(subtitle)
                .typography(.body, color: .pcTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PCTheme.Spacing.md)
        .padding(.top, PCTheme.Spacing.md)
    }
}
