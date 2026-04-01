import SwiftUI

struct WelcomeHomeView: View {
    let viewModel: OnboardingViewModel
    let dataManager: DataManager
    let appState: AppState

    @State private var showContent = false
    @State private var hasSaved = false

    var body: some View {
        VStack(spacing: PCTheme.Spacing.xl) {
            Spacer()

            VStack(spacing: PCTheme.Spacing.lg) {
                // Celebration icon
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.pcAccent)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1 : 0)
                    .accessibilityHidden(true)

                VStack(spacing: PCTheme.Spacing.sm) {
                    Text("Welcome home!")
                        .typography(.largeTitle)
                        .opacity(showContent ? 1 : 0)

                    Text("Your phone is in good hands. We will help you keep it running smoothly.")
                        .typography(.body, color: .pcTextSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                }
            }

            Spacer()

            // This view auto-transitions after saving
            if !hasSaved {
                ProgressView()
                    .tint(Color.pcAccent)
                    .accessibilityLabel("Setting up your dashboard")
            }

            Spacer()
                .frame(height: PCTheme.Spacing.xxl)
        }
        .padding(.horizontal, PCTheme.Spacing.lg)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
        }
        .task {
            guard !hasSaved else { return }

            // Save preferences and mark onboarding complete
            await viewModel.savePreferences(to: dataManager, appState: appState)
            hasSaved = true

            // Brief celebration pause
            try? await Task.sleep(for: .seconds(1.5))

            // Transition to main app (handled by appState.hasCompletedOnboarding)
        }
        .accessibilityElement(children: .contain)
        .postVoiceOverAnnouncement("Welcome home! Your phone is set up and ready.")
    }
}
