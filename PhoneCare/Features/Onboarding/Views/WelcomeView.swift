import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var showContent = false

    var body: some View {
        VStack(spacing: PCTheme.Spacing.xl) {
            Spacer()

            // Logo area
            VStack(spacing: PCTheme.Spacing.lg) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.pcAccent)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)

                VStack(spacing: PCTheme.Spacing.sm) {
                    Text("PhoneCare")
                        .typography(.largeTitle)

                    Text("Your phone, taken care of.")
                        .typography(.title3, color: .pcTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)

            Spacer()

            // CTA
            Button {
                onContinue()
            } label: {
                Text("Let's get started")
            }
            .primaryCTAStyle()
            .padding(.horizontal, PCTheme.Spacing.lg)
            .opacity(showContent ? 1 : 0)

            Spacer()
                .frame(height: PCTheme.Spacing.xxl)
        }
        .padding(.horizontal, PCTheme.Spacing.md)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                showContent = true
            }
        }
        .accessibilityElement(children: .contain)
    }
}
