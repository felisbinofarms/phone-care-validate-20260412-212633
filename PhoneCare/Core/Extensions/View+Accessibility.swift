import SwiftUI

// MARK: - VoiceOver Helpers

extension View {

    /// Add a VoiceOver label to this view, combining it into a single accessible element.
    ///
    ///     Image(systemName: "heart.fill")
    ///         .voiceOverLabel("Battery health: 92 percent, good condition")
    func voiceOverLabel(_ label: String) -> some View {
        self
            .accessibilityLabel(Text(label))
    }

    /// Add a VoiceOver hint that describes what happens when the user activates this element.
    func voiceOverHint(_ hint: String) -> some View {
        self
            .accessibilityHint(Text(hint))
    }

    /// Combine a label and a value for VoiceOver (e.g. "Battery: 92%").
    func voiceOverLabelValue(label: String, value: String) -> some View {
        self
            .accessibilityLabel(Text(label))
            .accessibilityValue(Text(value))
    }

    /// Mark this view as a semantic header for VoiceOver navigation.
    func voiceOverHeading() -> some View {
        self
            .accessibilityAddTraits(.isHeader)
    }

    /// Mark this view as a button for VoiceOver.
    func voiceOverButton(_ label: String? = nil) -> some View {
        let view = self.accessibilityAddTraits(.isButton)
        if let label {
            return AnyView(view.accessibilityLabel(Text(label)))
        }
        return AnyView(view)
    }

    /// Hide a purely decorative element from VoiceOver.
    func voiceOverHidden() -> some View {
        self
            .accessibilityHidden(true)
    }

    /// Group children into a single VoiceOver element with a custom label.
    func voiceOverGroup(_ label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
    }

    /// Announce a message to VoiceOver using `UIAccessibility.post`.
    func postVoiceOverAnnouncement(_ message: String) -> some View {
        self.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
    }
}

// MARK: - Dynamic Type Helpers

extension View {

    /// Limit the Dynamic Type size for this view (useful for constrained layouts).
    @ViewBuilder
    func limitDynamicType(to maxSize: DynamicTypeSize) -> some View {
        self.dynamicTypeSize(...maxSize)
    }

    /// Apply a minimum Dynamic Type size (useful for ensuring readability).
    @ViewBuilder
    func minimumDynamicType(_ minSize: DynamicTypeSize) -> some View {
        self.dynamicTypeSize(minSize...)
    }
}

// MARK: - Color-Independence Helpers

extension View {

    /// Overlay a shape icon on colored indicators so meaning doesn't depend solely on color.
    /// Use for status badges where color alone conveys information.
    func colorIndependentStatus(systemImage: String, color: Color) -> some View {
        HStack(spacing: PCTheme.Spacing.xs) {
            Image(systemName: systemImage)
                .foregroundStyle(color)
                .font(.footnote)
            self
        }
    }
}

// MARK: - Semantic Status View

/// A small helper that pairs a color with a shape symbol, ensuring
/// status information is never conveyed by color alone.
struct SemanticStatusIndicator: View {
    let status: SemanticStatus

    enum SemanticStatus {
        case good
        case warning
        case error
        case neutral

        var icon: String {
            switch self {
            case .good:    return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error:   return "xmark.circle.fill"
            case .neutral: return "minus.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .good:    return .pcAccent
            case .warning: return .pcWarning
            case .error:   return .pcError
            case .neutral: return .pcTextSecondary
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .good:    return "Good"
            case .warning: return "Warning"
            case .error:   return "Error"
            case .neutral: return "Neutral"
            }
        }
    }

    var body: some View {
        Image(systemName: status.icon)
            .foregroundStyle(status.color)
            .accessibilityLabel(status.accessibilityLabel)
    }
}
