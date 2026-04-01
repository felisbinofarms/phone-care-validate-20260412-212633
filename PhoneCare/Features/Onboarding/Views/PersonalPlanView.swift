import SwiftUI

struct PersonalPlanView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            OnboardingHeaderView(
                title: "Here is your personal plan",
                subtitle: "Based on what we found, here are your top actions.",
                onBack: onBack
            )

            // Plan items
            ScrollView {
                VStack(spacing: PCTheme.Spacing.sm) {
                    ForEach(Array(viewModel.personalPlan.enumerated()), id: \.element.id) { index, item in
                        PlanItemRow(item: item, index: index + 1)
                    }
                }
                .padding(.horizontal, PCTheme.Spacing.md)
                .padding(.top, PCTheme.Spacing.md)
                .padding(.bottom, PCTheme.Spacing.lg)
            }

            Spacer()

            // CTA
            Button {
                onContinue()
            } label: {
                Text("Continue")
            }
            .primaryCTAStyle()
            .padding(.horizontal, PCTheme.Spacing.lg)
            .padding(.bottom, PCTheme.Spacing.lg)
        }
    }
}

// MARK: - Plan Item Row

private struct PlanItemRow: View {
    let item: OnboardingViewModel.PlanItem
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: PCTheme.Spacing.md) {
            // Number badge
            Text("\(index)")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.pcAccent))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                HStack(spacing: PCTheme.Spacing.sm) {
                    Image(systemName: item.icon)
                        .font(.body)
                        .foregroundStyle(Color.pcAccent)
                        .accessibilityHidden(true)

                    Text(item.title)
                        .typography(.headline)
                }

                Text(item.detail)
                    .typography(.subheadline, color: .pcTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(PCTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PCTheme.Radius.lg)
                .fill(Color.pcSurface)
                .shadow(
                    color: PCTheme.Shadow.cardColor,
                    radius: PCTheme.Shadow.cardRadius,
                    x: PCTheme.Shadow.cardX,
                    y: PCTheme.Shadow.cardY
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(index): \(item.title). \(item.detail)")
    }
}
