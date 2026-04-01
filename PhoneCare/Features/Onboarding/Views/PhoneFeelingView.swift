import SwiftUI

struct PhoneFeelingView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                title: "How does your phone feel?",
                subtitle: "This helps us understand what to focus on.",
                onBack: onBack
            )

            // Options
            ScrollView {
                VStack(spacing: PCTheme.Spacing.sm) {
                    ForEach(PhoneFeeling.allCases) { feeling in
                        FeelingOptionRow(
                            feeling: feeling,
                            isSelected: viewModel.phoneFeeling == feeling
                        ) {
                            viewModel.phoneFeeling = feeling
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
                .disabled(viewModel.phoneFeeling == nil)

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

// MARK: - Feeling Option Row

private struct FeelingOptionRow: View {
    let feeling: PhoneFeeling
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PCTheme.Spacing.md) {
                Image(systemName: feeling.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.pcAccent : Color.pcTextSecondary)
                    .frame(width: 32)

                Text(feeling.title)
                    .typography(.body)
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
        .accessibilityLabel(feeling.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
