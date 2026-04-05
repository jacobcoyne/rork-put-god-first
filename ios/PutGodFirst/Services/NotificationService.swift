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

    private static let morningMessages: [(title: String, body: String)] = [
        ("Good morning ☀️", "Take a moment to put God first before you start your day."),
        ("Rise & Shine", "The Lord's mercies are new every morning. Start today in His presence."),
        ("New Day, New Grace", "This is the day the Lord has made — let's begin it with Him."),
        ("Morning Blessing", "Before the world gets loud, let God speak first."),
        ("First Things First", "A few minutes with God now sets the tone for everything ahead."),
        ("Good Morning", "\"Seek first the kingdom of God…\" — Matthew 6:33"),
        ("Your Day Awaits", "Ground yourself in prayer before the rush begins."),
        ("Dawn of Grace", "God has something for you today. Start by listening."),
        ("Peace Before the Pace", "Spend a quiet moment with the One who calms every storm."),
        ("A Fresh Start", "Yesterday is gone. Today is a gift. Begin it with gratitude."),
        ("Morning Light", "Let His word be a lamp to your feet as you step into today."),
        ("God First", "The best mornings start on your knees. Take a moment with Him."),
        ("Strength for Today", "\"I can do all things through Christ who strengthens me.\" — Phil 4:13"),
        ("Be Still", "Before you check your phone, check in with God."),
        ("Walk in Faith", "Trust God with today. He already knows what you need."),
    ]

    private static let middayMessages: [(title: String, body: String)] = [
        ("Midday Check-In", "Pause for a moment. Breathe. Remember God is with you."),
        ("Halfway There", "Haven't done your session yet? There's still time to put God first."),
        ("Afternoon Grace", "Take 60 seconds to thank God for something today."),
        ("Still Time", "Your daily session is waiting. A few minutes can change your whole day."),
        ("Quick Reminder", "Don't let the day pass without spending time in His presence."),
        ("Pause & Pray", "Even Jesus withdrew to quiet places to pray. You can too."),
        ("Refuel Your Spirit", "Feeling drained? Let God refill you. Open your session now."),
    ]

    private static let eveningMessages: [(title: String, body: String)] = [
        ("Evening Reflection", "Before the day ends, reflect on where you saw God today."),
        ("Wind Down with God", "End your day the way you started — in His presence."),
        ("Gratitude Moment", "Name three things God blessed you with today."),
        ("Rest in Him", "\"Come to me, all who are weary, and I will give you rest.\" — Matt 11:28"),
        ("Nightly Peace", "Hand your worries to God tonight. He's got tomorrow covered."),
        ("Day's End", "Close this chapter with a prayer. Tomorrow is full of new mercies."),
    ]

    private static let streakMessages: [(title: String, body: String)] = [
        ("Keep the Fire Burning 🔥", "Your streak is alive! Don't let today be the day it breaks."),
        ("Consistency Matters", "Every day you show up, your faith grows stronger."),
        ("Don't Break the Chain", "You've been faithful — keep going. God sees your dedication."),
        ("Momentum Builder", "Your daily habit is shaping who you're becoming. Stay the course."),
        ("Faithful & Steady", "Small daily steps lead to a transformed life. Keep walking."),
    ]

    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                scheduleAllNotifications()
            }
        }
    }

    private static let secondMessages: [(title: String, body: String)] = {
        var combined: [(title: String, body: String)] = []
        combined.append(contentsOf: middayMessages)
        combined.append(contentsOf: streakMessages)
        combined.append(contentsOf: eveningMessages)
        return combined
    }()

    static func scheduleMidnightRelockNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "relock-midnight", "relock-3am", "relock-5am"
        ])
    }

    static func cancelRelockNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "relock-midnight", "relock-3am", "relock-5am"
        ])
    }

    static func scheduleAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let dayOffset = Calendar.current.component(.dayOfYear, from: .now)

        for dayAhead in 0..<14 {
            guard let futureDate = Calendar.current.date(byAdding: .day, value: dayAhead, to: .now) else { continue }

            let morningIndex = (dayOffset + dayAhead) % morningMessages.count
            let morningMsg = morningMessages[morningIndex]
            let morningContent = UNMutableNotificationContent()
            morningContent.title = morningMsg.title
            morningContent.body = morningMsg.body
            morningContent.sound = .default
            morningContent.interruptionLevel = .timeSensitive

            let reminderTime = savedReminderTime
            let timeComps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            var morningComps = Calendar.current.dateComponents([.year, .month, .day], from: futureDate)
            morningComps.hour = timeComps.hour
            morningComps.minute = timeComps.minute
            let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningComps, repeats: false)
            center.add(UNNotificationRequest(identifier: "morning-\(dayAhead)", content: morningContent, trigger: morningTrigger))

            let secondIndex = (dayOffset + dayAhead) % secondMessages.count
            let secondMsg = secondMessages[secondIndex]
            let secondContent = UNMutableNotificationContent()
            secondContent.title = secondMsg.title
            secondContent.body = secondMsg.body
            secondContent.sound = .default
            secondContent.interruptionLevel = .timeSensitive

            var secondComps = Calendar.current.dateComponents([.year, .month, .day], from: futureDate)
            let hours = [12, 17, 20]
            let hourIndex = (dayOffset + dayAhead) % hours.count
            secondComps.hour = hours[hourIndex]
            secondComps.minute = hourIndex == 0 ? 30 : 0
            let secondTrigger = UNCalendarNotificationTrigger(dateMatching: secondComps, repeats: false)
            center.add(UNNotificationRequest(identifier: "second-\(dayAhead)", content: secondContent, trigger: secondTrigger))
        }

        scheduleMidnightRelockNotifications()
    }

    static func cancelTodayNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["morning-0", "second-0"])
    }

    static func rescheduleAfterCompletion() {
        cancelTodayNotifications()
    }
}
