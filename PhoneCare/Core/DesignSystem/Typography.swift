import SwiftUI

// MARK: - Type Scale

/// Semantic type-scale tokens that map to SF Pro + Dynamic Type.
enum PCTypography {
    case largeTitle   // 34pt Bold
    case title1       // 28pt Bold
    case title2       // 22pt Bold
    case title3       // 20pt Semibold
    case headline     // 17pt Semibold
    case body         // 17pt Regular
    case callout      // 16pt Regular
    case subheadline  // 15pt Regular
    case footnote     // 13pt Regular
    case caption      // 12pt Regular

    /// The matching `Font.TextStyle` for Dynamic Type scaling.
    var textStyle: Font.TextStyle {
        switch self {
        case .largeTitle:  return .largeTitle
        case .title1:      return .title
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .body:        return .body
        case .callout:     return .callout
        case .subheadline: return .subheadline
        case .footnote:    return .footnote
        case .caption:     return .caption
        }
    }

    /// The font weight defined in the style guide.
    var weight: Font.Weight {
        switch self {
        case .largeTitle, .title1, .title2:
            return .bold
        case .title3, .headline:
            return .semibold
        case .body, .callout, .subheadline, .footnote, .caption:
            return .regular
        }
    }

    /// Fully resolved `Font` value with the correct weight and Dynamic Type.
    var font: Font {
        Font.system(textStyle).weight(weight)
    }

    /// Default text color for this level.
    var color: Color {
        switch self {
        case .footnote, .caption:
            return .pcTextSecondary
        default:
            return .pcTextPrimary
        }
    }
}

// MARK: - View Modifier

/// Applies a `PCTypography` token as font + foreground color.
struct PCTypographyModifier: ViewModifier {
    let style: PCTypography
    let customColor: Color?

    init(_ style: PCTypography, color: Color? = nil) {
        self.style = style
        self.customColor = color
    }

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .foregroundStyle(customColor ?? style.color)
    }
}

// MARK: - View Extension

extension View {
    /// Apply a PhoneCare typography token.
    ///
    ///     Text("Hello")
    ///         .typography(.title1)
    ///
    ///     Text("Custom color")
    ///         .typography(.body, color: .pcAccent)
    func typography(_ style: PCTypography, color: Color? = nil) -> some View {
        modifier(PCTypographyModifier(style, color: color))
    }
}
