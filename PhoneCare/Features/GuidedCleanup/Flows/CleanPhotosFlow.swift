import SwiftUI

struct CleanPhotosFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = GuidedFlowCoordinator(
        flowType: .cleanPhotos,
        steps: [
            FlowStep(
                id: "intro",
                title: "Let's tidy up your photos",
                description: "We will help you find and remove photos you probably don't need.",
                icon: "photo.on.rectangle.angled",
                isSkippable: false
            ),
            FlowStep(
                id: "duplicates",
                title: "Remove duplicates",
                description: "These are photos that look exactly the same. We will keep the best quality one.",
                icon: "plus.square.on.square",
                isSkippable: true
            ),
            FlowStep(
                id: "blurry",
                title: "Clean up blurry photos",
                description: "Blurry photos take up space but are rarely useful. Let's review them.",
                icon: "camera.metering.unknown",
                isSkippable: true
            ),
            FlowStep(
                id: "screenshots",
                title: "Review screenshots",
                description: "Old screenshots can pile up. Let's see which ones you still need.",
                icon: "rectangle.portrait",
                isSkippable: true
            ),
        ]
    )

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.isComplete {
                    CompletionCelebrationView(
                        flowType: .cleanPhotos,
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
            .navigationTitle("Clean Photos")
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
        case "duplicates":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("How it works:")
                        .typography(.subheadline)
                    tipRow("We compare photos pixel by pixel")
                    tipRow("The highest quality version is kept")
                    tipRow("Deleted photos go to Recently Deleted for 30 days")
                }
            }
        case "blurry":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("What counts as blurry:")
                        .typography(.subheadline)
                    tipRow("Photos with significant motion blur")
                    tipRow("Out-of-focus images")
                    tipRow("You choose which ones to remove")
                }
            }
        case "screenshots":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("Tip:")
                        .typography(.subheadline)
                    tipRow("Screenshots older than 30 days are often no longer needed")
                    tipRow("You can review each one before deleting")
                }
            }
        default:
            EmptyView()
        }
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: PCTheme.Spacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.footnote)
                .foregroundStyle(Color.pcAccent)
                .voiceOverHidden()
            Text(text)
                .typography(.footnote, color: .pcTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
