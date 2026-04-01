import SwiftUI

struct UndoToastView: View {
    let itemCount: Int
    let countdownDuration: TimeInterval
    var onUndo: (() -> Void)?
    var onDismiss: (() -> Void)?

    @State private var remainingSeconds: Int
    @State private var timerTask: Task<Void, Never>?

    init(itemCount: Int, countdownDuration: TimeInterval = 30, onUndo: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.itemCount = itemCount
        self.countdownDuration = countdownDuration
        self.onUndo = onUndo
        self.onDismiss = onDismiss
        _remainingSeconds = State(initialValue: Int(countdownDuration))
    }

    var body: some View {
        HStack(spacing: PCTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                Text("\(itemCount) photos deleted")
                    .typography(.subheadline)
                    .foregroundStyle(.white)

                Text("\(remainingSeconds)s to undo")
                    .typography(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Button {
                timerTask?.cancel()
                onUndo?()
            } label: {
                Text("Undo")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.pcAccent)
                    .padding(.horizontal, PCTheme.Spacing.md)
                    .padding(.vertical, PCTheme.Spacing.sm)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
            }
            .accessibleTapTarget()
            .accessibilityHint("Undo the deletion")
        }
        .padding(PCTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: PCTheme.Radius.md)
                .fill(Color.pcTextPrimary)
                .pcModalShadow()
        )
        .padding(.horizontal, PCTheme.Spacing.md)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear { startCountdown() }
        .onDisappear { timerTask?.cancel() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(itemCount) photos deleted. \(remainingSeconds) seconds to undo.")
    }

    private func startCountdown() {
        timerTask?.cancel()
        remainingSeconds = Int(countdownDuration)
        timerTask = Task { @MainActor in
            while remainingSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                remainingSeconds -= 1
            }
            if !Task.isCancelled {
                onDismiss?()
            }
        }
    }
}
