import SwiftUI

struct TechSavvyView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                title: "How comfortable are you with technology?",
                subtitle: "We will adjust how we explain things based on your answer.",
                onBack: onBack
            )

            // Options
            ScrollView {
                VStack(spacing: PCTheme.Spacing.sm) {
                    ForEach(TechSavvyLevel.allCases) { level in
                        TechLevelOptionRow(
                            level: level,
                            isSelected: viewModel.techSavvyLevel == level
                        ) {
                            viewModel.techSavvyLevel = level
                        }
                    }
                }
                .padding(.horizontal, PCTheme.Spacing.md)
                .padding(.top, PCTheme.Spacing.md)
            }

            Spacer()

            // Bottom buttons
            VStack(spacing: PCTheme.Spacing.sm) {
                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                }
                .primaryCTAStyle()

                Button {
                    onSkip()
                } label: {
                    Text("Skip for now")
                }
                .textLinkStyle()
            }
            .padding(.horizontal, PCTheme.Spacing.lg)
            .padding(.bottom, PCTheme.Spacing.lg)
        }
    }
}

// MARK: - Tech Level Option Row

private struct TechLevelOptionRow: View {
    let level: TechSavvyLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PCTheme.Spacing.md) {
                Image(systemName: level.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.pcAccent : Color.pcTextSecondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                    Text(level.title)
                        .typography(.headline)

                    Text(level.description)
                        .typography(.subheadline, color: .pcTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.pcAccent)
                }
            }
            .padding(PCTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: PCTheme.Radius.md)
                    .fill(isSelected ? Color.pcMintTint : Color.pcSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PCTheme.Radius.md)
                    .strokeBorder(
                        isSelected ? Color.pcAccent : Color.pcBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(level.title). \(level.description)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
