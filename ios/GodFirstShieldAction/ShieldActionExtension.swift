import ManagedSettings
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {

    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private var hasCompletedToday: Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), timestamp > 0 else {
            return false
        }
        let lastCompleted = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(lastCompleted)
    }

    private func sendOpenAppNotification() {
        let content = UNMutableNotificationContent()
        content.sound = .default

        if !hasCompletedToday {
            content.title = "Put God First \u{2728}"
            content.body = "Tap here to start your daily session and unlock your apps."
            content.userInfo = ["openSession": true]
            content.categoryIdentifier = "SHIELD_TAP"
        } else {
            content.title = "Unlock Your Apps \u{1F513}"
            content.body = "Tap here to recite scripture or show your Bible."
            content.userInfo = ["unlockChooser": true, "isPostSession": true]
            content.categoryIdentifier = "SHIELD_TAP"
        }

        let request = UNNotificationRequest(
            identifier: "godFirst.openApp.\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.3, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendOpenAppNotification()
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendOpenAppNotification()
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendOpenAppNotification()
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
}
