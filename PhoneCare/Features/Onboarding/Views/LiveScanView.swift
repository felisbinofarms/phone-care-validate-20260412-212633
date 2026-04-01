import SwiftUI

struct LiveScanView: View {
    @Bindable var viewModel: OnboardingViewModel
    let storageAnalyzer: StorageAnalyzer
    let photoAnalyzer: PhotoAnalyzer
    let contactAnalyzer: ContactAnalyzer
    let batteryMonitor: BatteryMonitor
    let privacyAuditor: PrivacyAuditor
    let permissionManager: PermissionManager
    let onComplete: () -> Void

    @State private var hasStarted = false
    @State private var animatePulse = false

    var body: some View {
        VStack(spacing: PCTheme.Spacing.xl) {
            Spacer()

            // Animated scan icon
            ZStack {
                Circle()
                    .fill(Color.pcMintTint)
                    .frame(width: 120, height: 120)
                    .scaleEffect(animatePulse ? 1.1 : 1.0)
                    .opacity(animatePulse ? 0.6 : 0.3)

                Circle()
                    .fill(Color.pcMintTint)
                    .frame(width: 90, height: 90)

                Image(systemName: scanStageIcon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.pcAccent)
                    .contentTransition(.symbolEffect(.replace))
            }
            .accessibilityHidden(true)

            // Status text
            VStack(spacing: PCTheme.Spacing.sm) {
                Text("Scanning your phone")
                    .typography(.title2)

                Text(viewModel.scanStage.message)
                    .typography(.body, color: .pcTextSecondary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: viewModel.scanStage)
            }

            // Progress bar
            VStack(spacing: PCTheme.Spacing.sm) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.pcBorder)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.pcAccent)
                            .frame(
                                width: geometry.size.width * viewModel.scanProgress,
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.3), value: viewModel.scanProgress)
                    }
                }
                .frame(height: 8)

                Text("\(Int(viewModel.scanProgress * 100))%")
                    .typography(.footnote, color: .pcTextSecondary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, PCTheme.Spacing.xxl)

            // Step checklist
            VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                ScanChecklistItem(label: "Storage", stage: .storage, currentStage: viewModel.scanStage)
                ScanChecklistItem(label: "Photos", stage: .photos, currentStage: viewModel.scanStage)
                ScanChecklistItem(label: "Contacts", stage: .contacts, currentStage: viewModel.scanStage)
                ScanChecklistItem(label: "Battery", stage: .battery, currentStage: viewModel.scanStage)
                ScanChecklistItem(label: "Privacy", stage: .privacy, currentStage: viewModel.scanStage)
            }
            .padding(.horizontal, PCTheme.Spacing.xxl)

            Spacer()
        }
        .padding(.horizontal, PCTheme.Spacing.md)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animatePulse = true
            }
        }
        .task {
            guard !hasStarted else { return }
            hasStarted = true
            await viewModel.runScan(
                storageAnalyzer: storageAnalyzer,
                photoAnalyzer: photoAnalyzer,
                contactAnalyzer: contactAnalyzer,
                batteryMonitor: batteryMonitor,
                privacyAuditor: privacyAuditor,
                permissionManager: permissionManager
            )
            // Brief pause so user sees "complete" state
            try? await Task.sleep(for: .milliseconds(600))
            onComplete()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Scanning your phone. \(viewModel.scanStage.message)")
    }

    private var scanStageIcon: String {
        switch viewModel.scanStage {
        case .idle: return "magnifyingglass"
        case .storage: return "internaldrive.fill"
        case .photos: return "photo.fill"
        case .contacts: return "person.2.fill"
        case .battery: return "battery.75percent"
        case .privacy: return "lock.shield.fill"
        case .complete: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Scan Checklist Item

private struct ScanChecklistItem: View {
    let label: String
    let stage: ScanStage
    let currentStage: ScanStage

    private var state: ItemState {
        if currentStage == .complete || currentStage.rawValue > stage.rawValue {
            return .done
        } else if currentStage == stage {
            return .active
        } else {
            return .pending
        }
    }

    private enum ItemState {
        case pending, active, done
    }

    var body: some View {
        HStack(spacing: PCTheme.Spacing.sm) {
            Group {
                switch state {
                case .done:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.pcAccent)
                case .active:
                    ProgressView()
                        .controlSize(.small)
                case .pending:
                    Image(systemName: "circle")
                        .foregroundStyle(Color.pcBorder)
                }
            }
            .frame(width: 20)

            Text(label)
                .typography(state == .active ? .headline : .body,
                           color: state == .pending ? .pcTextSecondary : .pcTextPrimary)
        }
        .animation(.easeInOut(duration: 0.2), value: state == .done)
    }
}

// MARK: - ScanStage raw comparable

private extension ScanStage {
    var rawValue: Int {
        switch self {
        case .idle: return 0
        case .storage: return 1
        case .photos: return 2
        case .contacts: return 3
        case .battery: return 4
        case .privacy: return 5
        case .complete: return 6
        }
    }
}
