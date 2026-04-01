import SwiftUI

struct EducationalContentView: View {
    let permissionType: PermissionType

    var body: some View {
        VStack(alignment: .leading, spacing: PCTheme.Spacing.md) {
            Text("What this means")
                .typography(.headline)
                .voiceOverHeading()

            Text(explanation)
                .typography(.subheadline, color: .pcTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if !tips.isEmpty {
                Text("Our suggestion")
                    .typography(.headline)
                    .padding(.top, PCTheme.Spacing.sm)
                    .voiceOverHeading()

                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: PCTheme.Spacing.sm) {
                        Image(systemName: "lightbulb.fill")
                            .font(.footnote)
                            .foregroundStyle(Color.pcAccent)
                            .voiceOverHidden()

                        Text(tip)
                            .typography(.subheadline, color: .pcTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var explanation: String {
        switch permissionType {
        case .camera:
            return "Camera access lets apps take photos and videos using your phone's camera. Only apps you actively use for photography or video calls should need this."
        case .microphone:
            return "Microphone access lets apps listen to audio. This is needed for voice calls, voice messages, and video recording. Be mindful of which apps have this access."
        case .location:
            return "Location access lets apps know where you are. Some apps need this to work, like maps and weather. Others may not need it at all."
        case .contacts:
            return "Contacts access lets apps read your address book. Messaging apps often need this, but many other apps do not."
        case .photos:
            return "Photos access lets apps see your photo library. Consider using 'Limited' access to share only specific photos with apps that need them."
        case .calendar:
            return "Calendar access lets apps read and create events. Only apps that manage your schedule should need this."
        case .reminders:
            return "Reminders access lets apps read and create reminders. Only productivity and task apps typically need this."
        case .bluetooth:
            return "Bluetooth access lets apps connect to nearby devices like headphones, speakers, or fitness trackers."
        case .localNetwork:
            return "Local network access lets apps find and communicate with devices on your WiFi network, like smart home devices or printers."
        case .health:
            return "Health access lets apps read health and fitness data from the Health app. Only fitness and wellness apps should need this."
        case .tracking:
            return "App tracking lets apps follow your activity across other companies' apps and websites. Most people choose to turn this off."
        }
    }

    private var tips: [String] {
        switch permissionType {
        case .camera:
            return ["Only allow camera access for apps you use to take photos or make video calls."]
        case .microphone:
            return ["Review which apps have microphone access. If you do not use an app for calls or recording, it probably does not need it."]
        case .location:
            return [
                "Choose 'While Using' instead of 'Always' when possible.",
                "Apps like social media rarely need your precise location."
            ]
        case .contacts:
            return ["Only messaging and communication apps typically need access to your contacts."]
        case .photos:
            return ["Use 'Limited Access' to share only the photos an app needs, rather than your whole library."]
        case .calendar:
            return ["Only calendar and scheduling apps need this access."]
        case .reminders:
            return ["Only task management apps need this access."]
        case .bluetooth:
            return ["If you do not use Bluetooth accessories with an app, it does not need this access."]
        case .localNetwork:
            return ["Most apps do not need local network access unless they control smart home devices."]
        case .health:
            return ["Only grant Health access to apps you trust with your personal health information."]
        case .tracking:
            return ["Turning off tracking does not affect how apps work. It only stops them from following you across other apps."]
        }
    }
}
