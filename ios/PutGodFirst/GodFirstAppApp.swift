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

        let st = ScreenTimeService.shared
        if (st.godFirstModeActive || st.godFirstModeEnrolled) && st.isAuthorized {
            st.scheduleAllMonitoring()
            NotificationService.scheduleMidnightRelockNotifications()
        }
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
        enforceMidnightBlockingOnLaunch()
        return true
    }

    private func enforceMidnightBlockingOnLaunch() {
        let st = ScreenTimeService.shared
        guard st.godFirstModeActive || st.godFirstModeEnrolled else { return }
        guard st.isAuthorized else { return }

        st.clearStaleData()
        if !st.checkHasCompletedToday() && !st.wasScriptureUnlockedToday() {
            st.blockApps()
        }
        st.scheduleAllMonitoring()
        NotificationService.scheduleMidnightRelockNotifications()
        BackgroundEnforcementService.scheduleAll()
    }
}

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    private func clearSharedPendingLink() {
        let shared = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")
        shared?.removeObject(forKey: "pendingShieldDeepLink")
        shared?.synchronize()
    }

    private func enforceBlockingFromNotification() {
        let screen = ScreenTimeService.shared
        if screen.godFirstModeEnrolled || screen.godFirstModeActive {
            screen.godFirstModeActive = true
            screen.clearStaleData()
            if !screen.checkHasCompletedToday() && !screen.wasScriptureUnlockedToday() {
                screen.blockApps()
            }
            screen.scheduleAllMonitoring()
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let categoryId = response.notification.request.content.categoryIdentifier
        let actionId = response.actionIdentifier

        let isDefaultTap = actionId == UNNotificationDefaultActionIdentifier

        let userInfo = response.notification.request.content.userInfo
        let isRelockTrigger = userInfo["relockTrigger"] as? Bool ?? false

        if isRelockTrigger {
            await MainActor.run {
                enforceBlockingFromNotification()
            }

            if let deepLink = userInfo["deepLink"] as? String, let url = URL(string: deepLink) {
                await MainActor.run {
                    if url.host == "start-session" {
                        DeepLinkManager.shared.pendingAction = .openSession
                    } else if url.host == "scripture-unlock" {
                        DeepLinkManager.shared.pendingAction = .scriptureUnlock
                    }
                }
            }
            return
        }

        clearSharedPendingLink()

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

            if isPostSession || actionId == "RECITE_SCRIPTURE" {
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

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        let isRelockTrigger = userInfo["relockTrigger"] as? Bool ?? false
        let isSilent = userInfo["silent"] as? Bool ?? false

        if isRelockTrigger && isSilent {
            await MainActor.run {
                let screen = ScreenTimeService.shared
                if screen.godFirstModeEnrolled || screen.godFirstModeActive {
                    screen.godFirstModeActive = true
                    screen.clearStaleData()
                    if !screen.checkHasCompletedToday() && !screen.wasScriptureUnlockedToday() {
                        screen.blockApps()
                    }
                    screen.scheduleAllMonitoring()
                }
            }
            return []
        }

        if isRelockTrigger {
            await MainActor.run {
                let screen = ScreenTimeService.shared
                if screen.godFirstModeEnrolled || screen.godFirstModeActive {
                    screen.godFirstModeActive = true
                    screen.clearStaleData()
                    if !screen.checkHasCompletedToday() && !screen.wasScriptureUnlockedToday() {
                        screen.blockApps()
                    }
                    screen.scheduleAllMonitoring()
                }
            }
        }

        return [.banner, .sound]
    }
}
