import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    private struct ShieldMessage {
        let iconName: String
        let title: String
        let subtitle: String
    }

    private let messages: [ShieldMessage] = [
        ShieldMessage(
            iconName: "flame.fill",
            title: "Feed Your Soul First",
            subtitle: "Your spirit is hungry \u{2014} nourish it with God\u{2019}s Word before you feed the scroll. You got this!"
        ),
        ShieldMessage(
            iconName: "book.fill",
            title: "Hold Up!",
            subtitle: "This app isn\u{2019}t going anywhere. But your time with God? That\u{2019}s the good stuff. Go get it!"
        ),
        ShieldMessage(
            iconName: "crown.fill",
            title: "King Things First",
            subtitle: "Seek first His kingdom and everything else falls into place. Matthew 6:33"
        ),
        ShieldMessage(
            iconName: "heart.circle.fill",
            title: "Guard Your Heart",
            subtitle: "Above all else, guard your heart \u{2014} Proverbs 4:23. God\u{2019}s got better plans for your day!"
        ),
        ShieldMessage(
            iconName: "sparkles",
            title: "You\u{2019}re Glowing",
            subtitle: "Don\u{2019}t dim your light with mindless scrolling. Spend time with God and shine even brighter today!"
        ),
        ShieldMessage(
            iconName: "sun.max.fill",
            title: "Rise & Shine",
            subtitle: "The Son is calling you. Start your day in His presence and watch everything else fall into place."
        ),
        ShieldMessage(
            iconName: "drop.fill",
            title: "Thirsty for Real?",
            subtitle: "Jesus said: whoever drinks my water will never thirst \u{2014} John 4:14. Way better than your feed!"
        ),
        ShieldMessage(
            iconName: "leaf.fill",
            title: "Breathe, Bestie",
            subtitle: "Be still and know that He is God \u{2014} Psalm 46:10. Choose peace over the noise."
        ),
        ShieldMessage(
            iconName: "star.fill",
            title: "Choose the Better Part",
            subtitle: "Mary chose Jesus over distraction and so can you! Luke 10:42. Your future self will thank you."
        ),
        ShieldMessage(
            iconName: "figure.walk",
            title: "Walk by Faith",
            subtitle: "Not by sight \u{2014} and definitely not by scrolling! 2 Corinthians 5:7. Step toward God first."
        ),
        ShieldMessage(
            iconName: "hands.sparkles.fill",
            title: "You\u{2019}re Made for More",
            subtitle: "God\u{2019}s handiwork doesn\u{2019}t need a feed to feel good \u{2014} Ephesians 2:10. Go spend time with your Creator!"
        ),
        ShieldMessage(
            iconName: "shield.checkered",
            title: "Armor Up!",
            subtitle: "Put on the full armor of God! Ephesians 6:11. You\u{2019}re stronger than the urge to scroll."
        ),
    ]

    private func currentMessage() -> ShieldMessage {
        let minute = Calendar.current.component(.minute, from: Date())
        let index = minute % messages.count
        return messages[index]
    }

    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private var hasCompletedToday: Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), timestamp > 0 else {
            return false
        }
        let lastCompleted = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(lastCompleted)
    }

    private func makeConfiguration() -> ShieldConfiguration {
        let bgColor = UIColor(red: 0.06, green: 0.04, blue: 0.16, alpha: 1.0)
        let titleColor = UIColor.white
        let subtitleColor = UIColor(red: 0.82, green: 0.78, blue: 0.92, alpha: 1.0)
        let buttonTextColor = UIColor.white
        let secondaryTextColor = UIColor(red: 0.55, green: 0.52, blue: 0.68, alpha: 1.0)

        if !hasCompletedToday {
            let message = currentMessage()
            let buttonBgColor = UIColor(red: 0.22, green: 0.28, blue: 0.88, alpha: 1.0)
            let icon = UIImage(systemName: message.iconName)?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 34, weight: .medium))
                .withTintColor(UIColor(red: 0.52, green: 0.74, blue: 1.0, alpha: 1.0), renderingMode: .alwaysOriginal)

            return ShieldConfiguration(
                backgroundBlurStyle: .systemThickMaterialDark,
                backgroundColor: bgColor,
                icon: icon,
                title: ShieldConfiguration.Label(
                    text: message.title,
                    color: titleColor
                ),
                subtitle: ShieldConfiguration.Label(
                    text: message.subtitle + "\n\nComplete your daily session in God First to unlock your apps.",
                    color: subtitleColor
                ),
                primaryButtonLabel: ShieldConfiguration.Label(
                    text: "Start Session",
                    color: buttonTextColor
                ),
                primaryButtonBackgroundColor: buttonBgColor,
                secondaryButtonLabel: ShieldConfiguration.Label(
                    text: "Close App",
                    color: secondaryTextColor
                )
            )
        }

        let buttonBgColor = UIColor(red: 0.42, green: 0.28, blue: 0.92, alpha: 1.0)
        let icon = UIImage(systemName: "mic.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 34, weight: .medium))
            .withTintColor(UIColor(red: 0.68, green: 0.55, blue: 1.0, alpha: 1.0), renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterialDark,
            backgroundColor: bgColor,
            icon: icon,
            title: ShieldConfiguration.Label(
                text: "Recite to Unlock",
                color: titleColor
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Tap below to open God First. Recite a Bible verse or show your open Bible to unlock your apps.",
                color: subtitleColor
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Unlock with Scripture",
                color: buttonTextColor
            ),
            primaryButtonBackgroundColor: buttonBgColor,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Close App",
                color: secondaryTextColor
            )
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }
}
