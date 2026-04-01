import SwiftUI

struct QuickWinsSection: View {
    let quickWins: [QuickWin]
    let isPremium: Bool
    var onTapWin: ((QuickWin) -> Void)?

    var body: some View {
        if !quickWins.isEmpty {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                Text("Quick Wins")
                    .typography(.headline)
                    .voiceOverHeading()

                ForEach(quickWins) { win in
                    Button {
                        onTapWin?(win)
                    } label: {
                        quickWinRow(win)
                    }
                    .buttonStyle(.plain)
                    .accessibleTapTarget()
                }
            }
        }
    }

    @ViewBuilder
    private func quickWinRow(_ win: QuickWin) -> some View {
        CardView {
            HStack(spacing: PCTheme.Spacing.md) {
                Image(systemName: win.icon)
                    .font(.title3)
                    .foregroundStyle(Color.pcAccent)
                    .frame(width: 32, height: 32)
                    .voiceOverHidden()

                VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                    Text(win.title)
                        .typography(.subheadline)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(win.benefit)
                        .typography(.footnote, color: .pcAccent)
                }

                Spacer()

                if isPremium {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.pcTextSecondary)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.footnote)
                        .foregroundStyle(Color.pcTextSecondary)
                        .accessibilityLabel("Premium feature")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(isPremium ? "Tap to take action" : "Premium feature. Tap to learn more.")
    }
}
