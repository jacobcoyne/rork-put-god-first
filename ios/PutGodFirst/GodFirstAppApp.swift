import SwiftUI
import UserNotifications

@main
struct GodFirstAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        SubscriptionService.shared.configure()
        registerNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([shieldCategory, openAppCategory, alarmCategory])
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
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

        if categoryId == "SHIELD_TAP" || categoryId == "OPEN_APP" {
            let isPostSession = userInfo["isPostSession"] as? Bool ?? false

            if isPostSession || actionId == "RECITE_SCRIPTURE" || (isDefaultTap && isPostSession) {
                await MainActor.run {
                    DeepLinkManager.shared.pendingAction = .scriptureUnlock
                }
            } else {
                await MainActor.run {
                    DeepLinkManager.shared.pendingAction = .openSession
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
