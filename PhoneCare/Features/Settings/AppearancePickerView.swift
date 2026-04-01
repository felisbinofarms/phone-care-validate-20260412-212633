import SwiftUI

struct AppearancePickerView: View {
    @Binding var selectedMode: AppearanceMode
    var onChange: (() -> Void)?

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.md) {
                Text("Appearance")
                    .typography(.headline)
                    .voiceOverHeading()

                Picker("Appearance", selection: $selectedMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedMode) { _, _ in
                    onChange?()
                }
                .accessibilityLabel("Appearance mode")
            }
        }
    }
}
