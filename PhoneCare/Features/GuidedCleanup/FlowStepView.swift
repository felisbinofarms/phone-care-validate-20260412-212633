import SwiftUI

struct FlowStepView<Content: View>: View {
    let step: FlowStep
    let stepNumber: Int
    let totalSteps: Int
    let canGoBack: Bool
    let content: Content
    var onConfirm: (() -> Void)?
    var onSkip: (() -> Void)?
    var onBack: (() -> Void)?

    init(
        step: FlowStep,
        stepNumber: Int,
        totalSteps: Int,
        canGoBack: Bool,
        onConfirm: (() -> Void)? = nil,
        onSkip: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.step = step
        self.stepNumber = stepNumber
        self.totalSteps = totalSteps
        self.canGoBack = canGoBack
        self.onConfirm = onConfirm
        self.onSkip = onSkip
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress dots
            progressDots
                .padding(.top, PCTheme.Spacing.md)
                .padding(.bottom, PCTheme.Spacing.lg)

            ScrollView {
                VStack(spacing: PCTheme.Spacing.lg) {
                    // Step icon
                    Image(systemName: step.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(Color.pcAccent)
                        .voiceOverHidden()

                    // Title and description
                    VStack(spacing: PCTheme.Spacing.sm) {
                        Text(step.title)
                            .typography(.title3)
                            .multilineTextAlignment(.center)
                            .voiceOverHeading()

                        Text(step.description)
                            .typography(.subheadline, color: .pcTextSecondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Custom content
                    content
                }
                .padding(.horizontal, PCTheme.Spacing.md)
            }

            // Bottom buttons
            VStack(spacing: PCTheme.Spacing.sm) {
                Button("Continue") {
                    onConfirm?()
                }
                .primaryCTAStyle()

                if step.isSkippable {
                    Button("Skip") {
                        onSkip?()
                    }
                    .textLinkStyle()
                    .accessibleTapTarget()
                }

                if canGoBack {
                    Button("Back") {
                        onBack?()
                    }
                    .textLinkStyle()
                    .accessibleTapTarget()
                }
            }
            .padding(.horizontal, PCTheme.Spacing.md)
            .padding(.bottom, PCTheme.Spacing.lg)
        }
        .background(Color.pcBackground)
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: PCTheme.Spacing.sm) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(index < stepNumber ? Color.pcAccent : Color.pcBorder)
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(stepNumber) of \(totalSteps)")
    }
}
