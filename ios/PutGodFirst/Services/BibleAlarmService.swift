import Foundation
import UIKit
import UserNotifications

enum BibleAlarmService {
    private static let alarmKey = "bibleAlarmData"
    private static let alarmCategoryID = "BIBLE_ALARM"
    private static let alarmNotificationPrefix = "bible-alarm-"
    private static let followUpPrefix = "bible-alarm-followup-"
    private static let followUpCount = 20
    private static let followUpIntervalSeconds = 30

    static func saveAlarm(_ alarm: BibleAlarm) {
        if let data = try? JSONEncoder().encode(alarm) {
            UserDefaults.standard.set(data, forKey: alarmKey)
        }
    }

    static func loadAlarm() -> BibleAlarm {
        guard let data = UserDefaults.standard.data(forKey: alarmKey),
              let alarm = try? JSONDecoder().decode(BibleAlarm.self, from: data) else {
            return BibleAlarm()
        }
        return alarm
    }

    static func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            Task { @MainActor in
                completion(granted)
            }
        }
    }

    static func scheduleAlarm(_ alarm: BibleAlarm) {
        cancelAlarm()
        guard alarm.isEnabled else { return }

        let center = UNUserNotificationCenter.current()
        let soundFile = AlarmSoundFileService.soundFileName(for: alarm.sound)


        let bodies = [
            alarm.dismissMethod == .scanBible
                ? "Take a photo of your OPEN Bible to turn off your alarm"
                : "Recite a Bible verse out loud to turn off your alarm",
            "Your alarm is still ringing! Open the app to dismiss it.",
            "⏰ Wake up! Open your Bible to silence the alarm.",
            "Don't hit snooze — God is waiting for you!",
            "Your Bible Alarm is still going! Time to put God first.",
            "Rise and shine! Open the app and start your morning with God.",
            "⏰ Still ringing! Take a photo of your Bible or recite a verse.",
            "Good morning! Your alarm won't stop until you put God first.",
            "Time to wake up and meet with God!",
            "Your Bible Alarm needs your attention!",
            "Open your Bible — your alarm is waiting!",
            "⏰ Final call! Open the app to dismiss your alarm.",
            "God First! Open the app now to turn off the alarm."
        ]

        for day in alarm.repeatDays {
            var dateComponents = DateComponents()
            dateComponents.hour = alarm.hour
            dateComponents.minute = alarm.minute
            dateComponents.weekday = day

            let content = makeAlarmContent(
                title: "Time to Open Your Bible",
                body: bodies[0],
                soundFile: soundFile,
                volume: Float(alarm.volume),
                alarm: alarm,
                useCritical: false
            )

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(alarmNotificationPrefix)\(day)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }

        scheduleFollowUpNotifications(alarm: alarm, soundFile: soundFile, bodies: bodies, useCritical: false)
        saveAlarm(alarm)
    }

    private static func makeAlarmContent(
        title: String,
        body: String,
        soundFile: String,
        volume: Float,
        alarm: BibleAlarm,
        useCritical: Bool
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName(soundFile))
        content.categoryIdentifier = alarmCategoryID
        content.interruptionLevel = .timeSensitive
        content.userInfo = [
            "sound": alarm.sound.rawValue,
            "vibration": alarm.vibration.rawValue,
            "dismissMethod": alarm.dismissMethod.rawValue
        ]
        return content
    }

    private static func scheduleFollowUpNotifications(
        alarm: BibleAlarm,
        soundFile: String,
        bodies: [String],
        useCritical: Bool
    ) {
        let center = UNUserNotificationCenter.current()

        for day in alarm.repeatDays {
            for i in 1...followUpCount {
                let totalOffsetSeconds = alarm.minute * 60 + alarm.hour * 3600 + i * followUpIntervalSeconds
                let adjustedHour = (totalOffsetSeconds / 3600) % 24
                let adjustedMinute = (totalOffsetSeconds % 3600) / 60
                let adjustedSecond = totalOffsetSeconds % 60

                var dateComponents = DateComponents()
                dateComponents.weekday = day
                dateComponents.hour = adjustedHour
                dateComponents.minute = adjustedMinute
                dateComponents.second = adjustedSecond

                let bodyIndex = min(i, bodies.count - 1)
                let content = makeAlarmContent(
                    title: "⏰ Bible Alarm",
                    body: bodies[bodyIndex],
                    soundFile: soundFile,
                    volume: Float(alarm.volume),
                    alarm: alarm,
                    useCritical: useCritical
                )

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(followUpPrefix)\(day)-\(i)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }

    static func checkNotificationStatus() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    static func openAppNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    static func cancelAlarm() {
        let center = UNUserNotificationCenter.current()
        var identifiers = (1...7).map { "\(alarmNotificationPrefix)\($0)" }
        for day in 1...7 {
            for i in 1...followUpCount {
                identifiers.append("\(followUpPrefix)\(day)-\(i)")
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        AlarmAudioService.shared.stopPlayback()
    }

    static func cancelFollowUps() {
        let center = UNUserNotificationCenter.current()
        var identifiers: [String] = []
        for day in 1...7 {
            for i in 1...followUpCount {
                identifiers.append("\(followUpPrefix)\(day)-\(i)")
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    static func registerCategory() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open Bible",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: alarmCategoryID,
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
