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

    private var isTimeLimitBlocking: Bool {
        sharedDefaults?.synchronize()
        let locked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") ?? false
        guard locked else { return false }
        guard let ts = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), ts > 0 else { return false }
        let d = Date(timeIntervalSince1970: ts)
        return Calendar.current.isDateInToday(d)
    }

    private func sendTimeLimitChallengeNotification(completion: @escaping () -> Void) {
        let content = UNMutableNotificationContent()
        content.title = "Screen Time Limit Reached \u{23F0}"
        content.body = "Tap this notification to open Put God First and complete a challenge."
        content.userInfo = [
            "isTimeLimitChallenge": true,
            "deepLink": "putgodfirst://time-limit-unlock"
        ]
        content.sound = .default
        content.categoryIdentifier = "SCREEN_TIME_LIMIT"
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0

        let uniqueId = "godFirst.timeLimitShield.\(Int(Date().timeIntervalSince1970 * 1000))"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: uniqueId,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { _ in
            completion()
        }
    }

    private func sendOpenAppNotification(completion: @escaping () -> Void) {
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "shieldTapTimestamp")
        sharedDefaults?.synchronize()

        if isTimeLimitBlocking {
            sendTimeLimitChallengeNotification(completion: completion)
            return
        }

        let content = UNMutableNotificationContent()
        let isPostSession = hasCompletedToday

        if isPostSession {
            content.title = "Recite Scripture to Unlock 📖"
            content.body = "Tap this notification to open Put God First and recite a verse."
            content.userInfo = [
                "isPostSession": true,
                "deepLink": "putgodfirst://scripture-unlock"
            ]
        } else {
            content.title = "Put God First 🙏"
            content.body = "Tap this notification to open Put God First and start your session."
            content.userInfo = [
                "isPostSession": false,
                "deepLink": "putgodfirst://start-session"
            ]
        }
        content.sound = .default
        content.categoryIdentifier = "SHIELD_TAP"
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0

        let uniqueId = "godFirst.openApp.\(Int(Date().timeIntervalSince1970 * 1000))"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: uniqueId,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { _ in
            completion()
        }
    }

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendOpenAppNotification {
                completionHandler(.close)
            }
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendOpenAppNotification {
                completionHandler(.close)
            }
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendOpenAppNotification {
                completionHandler(.close)
            }
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
}
