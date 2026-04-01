import SwiftUI

// MARK: - Primary CTA

/// Accent-green filled button -- 50pt, 12pt radius.
struct PrimaryCTAButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: PCTheme.HitArea.primaryCTA)
            .background(
                RoundedRectangle(cornerRadius: PCTheme.Radius.md)
                    .fill(isEnabled ? Color.pcAccent : Color.pcAccent.opacity(0.4))
            )
            .opacity(pressedOpacity(configuration.isPressed))
            .scaleEffect(pressedScale(configuration.isPressed))
            .animation(pressAnimation, value: configuration.isPressed)
    }

    private func pressedOpacity(_ pressed: Bool) -> Double {
        pressed ? 0.85 : 1.0
    }

    private func pressedScale(_ pressed: Bool) -> CGFloat {
        if reduceMotion { return 1.0 }
        return pressed ? 0.97 : 1.0
    }

    private var pressAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.15)
    }
}

// MARK: - Secondary

/// Mint-tint background, accent-green text -- 50pt, 12pt radius.
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(isEnabled ? Color.pcAccent : Color.pcAccent.opacity(0.4))
            .frame(maxWidth: .infinity, minHeight: PCTheme.HitArea.primaryCTA)
            .background(
                RoundedRectangle(cornerRadius: PCTheme.Radius.md)
                    .fill(Color.pcMintTint)
            )
            .opacity(pressedOpacity(configuration.isPressed))
            .scaleEffect(pressedScale(configuration.isPressed))
            .animation(pressAnimation, value: configuration.isPressed)
    }

    private func pressedOpacity(_ pressed: Bool) -> Double {
        pressed ? 0.7 : 1.0
    }

    private func pressedScale(_ pressed: Bool) -> CGFloat {
        if reduceMotion { return 1.0 }
        return pressed ? 0.97 : 1.0
    }

    private var pressAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.15)
    }
}

// MARK: - Destructive

/// White background, red text -- 50pt, 12pt radius.
struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(isEnabled ? Color.pcError : Color.pcError.opacity(0.4))
            .frame(maxWidth: .infinity, minHeight: PCTheme.HitArea.primaryCTA)
            .background(
                RoundedRectangle(cornerRadius: PCTheme.Radius.md)
                    .fill(Color.pcSurface)
                    .shadow(
                        color: PCTheme.Shadow.cardColor,
                        radius: PCTheme.Shadow.cardRadius / 2,
                        x: PCTheme.Shadow.cardX,
                        y: PCTheme.Shadow.cardY
                    )
            )
            .opacity(pressedOpacity(configuration.isPressed))
            .scaleEffect(pressedScale(configuration.isPressed))
            .animation(pressAnimation, value: configuration.isPressed)
    }

    private func pressedOpacity(_ pressed: Bool) -> Double {
        pressed ? 0.7 : 1.0
    }

    private func pressedScale(_ pressed: Bool) -> CGFloat {
        if reduceMotion { return 1.0 }
        return pressed ? 0.97 : 1.0
    }

    private var pressAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.15)
    }
}

// MARK: - Text Link

/// Transparent background, primary-blue text -- 44pt min height.
struct TextLinkButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(isEnabled ? Color.pcPrimary : Color.pcPrimary.opacity(0.4))
            .frame(minHeight: PCTheme.HitArea.minimum)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extension Helpers

extension View {
    func primaryCTAStyle() -> some View {
        buttonStyle(PrimaryCTAButtonStyle())
    }

    func secondaryStyle() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }

    func destructiveStyle() -> some View {
        buttonStyle(DestructiveButtonStyle())
    }

    func textLinkStyle() -> some View {
        buttonStyle(TextLinkButtonStyle())
    }
}
