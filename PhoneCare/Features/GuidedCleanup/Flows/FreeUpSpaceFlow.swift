import SwiftUI

struct FreeUpSpaceFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = GuidedFlowCoordinator(
        flowType: .freeUpSpace,
        steps: [
            FlowStep(
                id: "overview",
                title: "Let's free up some space",
                description: "We will walk you through a few easy steps to help your phone have more room.",
                icon: "internaldrive.fill",
                isSkippable: false
            ),
            FlowStep(
                id: "photos",
                title: "Clean up photos",
                description: "Duplicate and blurry photos often take up the most space. Let's find them.",
                icon: "photo.on.rectangle",
                isSkippable: true
            ),
            FlowStep(
                id: "videos",
                title: "Review large videos",
                description: "Videos can be very large. Let's check if any can be removed or compressed.",
                icon: "video.fill",
                isSkippable: true
            ),
            FlowStep(
                id: "apps",
                title: "Check unused apps",
                description: "Apps you haven't used in a while can be offloaded to save space while keeping your data.",
                icon: "square.grid.2x2.fill",
                isSkippable: true
            ),
            FlowStep(
                id: "summary",
                title: "Review your cleanup",
                description: "Here is a summary of what we found and cleaned up.",
                icon: "checkmark.circle.fill",
                isSkippable: false
            ),
        ]
    )

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.isComplete {
                    CompletionCelebrationView(
                        flowType: .freeUpSpace,
                        itemsCleaned: coordinator.itemsCleaned,
                        bytesFreed: coordinator.bytesFreed,
                        onDone: { dismiss() }
                    )
                } else if let step = coordinator.currentStep {
                    FlowStepView(
                        step: step,
                        stepNumber: coordinator.currentStepNumber,
                        totalSteps: coordinator.totalSteps,
                        canGoBack: coordinator.canGoBack,
                        onConfirm: { coordinator.next() },
                        onSkip: { coordinator.skip() },
                        onBack: { coordinator.back() }
                    ) {
                        stepContent(for: step)
                    }
                }
            }
            .navigationTitle("Free Up Space")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibleTapTarget()
                }
            }
        }
    }

    @ViewBuilder
    private func stepContent(for step: FlowStep) -> some View {
        switch step.id {
        case "photos":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("What we will do:")
                        .typography(.subheadline)
                    bulletPoint("Find duplicate photos")
                    bulletPoint("Identify blurry images")
                    bulletPoint("Review old screenshots")
                }
            }
        case "videos":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("What we will do:")
                        .typography(.subheadline)
                    bulletPoint("Find videos over 100 MB")
                    bulletPoint("Show which ones you might not need")
                }
            }
        case "apps":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("How offloading works:")
                        .typography(.subheadline)
                    bulletPoint("The app is removed but your data stays")
                    bulletPoint("Reinstall anytime from the App Store")
                    bulletPoint("Your settings and accounts are saved")
                }
            }
        default:
            EmptyView()
        }
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: PCTheme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(Color.pcAccent)
                .voiceOverHidden()
            Text(text)
                .typography(.footnote, color: .pcTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
