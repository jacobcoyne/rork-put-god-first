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

    private func sendNotificationAndComplete(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        sharedDefaults?.synchronize()

        let content = UNMutableNotificationContent()
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0

        if isTimeLimitBlocking {
            content.title = "Screen Time Limit Reached \u{23F0}"
            content.body = "Tap here to open Put God First and complete a challenge."
            content.userInfo = [
                "isTimeLimitChallenge": true,
                "deepLink": "putgodfirst://time-limit-unlock"
            ]
            content.categoryIdentifier = "SCREEN_TIME_LIMIT"
        } else if hasCompletedToday {
            content.title = "Recite Scripture to Unlock 📖"
            content.body = "Tap here to open Put God First and recite a verse."
            content.userInfo = [
                "isPostSession": true,
                "deepLink": "putgodfirst://scripture-unlock"
            ]
            content.categoryIdentifier = "SHIELD_TAP"
        } else {
            content.title = "Put God First 🙏"
            content.body = "Tap here to open Put God First and start your session."
            content.userInfo = [
                "isPostSession": false,
                "deepLink": "putgodfirst://start-session"
            ]
            content.categoryIdentifier = "SHIELD_TAP"
        }

        let uniqueId = "godFirst.shield.\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(
            identifier: uniqueId,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { _ in
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendNotificationAndComplete(completionHandler: completionHandler)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendNotificationAndComplete(completionHandler: completionHandler)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            sendNotificationAndComplete(completionHandler: completionHandler)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
}
