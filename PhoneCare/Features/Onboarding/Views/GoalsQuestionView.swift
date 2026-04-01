import SwiftUI

struct GoalsQuestionView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                title: "What matters most?",
                subtitle: "Pick as many as you like. This helps us show you what is most important first.",
                onBack: onBack
            )

            // Goal options
            ScrollView {
                VStack(spacing: PCTheme.Spacing.sm) {
                    ForEach(OnboardingGoal.allCases) { goal in
                        GoalOptionRow(
                            goal: goal,
                            isSelected: viewModel.selectedGoals.contains(goal)
                        ) {
                            viewModel.toggleGoal(goal)
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
                .disabled(!viewModel.hasSelectedGoals)

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

// MARK: - Goal Option Row

private struct GoalOptionRow: View {
    let goal: OnboardingGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PCTheme.Spacing.md) {
                Image(systemName: goal.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.pcAccent : Color.pcTextSecondary)
                    .frame(width: 28)

                Text(goal.title)
                    .typography(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.pcAccent : Color.pcBorder)
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
        .accessibilityLabel(goal.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint("Double tap to \(isSelected ? "deselect" : "select")")
    }
}
