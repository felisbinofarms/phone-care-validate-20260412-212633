import SwiftUI

// MARK: - Convenience Color Accessors

extension Color {

    /// Brand blue -- nav bars, headers.
    static let pcPrimary = PCTheme.Colors.primary

    /// CTAs, success states, health-positive.
    static let pcAccent = PCTheme.Colors.accent

    /// Screen background.
    static let pcBackground = PCTheme.Colors.background

    /// Card / elevated surface.
    static let pcSurface = PCTheme.Colors.surface

    /// Primary body text.
    static let pcTextPrimary = PCTheme.Colors.textPrimary

    /// Metadata / secondary text.
    static let pcTextSecondary = PCTheme.Colors.textSecondary

    /// Genuine warnings only.
    static let pcWarning = PCTheme.Colors.warning

    /// True errors only.
    static let pcError = PCTheme.Colors.error

    /// Dividers and borders.
    static let pcBorder = PCTheme.Colors.border

    /// Card backgrounds and highlights.
    static let pcMintTint = PCTheme.Colors.mintTint

    /// Secondary backgrounds.
    static let pcSkyLight = PCTheme.Colors.skyLight
}

// MARK: - ShapeStyle Convenience

extension ShapeStyle where Self == Color {
    static var pcPrimary: Color { .pcPrimary }
    static var pcAccent: Color { .pcAccent }
    static var pcBackground: Color { .pcBackground }
    static var pcSurface: Color { .pcSurface }
    static var pcTextPrimary: Color { .pcTextPrimary }
    static var pcTextSecondary: Color { .pcTextSecondary }
    static var pcWarning: Color { .pcWarning }
    static var pcError: Color { .pcError }
    static var pcBorder: Color { .pcBorder }
    static var pcMintTint: Color { .pcMintTint }
    static var pcSkyLight: Color { .pcSkyLight }
}
