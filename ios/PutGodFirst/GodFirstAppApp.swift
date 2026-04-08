import SwiftUI
import UserNotifications
import BackgroundTasks

@main
struct GodFirstAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        SubscriptionService.shared.configure()
        registerNotificationCategories()
        BackgroundEnforcementService.registerTasks()
        BackgroundEnforcementService.scheduleAll()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "putgodfirst" else { return }
        switch url.host {
        case "scripture-unlock":
            DeepLinkManager.shared.pendingAction = .scriptureUnlock
        case "start-session":
            DeepLinkManager.shared.pendingAction = .openSession
        case "time-limit-unlock":
            DeepLinkManager.shared.pendingAction = .timeLimitUnlock
        default:
            break
        }
    }

    private func registerNotificationCategories() {
        let scriptureAction = UNNotificationAction(
            identifier: "RECITE_SCRIPTURE",
            title: "Recite Scripture to Unlock",
            options: [.foreground]
        )
        let openAction = UNNotificationAction(
            identifier: "OPEN_APP_ACTION",
            title: "Open App",
            options: [.foreground]
        )
        let shieldCategory = UNNotificationCategory(
            identifier: "SHIELD_TAP",
            actions: [scriptureAction, openAction],
            intentIdentifiers: [],
            options: []
        )
        let openAppCategory = UNNotificationCategory(
            identifier: "OPEN_APP",
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )
        let alarmOpenAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open Bible",
            options: [.foreground]
        )
        let alarmCategory = UNNotificationCategory(
            identifier: "BIBLE_ALARM",
            actions: [alarmOpenAction],
            intentIdentifiers: [],
            options: []
        )
        let challengeAction = UNNotificationAction(
            identifier: "TAKE_CHALLENGE",
            title: "Take the Challenge",
            options: [.foreground]
        )
        let timeLimitCategory = UNNotificationCategory(
            identifier: "SCREEN_TIME_LIMIT",
            actions: [challengeAction],
            intentIdentifiers: [],
            options: []
        )
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([shieldCategory, openAppCategory, alarmCategory, timeLimitCategory])
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        scheduleMidnightLocalNotifications()
        return true
    }

    private func scheduleMidnightLocalNotifications() {
        let st = ScreenTimeService.shared
        guard st.godFirstModeActive || st.godFirstModeEnrolled else { return }

        let center = UNUserNotificationCenter.current()
        var idsToRemove: [String] = []
        for i in 0..<7 {
            idsToRemove.append("midnight-relock-\(i)")
            idsToRemove.append("pre-midnight-relock-\(i)")
            idsToRemove.append("early-morning-relock-\(i)")
            idsToRemove.append("morning-locked-\(i)")
        }
        center.removePendingNotificationRequests(withIdentifiers: idsToRemove)

        for dayOffset in 0..<7 {
            func addSilentRelock(hour: Int, minute: Int, id: String) {
                let content = UNMutableNotificationContent()
                content.title = "Put God First 🙏"
                content.body = "Your apps are locked. Start your morning with God."
                content.sound = nil
                content.interruptionLevel = .passive
                content.userInfo = ["relockTrigger": true, "silent": true]

                var comps = DateComponents()
                comps.hour = hour
                comps.minute = minute
                if dayOffset > 0 {
                    if let future = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
                        let futureComps = Calendar.current.dateComponents([.year, .month, .day], from: future)
                        comps.year = futureComps.year
                        comps.month = futureComps.month
                        comps.day = futureComps.day
                    }
                }
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: dayOffset == 0)
                center.add(UNNotificationRequest(identifier: "\(id)-\(dayOffset)", content: content, trigger: trigger))
            }

            addSilentRelock(hour: 23, minute: 55, id: "pre-midnight-relock")
            addSilentRelock(hour: 0, minute: 1, id: "midnight-relock")
            addSilentRelock(hour: 4, minute: 0, id: "early-morning-relock")

            let lockedContent = UNMutableNotificationContent()
            lockedContent.title = "Your Apps Are Locked 🔒"
            lockedContent.body = "Open Put God First and complete your morning session to unlock your apps."
            lockedContent.sound = .default
            lockedContent.interruptionLevel = .timeSensitive
            lockedContent.categoryIdentifier = "OPEN_APP"
            lockedContent.userInfo = ["deepLink": "putgodfirst://start-session"]

            let reminderTime = NotificationService.savedReminderTime
            let timeComps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            var lockedComps = DateComponents()
            lockedComps.hour = timeComps.hour
            lockedComps.minute = timeComps.minute
            if dayOffset > 0 {
                if let future = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
                    let futureComps = Calendar.current.dateComponents([.year, .month, .day], from: future)
                    lockedComps.year = futureComps.year
                    lockedComps.month = futureComps.month
                    lockedComps.day = futureComps.day
                }
            }

            let lockedTrigger = UNCalendarNotificationTrigger(dateMatching: lockedComps, repeats: dayOffset == 0)
            center.add(UNNotificationRequest(
                identifier: "morning-locked-\(dayOffset)",
                content: lockedContent,
                trigger: lockedTrigger
            ))
        }
    }
}

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let categoryId = response.notification.request.content.categoryIdentifier
        let actionId = response.actionIdentifier

        let isDefaultTap = actionId == UNNotificationDefaultActionIdentifier

        let userInfo = response.notification.request.content.userInfo
        let isRelockTrigger = userInfo["relockTrigger"] as? Bool ?? false

        if isRelockTrigger {
            await MainActor.run {
                let screen = ScreenTimeService.shared
                if screen.godFirstModeEnrolled || screen.godFirstModeActive {
                    screen.godFirstModeActive = true
                    if !screen.checkHasCompletedToday() && !screen.wasScriptureUnlockedToday() {
                        screen.blockApps()
                    }
                }
            }
            return
        }

        if let deepLink = userInfo["deepLink"] as? String, let url = URL(string: deepLink) {
            await MainActor.run {
                if url.host == "scripture-unlock" {
                    DeepLinkManager.shared.pendingAction = .scriptureUnlock
                } else if url.host == "start-session" {
                    DeepLinkManager.shared.pendingAction = .openSession
                } else if url.host == "time-limit-unlock" {
                    DeepLinkManager.shared.pendingAction = .timeLimitUnlock
                } else {
                    UIApplication.shared.open(url)
                }
            }
            return
        }

        if categoryId == "SCREEN_TIME_LIMIT" || (userInfo["isTimeLimitChallenge"] as? Bool == true) {
            await MainActor.run {
                DeepLinkManager.shared.pendingAction = .timeLimitUnlock
            }
            return
        }

        if categoryId == "SHIELD_TAP" || categoryId == "OPEN_APP" {
            let isPostSession = userInfo["isPostSession"] as? Bool ?? false

            if isPostSession || actionId == "RECITE_SCRIPTURE" || (isDefaultTap && categoryId == "SHIELD_TAP") {
                await MainActor.run {
                    DeepLinkManager.shared.pendingAction = .scriptureUnlock
                }
            } else {
                await MainActor.run {
                    DeepLinkManager.shared.pendingAction = .openSession
                }
            }
            return
        }

        if isDefaultTap {
            await MainActor.run {
                DeepLinkManager.shared.pendingAction = .openSession
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
