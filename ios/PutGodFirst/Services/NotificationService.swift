import Foundation
import UserNotifications

enum NotificationService {

    private static let reminderTimeKey = "morningReminderTime"

    static var savedReminderTime: Date {
        if let saved = UserDefaults.standard.object(forKey: reminderTimeKey) as? Date {
            return saved
        }
        var comps = DateComponents()
        comps.hour = 7
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? .now
    }

    static func saveReminderTime(_ date: Date) {
        UserDefaults.standard.set(date, forKey: reminderTimeKey)
    }

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .providesAppNotificationSettings]) { granted, _ in
            if granted {
                scheduleAllNotifications()
            }
        }
    }

    static func scheduleAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        scheduleAppsLockedNotifications()
    }

    static func sendPostChallengeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Apps Unlocked! 🎉"
        content.body = "You completed the challenge. Your apps are free — go enjoy your day!"
        content.sound = .default
        content.interruptionLevel = .active

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "post-challenge-unlock",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelTodayNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["morning-locked-0"])
    }

    static func rescheduleAfterCompletion() {
        cancelTodayNotifications()
    }

    static func scheduleMidnightRelockNotifications() {}

    static func cancelRelockNotifications() {}

    private static func scheduleAppsLockedNotifications() {
        let st = ScreenTimeService.shared
        guard st.godFirstModeActive || st.godFirstModeEnrolled else { return }

        let center = UNUserNotificationCenter.current()
        let reminderTime = savedReminderTime
        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)

        for dayOffset in 0..<7 {
            let content = UNMutableNotificationContent()
            content.title = "Your Apps Are Locked 🔒"
            content.body = "Open Put God First and complete your morning session to unlock your apps."
            content.sound = .default
            content.interruptionLevel = .timeSensitive
            content.categoryIdentifier = "OPEN_APP"
            content.userInfo = ["deepLink": "putgodfirst://start-session"]

            var comps = DateComponents()
            comps.hour = timeComps.hour
            comps.minute = timeComps.minute
            if dayOffset > 0 {
                if let future = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
                    let futureComps = Calendar.current.dateComponents([.year, .month, .day], from: future)
                    comps.year = futureComps.year
                    comps.month = futureComps.month
                    comps.day = futureComps.day
                }
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: dayOffset == 0)
            center.add(UNNotificationRequest(
                identifier: "morning-locked-\(dayOffset)",
                content: content,
                trigger: trigger
            ))
        }
    }
}
