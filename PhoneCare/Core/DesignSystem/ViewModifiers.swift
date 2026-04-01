import SwiftUI

// MARK: - Accessible Tap Target

/// Ensures the tappable area meets or exceeds the given minimum size (default 44pt per Apple HIG).
struct AccessibleTapTargetModifier: ViewModifier {
    let minWidth: CGFloat
    let minHeight: CGFloat

    init(minWidth: CGFloat = PCTheme.HitArea.minimum, minHeight: CGFloat = PCTheme.HitArea.minimum) {
        self.minWidth = minWidth
        self.minHeight = minHeight
    }

    func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth, minHeight: minHeight)
            .contentShape(Rectangle())
    }
}

extension View {
    /// Ensure this view meets the minimum 44pt tap target (Apple HIG).
    func accessibleTapTarget() -> some View {
        modifier(AccessibleTapTargetModifier())
    }

    /// Ensure this view meets a custom minimum tap target size.
    func accessibleTapTarget(minWidth: CGFloat = PCTheme.HitArea.minimum,
                             minHeight: CGFloat = PCTheme.HitArea.minimum) -> some View {
        modifier(AccessibleTapTargetModifier(minWidth: minWidth, minHeight: minHeight))
    }
}

// MARK: - Reduce Motion

/// Replaces the given animation with a crossfade when Reduce Motion is enabled.
struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let animation: Animation
    let reducedAnimation: Animation

    init(animation: Animation = .default, reducedAnimation: Animation = .easeInOut(duration: 0.3)) {
        self.animation = animation
        self.reducedAnimation = reducedAnimation
    }

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? reducedAnimation : animation, value: UUID())
    }
}

/// Conditionally apply an animation respecting Reduce Motion.
struct ReduceMotionTransitionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let standardTransition: AnyTransition
    let reducedTransition: AnyTransition

    init(standard: AnyTransition = .scale.combined(with: .opacity),
         reduced: AnyTransition = .opacity) {
        self.standardTransition = standard
        self.reducedTransition = reduced
    }

    func body(content: Content) -> some View {
        content
            .transition(reduceMotion ? reducedTransition : standardTransition)
    }
}

extension View {
    /// Apply an animation that gracefully degrades when Reduce Motion is on.
    func motionSafe(_ animation: Animation = .default,
                    reduced: Animation = .easeInOut(duration: 0.3)) -> some View {
        modifier(ReduceMotionModifier(animation: animation, reducedAnimation: reduced))
    }

    /// Apply a transition that falls back to a crossfade under Reduce Motion.
    func motionSafeTransition(standard: AnyTransition = .scale.combined(with: .opacity),
                              reduced: AnyTransition = .opacity) -> some View {
        modifier(ReduceMotionTransitionModifier(standard: standard, reduced: reduced))
    }
}

// MARK: - Health Score Color

/// Maps a health score (0-100) to a semantic color.
///
/// **Design rule**: scores 51-100 are green (accent), 0-50 are amber (warning).
/// Red is **never** used for health scores to avoid alarming users.
struct HealthScoreColorModifier: ViewModifier {
    let score: Int

    func body(content: Content) -> some View {
        content
            .foregroundStyle(healthColor)
    }

    private var healthColor: Color {
        score >= 51 ? .pcAccent : .pcWarning
    }
}

extension View {
    /// Colour a view by health score: green >= 51, amber <= 50. Never red.
    func healthScoreColor(_ score: Int) -> some View {
        modifier(HealthScoreColorModifier(score: score))
    }
}

/// Utility function to get the health color for a given score.
func healthColor(for score: Int) -> Color {
    score >= 51 ? .pcAccent : .pcWarning
}

// MARK: - Card Shadow Modifier

/// Applies the standard PhoneCare card shadow.
struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(
                color: PCTheme.Shadow.cardColor,
                radius: PCTheme.Shadow.cardRadius,
                x: PCTheme.Shadow.cardX,
                y: PCTheme.Shadow.cardY
            )
    }
}

/// Applies the PhoneCare modal shadow.
struct ModalShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(
                color: PCTheme.Shadow.modalColor,
                radius: PCTheme.Shadow.modalRadius,
                x: PCTheme.Shadow.modalX,
                y: PCTheme.Shadow.modalY
            )
    }
}

extension View {
    /// Apply the PhoneCare card shadow.
    func pcCardShadow() -> some View {
        modifier(CardShadowModifier())
    }

    /// Apply the PhoneCare modal shadow.
    func pcModalShadow() -> some View {
        modifier(ModalShadowModifier())
    }
}
