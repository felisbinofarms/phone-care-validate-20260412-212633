import SwiftUI

struct DuplicateGroupView: View {
    let group: [String]
    let groupIndex: Int
    let selectedIDs: Set<String>
    var onToggle: ((String) -> Void)?
    var onKeepBest: (() -> Void)?

    private var bestPhotoID: String? { group.first }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                // Header
                HStack {
                    Text("Group \(groupIndex + 1)")
                        .typography(.headline)

                    Spacer()

                    Text("\(group.count) photos")
                        .typography(.footnote, color: .pcTextSecondary)
                }

                // Grid
                PhotoGridView(
                    photoIDs: group,
                    selectedIDs: selectedIDs,
                    onToggle: onToggle
                )

                // Keep Best button
                if let best = bestPhotoID {
                    Divider()
                        .foregroundStyle(Color.pcBorder)

                    HStack {
                        Button {
                            onKeepBest?()
                        } label: {
                            HStack(spacing: PCTheme.Spacing.xs) {
                                Image(systemName: "star.fill")
                                    .font(.footnote)
                                Text("Keep Best, Select Rest")
                            }
                        }
                        .textLinkStyle()
                        .accessibilityHint("Keeps the highest quality photo and selects all others for deletion")

                        Spacer()

                        if selectedIDs.contains(where: { group.contains($0) }) {
                            let selectedInGroup = group.filter { selectedIDs.contains($0) }.count
                            Text("\(selectedInGroup) selected")
                                .typography(.caption, color: .pcAccent)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Duplicate group \(groupIndex + 1) with \(group.count) photos")
    }
}
