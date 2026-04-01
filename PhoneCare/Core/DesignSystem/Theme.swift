import SwiftUI

// MARK: - PhoneCare Design Tokens

/// Central design-token namespace for the PhoneCare design system.
/// Access tokens via `PCTheme.Colors`, `PCTheme.Spacing`, etc.
enum PCTheme {

    // MARK: - Colors

    enum Colors {
        static let primary      = Color(light: 0x0A3D62, dark: 0x5DADE2)
        static let accent       = Color(light: 0x1A8A6E, dark: 0x58D68D)
        static let background   = Color(light: 0xF8F9FA, dark: 0x1C1C1E)
        static let surface      = Color(light: 0xFFFFFF, dark: 0x2C2C2E)
        static let textPrimary  = Color(light: 0x2C3E50, dark: 0xF2F2F7)
        static let textSecondary = Color(light: 0x95A5A6, dark: 0x8E8E93)
        static let warning      = Color(light: 0xF39C12, dark: 0xF5B041)
        static let error        = Color(light: 0xE74C3C, dark: 0xEC7063)
        static let border       = Color(light: 0xE5E7EB, dark: 0x38383A)
        static let mintTint     = Color(light: 0xE8F8F5, dark: 0x1A3D35)
        static let skyLight     = Color(light: 0xD4E6F1, dark: 0x1A2E3D)
    }

    // MARK: - Spacing (8pt grid)

    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radii

    enum Radius {
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows

    enum Shadow {
        /// Card shadow: 0 2pt 8pt rgba(0,0,0,0.08)
        static let cardColor   = Color.black.opacity(0.08)
        static let cardRadius: CGFloat = 8
        static let cardX: CGFloat = 0
        static let cardY: CGFloat = 2

        /// Modal shadow: 0 8pt 24pt rgba(0,0,0,0.12)
        static let modalColor  = Color.black.opacity(0.12)
        static let modalRadius: CGFloat = 24
        static let modalX: CGFloat = 0
        static let modalY: CGFloat = 8
    }

    // MARK: - Touch Targets

    enum HitArea {
        /// Apple HIG minimum (44pt)
        static let minimum: CGFloat = 44
        /// PhoneCare standard for primary CTAs
        static let primaryCTA: CGFloat = 50
        /// Minimum list-row height
        static let listRow: CGFloat = 56
        /// Actionable list-row height
        static let actionableRow: CGFloat = 64
    }
}

// MARK: - Color Hex Initializer

extension Color {
    /// Create an adaptive Color from light and dark hex values (0xRRGGBB).
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8)  & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
