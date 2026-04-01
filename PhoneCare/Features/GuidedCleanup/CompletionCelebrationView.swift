import SwiftUI

struct CompletionCelebrationView: View {
    let flowType: GuidedFlowType
    let itemsCleaned: Int
    let bytesFreed: Int64
    var onDone: (() -> Void)?

    @State private var showContent = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: PCTheme.Spacing.xl) {
            Spacer()

            // Celebration icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.pcAccent)
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1.0 : 0.0)
                .voiceOverHidden()

            // Title
            Text("All done!")
                .typography(.title1)
                .opacity(showContent ? 1.0 : 0.0)

            // Summary
            VStack(spacing: PCTheme.Spacing.md) {
                Text(summaryMessage)
                    .typography(.subheadline, color: .pcTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                // Stats
                if itemsCleaned > 0 || bytesFreed > 0 {
                    HStack(spacing: PCTheme.Spacing.xl) {
                        if itemsCleaned > 0 {
                            statBubble(value: "\(itemsCleaned)", label: "Items cleaned")
                        }
                        if bytesFreed > 0 {
                            statBubble(value: formatBytes(bytesFreed), label: "Space freed")
                        }
                    }
                }
            }
            .opacity(showContent ? 1.0 : 0.0)

            Spacer()

            // Done button
            Button("Done") {
                onDone?()
            }
            .primaryCTAStyle()
            .padding(.horizontal, PCTheme.Spacing.md)
            .padding(.bottom, PCTheme.Spacing.lg)
            .opacity(showContent ? 1.0 : 0.0)
        }
        .padding(.horizontal, PCTheme.Spacing.md)
        .background(Color.pcBackground)
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(duration: 0.8, bounce: 0.3)) {
                showContent = true
            }
        }
        .postVoiceOverAnnouncement("Cleanup complete. \(summaryMessage)")
    }

    private var summaryMessage: String {
        switch flowType {
        case .freeUpSpace:
            return "You have freed up space and your phone will run smoother."
        case .cleanPhotos:
            return "Your photo library is tidier now."
        case .cleanContacts:
            return "Your contacts are cleaned up and organized."
        case .reviewPrivacy:
            return "Your privacy settings have been reviewed."
        }
    }

    private func statBubble(value: String, label: String) -> some View {
        VStack(spacing: PCTheme.Spacing.xs) {
            Text(value)
                .typography(.title2, color: .pcAccent)

            Text(label)
                .typography(.caption, color: .pcTextSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
