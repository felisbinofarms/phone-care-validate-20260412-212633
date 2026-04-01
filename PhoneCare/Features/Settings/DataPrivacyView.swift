import SwiftUI

struct DataPrivacyView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(AppState.self) private var appState
    @State private var showFirstConfirmation = false
    @State private var showFinalConfirmation = false
    @State private var isDeleting = false
    @State private var deleteComplete = false

    var body: some View {
        ScrollView {
            VStack(spacing: PCTheme.Spacing.lg) {
                // Info section
                CardView {
                    VStack(alignment: .leading, spacing: PCTheme.Spacing.md) {
                        HStack(spacing: PCTheme.Spacing.md) {
                            Image(systemName: "shield.checkered")
                                .font(.title2)
                                .foregroundStyle(Color.pcAccent)
                                .voiceOverHidden()

                            Text("Your Data Privacy")
                                .typography(.headline)
                        }

                        Text("All your data is stored on your device. PhoneCare does not send any personal data to external servers.")
                            .typography(.subheadline, color: .pcTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: PCTheme.Spacing.sm) {
                            privacyPoint("Scan results stay on your phone")
                            privacyPoint("No photos leave your device")
                            privacyPoint("Contact data is never uploaded")
                            privacyPoint("No third-party analytics")
                        }
                    }
                }

                // Delete section
                CardView {
                    VStack(alignment: .leading, spacing: PCTheme.Spacing.md) {
                        Text("Delete All Data")
                            .typography(.headline)
                            .voiceOverHeading()

                        Text("This will permanently delete all scan history, preferences, and cached data from PhoneCare. Your photos, contacts, and other phone data are not affected.")
                            .typography(.subheadline, color: .pcTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        if deleteComplete {
                            HStack(spacing: PCTheme.Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.pcAccent)
                                Text("All data has been deleted.")
                                    .typography(.subheadline, color: .pcAccent)
                            }
                        } else {
                            Button("Delete All PhoneCare Data") {
                                showFirstConfirmation = true
                            }
                            .destructiveStyle()
                            .disabled(isDeleting)
                        }
                    }
                }
            }
            .padding(.horizontal, PCTheme.Spacing.md)
            .padding(.top, PCTheme.Spacing.md)
            .padding(.bottom, PCTheme.Spacing.xl)
        }
        .background(Color.pcBackground)
        .navigationTitle("Data & Privacy")
        .alert("Delete all data?", isPresented: $showFirstConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showFinalConfirmation = true
            }
        } message: {
            Text("This will remove all PhoneCare data from your device. This cannot be undone.")
        }
        .alert("Are you sure?", isPresented: $showFinalConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Everything", role: .destructive) {
                performDelete()
            }
        } message: {
            Text("This is your last chance. All scan history, preferences, and cached data will be permanently deleted.")
        }
    }

    private func privacyPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: PCTheme.Spacing.sm) {
            Image(systemName: "checkmark.shield.fill")
                .font(.footnote)
                .foregroundStyle(Color.pcAccent)
                .voiceOverHidden()

            Text(text)
                .typography(.footnote, color: .pcTextSecondary)
        }
    }

    private func performDelete() {
        isDeleting = true
        do {
            try dataManager.deleteAllData()
            deleteComplete = true
        } catch {
            // Show error if needed
        }
        isDeleting = false
    }
}
