import SwiftUI

struct StorageBarChart: View {
    let totalBytes: Int64
    let categories: [StorageCategory]
    let freeBytes: Int64
    var onTapCategory: ((StorageCategory) -> Void)?

    @State private var selectedCategory: String?

    private var barHeight: CGFloat { 28 }

    var body: some View {
        VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
            // Segmented bar
            GeometryReader { geometry in
                HStack(spacing: 1) {
                    ForEach(categories) { category in
                        let width = barWidth(for: category, in: geometry.size.width)
                        if width > 2 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(category.color)
                                .frame(width: width, height: barHeight)
                                .opacity(selectedCategory == nil || selectedCategory == category.id ? 1.0 : 0.4)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if selectedCategory == category.id {
                                            selectedCategory = nil
                                        } else {
                                            selectedCategory = category.id
                                        }
                                    }
                                    onTapCategory?(category)
                                }
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("\(category.name): \(formatBytes(category.sizeInBytes))")
                                .accessibilityAddTraits(.isButton)
                        }
                    }

                    // Free space
                    let freeWidth = freeBarWidth(in: geometry.size.width)
                    if freeWidth > 2 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.pcBorder.opacity(0.3))
                            .frame(width: freeWidth, height: barHeight)
                            .accessibilityLabel("Free space: \(formatBytes(freeBytes))")
                    }
                }
            }
            .frame(height: barHeight)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            // Legend
            legendView
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilitySummary)
    }

    // MARK: - Legend

    private var legendView: some View {
        FlowLayout(spacing: PCTheme.Spacing.sm) {
            ForEach(categories) { category in
                HStack(spacing: PCTheme.Spacing.xs) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                        .voiceOverHidden()

                    Text(category.name)
                        .typography(.caption)

                    Text(formatBytes(category.sizeInBytes))
                        .typography(.caption, color: .pcTextSecondary)
                }
                .opacity(selectedCategory == nil || selectedCategory == category.id ? 1.0 : 0.5)
            }

            HStack(spacing: PCTheme.Spacing.xs) {
                Circle()
                    .fill(Color.pcBorder.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .voiceOverHidden()

                Text("Free")
                    .typography(.caption)

                Text(formatBytes(freeBytes))
                    .typography(.caption, color: .pcTextSecondary)
            }
        }
    }

    // MARK: - Helpers

    private func barWidth(for category: StorageCategory, in totalWidth: CGFloat) -> CGFloat {
        guard totalBytes > 0 else { return 0 }
        let fraction = CGFloat(category.sizeInBytes) / CGFloat(totalBytes)
        return max(0, fraction * (totalWidth - CGFloat(categories.count)))
    }

    private func freeBarWidth(in totalWidth: CGFloat) -> CGFloat {
        guard totalBytes > 0 else { return totalWidth }
        let usedWidth = categories.reduce(CGFloat(0)) { sum, cat in
            sum + barWidth(for: cat, in: totalWidth)
        }
        return max(0, totalWidth - usedWidth - CGFloat(categories.count))
    }

    private func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    private var accessibilitySummary: String {
        let parts = categories.map { "\($0.name): \(formatBytes($0.sizeInBytes))" }
        return "Storage breakdown. " + parts.joined(separator: ", ") + ". Free: \(formatBytes(freeBytes))"
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private struct LayoutResult {
        var size: CGSize
        var positions: [CGPoint]
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return LayoutResult(size: CGSize(width: maxWidth, height: totalHeight), positions: positions)
    }
}
