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
            title: "\u{1F525} Feed your soul first!",
            subtitle: "Your spirit is hungry \u{1F37D}\u{FE0F} Nourish it with God\u{2019}s Word before you feed the scroll. You got this! \u{1F4AA}"
        ),
        ShieldMessage(
            iconName: "book.fill",
            title: "\u{1F6D1} Hold up!",
            subtitle: "This app isn\u{2019}t going anywhere \u{1F60C} But your time with God? That\u{2019}s the good stuff. Go get it! \u{2728}"
        ),
        ShieldMessage(
            iconName: "crown.fill",
            title: "\u{1F451} King things first!",
            subtitle: "Seek first His kingdom and everything else falls into place \u{1F64F} Matthew 6:33. The scroll can wait! \u{1F4F1}"
        ),
        ShieldMessage(
            iconName: "heart.circle.fill",
            title: "\u{1F49B} Guard your heart!",
            subtitle: "Above all else, guard your heart \u{2014} Proverbs 4:23 \u{1F6E1}\u{FE0F} God\u{2019}s got better plans for your morning! \u{2600}\u{FE0F}"
        ),
        ShieldMessage(
            iconName: "sparkles",
            title: "\u{2728} You\u{2019}re glowing!",
            subtitle: "Don\u{2019}t dim your light with mindless scrolling \u{1F4F2} Spend time with God and shine even brighter today! \u{1F31F}"
        ),
        ShieldMessage(
            iconName: "sun.max.fill",
            title: "\u{2600}\u{FE0F} Rise & shine!",
            subtitle: "The Son is calling you \u{1F324}\u{FE0F} Start your day in His presence and watch everything else fall into place \u{1F64C}"
        ),
        ShieldMessage(
            iconName: "drop.fill",
            title: "\u{1F4A7} Thirsty for real?",
            subtitle: "Jesus said: whoever drinks my water will never thirst \u{1F64F} John 4:14. Way better than your feed! \u{1F602}"
        ),
        ShieldMessage(
            iconName: "leaf.fill",
            title: "\u{1F343} Breathe, bestie",
            subtitle: "Be still and know that He is God \u{1F54A}\u{FE0F} Psalm 46:10. Take a deep breath and choose peace over the noise \u{1F90D}"
        ),
        ShieldMessage(
            iconName: "star.fill",
            title: "\u{1F31F} Choose the better part!",
            subtitle: "Mary chose Jesus over distraction and so can you! \u{1F4AA} Luke 10:42. Your future self will thank you \u{1F60A}"
        ),
        ShieldMessage(
            iconName: "figure.walk",
            title: "\u{1F6B6} Walk by faith!",
            subtitle: "Not by sight \u{1F440} and definitely not by scrolling! 2 Cor 5:7. Step toward God first \u{1F3AF}"
        ),
        ShieldMessage(
            iconName: "hands.sparkles.fill",
            title: "\u{1F64C} You\u{2019}re made for MORE!",
            subtitle: "God\u{2019}s handiwork doesn\u{2019}t need a feed to feel good \u{1F48E} Ephesians 2:10. Go spend time with your Creator! \u{1F525}"
        ),
        ShieldMessage(
            iconName: "shield.checkered",
            title: "\u{1F6E1}\u{FE0F} Armor up!",
            subtitle: "Put on the full armor of God! \u{2694}\u{FE0F} Ephesians 6:11. You\u{2019}re stronger than the urge to scroll \u{1F4AA}\u{1F525}"
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

    private var isTimeLimitBlocking: Bool {
        sharedDefaults?.synchronize()
        let locked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") ?? false
        guard locked else { return false }
        guard let ts = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), ts > 0 else { return false }
        let d = Date(timeIntervalSince1970: ts)
        return Calendar.current.isDateInToday(d)
    }

    private var timeLimitMinutes: Int {
        sharedDefaults?.synchronize()
        return sharedDefaults?.integer(forKey: "screenTimeLimitMinutes") ?? 30
    }

    private func makeConfiguration() -> ShieldConfiguration {
        let bgColor = UIColor(red: 0.08, green: 0.06, blue: 0.20, alpha: 1.0)
        let titleColor = UIColor.white
        let subtitleColor = UIColor(red: 0.78, green: 0.74, blue: 0.90, alpha: 1.0)
        let buttonTextColor = UIColor.white
        let secondaryTextColor = UIColor(red: 0.6, green: 0.58, blue: 0.72, alpha: 1.0)

        if isTimeLimitBlocking {
            let buttonBgColor = UIColor(red: 1.0, green: 0.68, blue: 0.28, alpha: 1.0)
            let icon = UIImage(systemName: "hourglass")?
                .withTintColor(.white, renderingMode: .alwaysOriginal)

            return ShieldConfiguration(
                backgroundBlurStyle: .systemThickMaterialDark,
                backgroundColor: bgColor,
                icon: icon,
                title: ShieldConfiguration.Label(text: "\u{23F0} Screen Time Limit Reached", color: titleColor),
                subtitle: ShieldConfiguration.Label(text: "You\u{2019}ve used your \(timeLimitMinutes)-minute daily limit! \u{1F4AA} Tap below to complete a faith challenge and unlock your apps. You got this! \u{1F525}", color: subtitleColor),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Take the Challenge \u{2728}", color: buttonTextColor),
                primaryButtonBackgroundColor: buttonBgColor,
                secondaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: secondaryTextColor)
            )
        }

        if hasCompletedToday {
            let buttonBgColor = UIColor(red: 0.52, green: 0.35, blue: 0.95, alpha: 1.0)
            let icon = UIImage(systemName: "mic.fill")?
                .withTintColor(.white, renderingMode: .alwaysOriginal)

            return ShieldConfiguration(
                backgroundBlurStyle: .systemThickMaterialDark,
                backgroundColor: bgColor,
                icon: icon,
                title: ShieldConfiguration.Label(text: "\u{1F4D6} Recite Scripture to Unlock", color: titleColor),
                subtitle: ShieldConfiguration.Label(text: "You already put God first today! \u{1F64F} Tap below to recite a verse and unlock your apps. You got this! \u{1F4AA}", color: subtitleColor),
                primaryButtonLabel: ShieldConfiguration.Label(text: "Recite Scripture \u{1F399}\u{FE0F}", color: buttonTextColor),
                primaryButtonBackgroundColor: buttonBgColor,
                secondaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: secondaryTextColor)
            )
        }

        let message = currentMessage()
        let buttonBgColor = UIColor(red: 0.28, green: 0.32, blue: 0.92, alpha: 1.0)
        let icon = UIImage(systemName: message.iconName)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterialDark,
            backgroundColor: bgColor,
            icon: icon,
            title: ShieldConfiguration.Label(text: message.title, color: titleColor),
            subtitle: ShieldConfiguration.Label(text: message.subtitle, color: subtitleColor),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Open God First \u{1F64F}", color: buttonTextColor),
            primaryButtonBackgroundColor: buttonBgColor,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: secondaryTextColor)
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
