import ManagedSettings
import ManagedSettingsUI
import UIKit

nonisolated class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    nonisolated override func configuration(shielding application: Application) -> ShieldConfiguration {
        return buildConfiguration(appName: application.localizedDisplayName)
    }

    nonisolated override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return buildConfiguration(appName: application.localizedDisplayName ?? category.localizedDisplayName)
    }

    nonisolated override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return buildConfiguration(appName: webDomain.domain)
    }

    nonisolated override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return buildConfiguration(appName: webDomain.domain ?? category.localizedDisplayName)
    }

    nonisolated private func buildConfiguration(appName: String?) -> ShieldConfiguration {
        let messages: [(String, String)] = [
            ("🙏 God First, Scroll Later", "Put down %@ and pick up the Word! Complete your morning session to unlock."),
            ("⛪ Not Yet, Fam!", "%@ can wait. Your soul can't! Open Put God First to start your day right."),
            ("🔥 Stay Focused!", "You're trying to open %@ but God's got better plans. Do your session first!"),
            ("✝️ Scripture Before Scrolling", "%@ is locked until you spend time with God. You got this! 💪"),
            ("🚫 Nah, Not Right Now", "%@ is on pause. God's Word hits different — go read it first!"),
            ("☕ God Before the Gram", "%@ isn't going anywhere. But your peace is waiting. ☕✨"),
            ("🛡️ Morning Armor Active", "Start your day in the Word before the world. %@ will be here after."),
            ("📵 Phone Down, Prayer Up", "5 min with God > 5 hours of %@. No cap. 🧢"),
        ]

        let index = abs(Int(Date().timeIntervalSince1970)) % messages.count
        let (title, subtitle) = messages[index]
        let name = appName ?? "This app"
        let formattedSubtitle = subtitle.replacingOccurrences(of: "%@", with: name)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterialDark,
            backgroundColor: UIColor(red: 0.08, green: 0.07, blue: 0.14, alpha: 1.0),
            icon: UIImage(systemName: "book.closed.fill"),
            title: ShieldConfiguration.Label(
                text: title,
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: formattedSubtitle,
                color: UIColor(white: 0.82, alpha: 1.0)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Put God First ✨",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.40, green: 0.28, blue: 0.90, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: UIColor(white: 0.55, alpha: 1.0)
            )
        )
    }
}
