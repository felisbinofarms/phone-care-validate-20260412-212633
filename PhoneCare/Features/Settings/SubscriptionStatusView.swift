import SwiftUI

struct SubscriptionStatusView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showPaywall = false

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: PCTheme.Spacing.md) {
                HStack {
                    Image(systemName: subscriptionManager.isPremium ? "star.circle.fill" : "star.circle")
                        .font(.title2)
                        .foregroundStyle(Color.pcAccent)
                        .voiceOverHidden()

                    VStack(alignment: .leading, spacing: PCTheme.Spacing.xs) {
                        Text(subscriptionManager.isPremium ? "Premium" : "Free Plan")
                            .typography(.headline)

                        if subscriptionManager.isPremium {
                            if subscriptionManager.isInTrial {
                                Text("Free trial active")
                                    .typography(.footnote, color: .pcAccent)
                            }
                            if let expDate = subscriptionManager.expirationDate {
                                Text("Renews \(expDate.relativeFormatted())")
                                    .typography(.footnote, color: .pcTextSecondary)
                            }
                        } else {
                            Text("Upgrade for full access")
                                .typography(.footnote, color: .pcTextSecondary)
                        }
                    }

                    Spacer()
                }

                if subscriptionManager.isPremium {
                    Divider()
                        .foregroundStyle(Color.pcBorder)

                    Button("Manage Subscription") {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .textLinkStyle()
                    .accessibleTapTarget()

                    Button("Restore Purchases") {
                        Task { await subscriptionManager.restorePurchases() }
                    }
                    .textLinkStyle()
                    .accessibleTapTarget()
                } else {
                    Button("Upgrade to Premium") {
                        showPaywall = true
                    }
                    .primaryCTAStyle()
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallBottomSheet()
        }
        .accessibilityElement(children: .contain)
    }
}
