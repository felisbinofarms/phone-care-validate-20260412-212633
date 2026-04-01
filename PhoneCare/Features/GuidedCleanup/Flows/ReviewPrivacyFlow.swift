import SwiftUI

struct ReviewPrivacyFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = GuidedFlowCoordinator(
        flowType: .reviewPrivacy,
        steps: [
            FlowStep(
                id: "intro",
                title: "Let's review your privacy",
                description: "We will go through your app permissions and help you understand what each one does.",
                icon: "lock.shield.fill",
                isSkippable: false
            ),
            FlowStep(
                id: "location",
                title: "Location access",
                description: "Location is one of the most important permissions to review. Let's see which apps can access it.",
                icon: "location.fill",
                isSkippable: true
            ),
            FlowStep(
                id: "camera_mic",
                title: "Camera and Microphone",
                description: "These permissions give apps access to see and hear. Let's make sure only the right apps have access.",
                icon: "camera.fill",
                isSkippable: true
            ),
            FlowStep(
                id: "tracking",
                title: "App Tracking",
                description: "App tracking lets apps follow your activity across other apps and websites. Most people prefer to keep this off.",
                icon: "hand.raised.fill",
                isSkippable: true
            ),
            FlowStep(
                id: "summary",
                title: "Privacy review complete",
                description: "You have reviewed your most important privacy settings.",
                icon: "checkmark.shield.fill",
                isSkippable: false
            ),
        ]
    )

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.isComplete {
                    CompletionCelebrationView(
                        flowType: .reviewPrivacy,
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
            .navigationTitle("Privacy Review")
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
        case "location":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("Good to know:")
                        .typography(.subheadline)
                    tipRow("'While Using' is usually enough for most apps")
                    tipRow("Very few apps truly need 'Always' access")
                    tipRow("You can change this anytime in Settings")
                }
            }
        case "camera_mic":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("Things to consider:")
                        .typography(.subheadline)
                    tipRow("Video call apps need both camera and microphone")
                    tipRow("Social media apps may ask but don't always need them")
                    tipRow("The indicator light shows when they're in use")
                }
            }
        case "tracking":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("About app tracking:")
                        .typography(.subheadline)
                    tipRow("Turning this off does not break any apps")
                    tipRow("It only stops apps from tracking you across other apps")
                    tipRow("You can turn it off for all apps at once in Settings")
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
