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
        if now - lastSent < 3 {
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
        content.body = "Tap to open Put God First and complete a challenge."
        content.userInfo = [
            "isTimeLimitChallenge": true,
            "deepLink": "putgodfirst://time-limit-unlock"
        ]
        content.sound = .default
        content.categoryIdentifier = "SCREEN_TIME_LIMIT"
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0

        let uniqueId = "godFirst.timeLimitShield.\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(
            identifier: uniqueId,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)

        sharedDefaults?.set("time-limit-unlock", forKey: "pendingShieldDeepLink")
        sharedDefaults?.synchronize()
    }

    private func sendOpenAppNotification() {
        if isTimeLimitBlocking {
            sendTimeLimitChallengeNotification()
            return
        }

        let notifKey = hasCompletedToday ? "scriptureUnlock" : "morningSession"
        guard !shouldThrottleNotification(key: notifKey) else { return }

        let content = UNMutableNotificationContent()
        let isPostSession = hasCompletedToday
        let deepLink: String

        if isPostSession {
            deepLink = "putgodfirst://scripture-unlock"
            content.title = "Recite Scripture to Unlock \u{1F4D6}"
            content.body = "Tap to open Put God First and recite a verse."
            content.userInfo = [
                "isPostSession": true,
                "deepLink": deepLink
            ]
        } else {
            deepLink = "putgodfirst://start-session"
            content.title = "Put God First \u{1F64F}"
            content.body = "Tap to open Put God First and start your session."
            content.userInfo = [
                "isPostSession": false,
                "deepLink": deepLink
            ]
        }
        content.sound = .default
        content.categoryIdentifier = "SHIELD_TAP"
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0

        let uniqueId = "godFirst.openApp.\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(
            identifier: uniqueId,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)

        let linkKey = isPostSession ? "scripture-unlock" : "start-session"
        sharedDefaults?.set(linkKey, forKey: "pendingShieldDeepLink")
        sharedDefaults?.synchronize()
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
