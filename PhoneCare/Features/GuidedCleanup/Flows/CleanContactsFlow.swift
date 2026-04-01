import SwiftUI

struct CleanContactsFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = GuidedFlowCoordinator(
        flowType: .cleanContacts,
        steps: [
            FlowStep(
                id: "intro",
                title: "Let's clean up your contacts",
                description: "We will find duplicate contacts and help you merge them.",
                icon: "person.2.fill",
                isSkippable: false
            ),
            FlowStep(
                id: "scan",
                title: "Scanning contacts",
                description: "Looking through your address book for duplicates and similar entries.",
                icon: "magnifyingglass",
                isSkippable: false
            ),
            FlowStep(
                id: "review",
                title: "Review duplicates",
                description: "For each group, choose which information to keep. We will combine everything into one contact.",
                icon: "person.crop.circle.badge.checkmark",
                isSkippable: true
            ),
            FlowStep(
                id: "backup",
                title: "Safe to merge",
                description: "Before merging, we save a backup. You can undo any merge within 30 days.",
                icon: "shield.checkered",
                isSkippable: false
            ),
        ]
    )

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.isComplete {
                    CompletionCelebrationView(
                        flowType: .cleanContacts,
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
            .navigationTitle("Clean Contacts")
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
        case "scan":
            VStack(spacing: PCTheme.Spacing.md) {
                ProgressView()
                    .controlSize(.large)
                Text("This usually takes just a few seconds.")
                    .typography(.footnote, color: .pcTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PCTheme.Spacing.lg)
        case "review":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("How merging works:")
                        .typography(.subheadline)
                    tipRow("We show you duplicates side by side")
                    tipRow("Pick which name, phone, and email to keep")
                    tipRow("Everything is combined into one clean contact")
                }
            }
        case "backup":
            CardView {
                VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                    Text("Your contacts are safe:")
                        .typography(.subheadline)
                    tipRow("A backup is created before any changes")
                    tipRow("Undo any merge within 30 days")
                    tipRow("Original contacts are never permanently lost")
                }
            }
        default:
            EmptyView()
        }
    }

    private func tipRow(_ text: String) -> some View {
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
