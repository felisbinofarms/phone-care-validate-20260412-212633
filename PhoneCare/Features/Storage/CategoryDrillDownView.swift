import SwiftUI

struct CategoryDrillDownView: View {
    let category: StorageCategory
    @Environment(DataManager.self) private var dataManager

    @State private var details: [ScanDetail] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.lg) {
                // Header
                headerSection

                // Details list
                if details.isEmpty {
                    emptyState
                } else {
                    detailsList
                }

                // Tips
                tipsSection
            }
            .padding(.horizontal, PCTheme.Spacing.md)
            .padding(.top, PCTheme.Spacing.md)
        }
        .background(Color.pcBackground)
        .navigationTitle(category.name)
        .onAppear { loadDetails() }
    }

    // MARK: - Header

    private var headerSection: some View {
        CardView {
            HStack(spacing: PCTheme.Spacing.md) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(category.color)
                    .frame(width: 44, height: 44)
                    .background(category.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: PCTheme.Radius.sm))
                    .voiceOverHidden()

                VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                    Text(category.name)
                        .typography(.headline)

                    Text(formatBytes(category.sizeInBytes))
                        .typography(.title3, color: .pcTextSecondary)

                    Text("\(String(format: "%.1f", category.percentage))% of total storage")
                        .typography(.footnote, color: .pcTextSecondary)
                }

                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Details

    private var detailsList: some View {
        VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
            Text("Breakdown")
                .typography(.headline)
                .voiceOverHeading()

            ForEach(details, id: \.id) { detail in
                CardView {
                    HStack {
                        VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                            Text(detail.detailType.replacingOccurrences(of: "_", with: " ").capitalized)
                                .typography(.subheadline)

                            if detail.sizeInBytes > 0 {
                                Text(formatBytes(detail.sizeInBytes))
                                    .typography(.footnote, color: .pcTextSecondary)
                            }
                        }

                        Spacer()

                        if detail.value > 0 {
                            Text("\(Int(detail.value)) \(detail.unit)")
                                .typography(.footnote, color: .pcAccent)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        CardView {
            VStack(spacing: PCTheme.Spacing.md) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.largeTitle)
                    .foregroundStyle(Color.pcTextSecondary)
                    .voiceOverHidden()

                Text("No detailed breakdown available yet")
                    .typography(.subheadline, color: .pcTextSecondary)
                    .multilineTextAlignment(.center)

                Text("Run a scan from the home screen to get detailed information.")
                    .typography(.footnote, color: .pcTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PCTheme.Spacing.md)
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
            Text("Tips")
                .typography(.headline)
                .voiceOverHeading()

            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: PCTheme.Spacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .font(.footnote)
                        .foregroundStyle(Color.pcAccent)
                        .voiceOverHidden()

                    Text(tip)
                        .typography(.footnote, color: .pcTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.bottom, PCTheme.Spacing.lg)
    }

    private var tips: [String] {
        switch category.id {
        case "photos":
            return [
                "Duplicate and blurry photos often take up the most space.",
                "Consider using iCloud Photos to keep originals in the cloud.",
                "Screenshots you no longer need can add up over time."
            ]
        case "apps":
            return [
                "Offloading unused apps frees space but keeps your data.",
                "Check which apps you have not opened in the last month.",
                "Some apps store large caches that can be cleared."
            ]
        case "messages":
            return [
                "Old message threads with photos and videos can be large.",
                "You can set messages to auto-delete after 30 days in Settings.",
            ]
        default:
            return [
                "Regular cleanup helps keep your phone running smoothly.",
                "Back up important files before removing them."
            ]
        }
    }

    // MARK: - Helpers

    private func loadDetails() {
        do {
            if let scan = try dataManager.latestScanResult() {
                details = (scan.details ?? []).filter { $0.category == "storage" && $0.detailType.contains(category.id) }
            }
        } catch {
            // Show empty state
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
