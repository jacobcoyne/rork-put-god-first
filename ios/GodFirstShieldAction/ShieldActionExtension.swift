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

    private func shouldThrottleNotification(key: String) -> Bool {
        sharedDefaults?.synchronize()
        let lastSentKey = "lastNotifTime_\(key)"
        let lastSent = sharedDefaults?.double(forKey: lastSentKey) ?? 0
        let now = Date().timeIntervalSince1970
        if now - lastSent < 3600 {
            return true
        }
        sharedDefaults?.set(now, forKey: lastSentKey)
        sharedDefaults?.synchronize()
        return false
    }

    private func sendTimeLimitChallengeNotification() {
        guard !shouldThrottleNotification(key: "timeLimitShield") else { return }

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

        let request = UNNotificationRequest(
            identifier: "godFirst.timeLimitShield",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func sendOpenAppNotification() {
        if isTimeLimitBlocking {
            sendTimeLimitChallengeNotification()
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

        let notifKey = isTimeLimitBlocking ? "timeLimitShield" : (hasCompletedToday ? "scriptureUnlock" : "morningSession")
        guard !shouldThrottleNotification(key: notifKey) else { return }

        let request = UNNotificationRequest(
            identifier: "godFirst.openApp",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
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
