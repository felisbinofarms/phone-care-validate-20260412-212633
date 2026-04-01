import SwiftUI

// MARK: - Generic Card Container

/// A reusable card surface with PhoneCare styling (16pt radius, card shadow, surface background).
struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
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
    }
}

// MARK: - Dashboard Card

/// A structured card for dashboard-style layouts with icon, title, status, description, and action.
///
///     DashboardCardView(
///         icon: "heart.fill",
///         iconColor: .pcAccent,
///         title: "Battery Health",
///         status: .good("92%"),
///         description: "Your battery is in excellent condition."
///     ) {
///         Button("Details") { }
///     }
struct DashboardCardView<Action: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let status: CardStatus
    let description: String
    let action: Action?

    /// Create a dashboard card without a trailing action.
    init(
        icon: String,
        iconColor: Color = .pcAccent,
        title: String,
        status: CardStatus,
        description: String
    ) where Action == EmptyView {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.status = status
        self.description = description
        self.action = nil
    }

    /// Create a dashboard card with a trailing action.
    init(
        icon: String,
        iconColor: Color = .pcAccent,
        title: String,
        status: CardStatus,
        description: String,
        @ViewBuilder action: () -> Action
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.status = status
        self.description = description
        self.action = action()
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                // Top row: Icon + Title | Status
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(iconColor)

                    Text(title)
                        .typography(.headline)

                    Spacer()

                    statusBadge
                }

                // Description
                Text(description)
                    .typography(.subheadline, color: .pcTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Optional action
                if let action {
                    Divider()
                        .foregroundStyle(Color.pcBorder)

                    action
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .good(let label):
            StatusLabel(text: label, color: .pcAccent)
        case .warning(let label):
            StatusLabel(text: label, color: .pcWarning)
        case .error(let label):
            StatusLabel(text: label, color: .pcError)
        case .neutral(let label):
            StatusLabel(text: label, color: .pcTextSecondary)
        }
    }
}

// MARK: - Card Status

enum CardStatus {
    case good(String)
    case warning(String)
    case error(String)
    case neutral(String)
}

// MARK: - Status Label (internal)

private struct StatusLabel: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, PCTheme.Spacing.sm)
            .padding(.vertical, PCTheme.Spacing.xs)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }
}

// MARK: - View Modifier

extension View {
    /// Wrap any view in a PhoneCare card surface.
    func cardStyle() -> some View {
        padding(PCTheme.Spacing.md)
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
    }
}
