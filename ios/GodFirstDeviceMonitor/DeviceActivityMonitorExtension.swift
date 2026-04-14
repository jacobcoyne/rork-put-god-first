import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation
import UserNotifications

nonisolated class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let godFirstStore = ManagedSettingsStore(named: .init("godFirst"))
    private let timeLimitStore = ManagedSettingsStore(named: .init("godFirstScreenTimeLimit"))
    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private let screenTimeLimitActivity = "godFirst.screenTimeLimit"
    private let timeLimitReachedEvent = "godFirst.timeLimitReached"
    private let timeLimitWarningEvent = "godFirst.timeLimitWarning"

    nonisolated override func intervalDidStart(for activity: DeviceActivityName) {
        if activity.rawValue == screenTimeLimitActivity {
            return
        }
        reblockIfNeeded()
    }

    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        if activity.rawValue == screenTimeLimitActivity {
            return
        }
        reblockIfNeeded()
    }

    nonisolated override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        if activity.rawValue == screenTimeLimitActivity {
            if event.rawValue == timeLimitReachedEvent {
                lockTimeLimitApps()
                sendAppsLockedNotification()
            }
            return
        }
        reblockIfNeeded()
    }

    nonisolated override func intervalWillStartWarning(for activity: DeviceActivityName) {
        if activity.rawValue == screenTimeLimitActivity {
            return
        }
        reblockIfNeeded()
    }

    nonisolated override func intervalWillEndWarning(for activity: DeviceActivityName) {
        if activity.rawValue == screenTimeLimitActivity {
            return
        }
        reblockIfNeeded()
    }

    private func lockTimeLimitApps() {
        sharedDefaults?.synchronize()

        let alreadyUnlocked = wasTimeLimitUnlockedToday()
        guard !alreadyUnlocked else { return }

        guard let data = sharedDefaults?.data(forKey: "timeLimitActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }

        let apps = selection.applicationTokens
        let categories = selection.categoryTokens
        let webDomains = selection.webDomainTokens

        guard !apps.isEmpty || !categories.isEmpty else { return }

        timeLimitStore.shield.applications = apps.isEmpty ? nil : apps
        timeLimitStore.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        timeLimitStore.shield.webDomains = webDomains.isEmpty ? nil : webDomains

        sharedDefaults?.set(true, forKey: "isTimeLimitLocked")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "timeLimitLockTimestamp")
        sharedDefaults?.set(true, forKey: "isTimeLimitBlocking")
        sharedDefaults?.synchronize()
    }

    private func wasTimeLimitUnlockedToday() -> Bool {
        guard let ts = sharedDefaults?.double(forKey: "lastTimeLimitUnlockTimestamp"), ts > 0 else { return false }
        return Calendar.current.isDateInToday(Date(timeIntervalSince1970: ts))
    }

    private func sendAppsLockedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🛡️ Apps Locked"
        content.body = "You hit your screen time limit. Tap to open Put God First and unlock with a challenge."
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        content.userInfo = ["deepLink": "putgodfirst://time-limit-challenge"]

        let request = UNNotificationRequest(
            identifier: "screen-time-limit-locked",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func reblockIfNeeded() {
        sharedDefaults?.synchronize()

        let isEnrolled = sharedDefaults?.bool(forKey: "godFirstModeEnrolled") ?? false
        let isActive = sharedDefaults?.bool(forKey: "godFirstModeActive") ?? false

        guard isEnrolled || isActive else { return }

        if !checkHasCompletedToday() && !wasScriptureUnlockedToday() {
            applyBlocking()
        }
    }

    private func applyBlocking() {
        sharedDefaults?.synchronize()

        guard let data = sharedDefaults?.data(forKey: "familyActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }

        let apps = selection.applicationTokens
        let categories = selection.categoryTokens

        guard !apps.isEmpty || !categories.isEmpty else { return }

        godFirstStore.shield.applications = apps.isEmpty ? nil : apps
        godFirstStore.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)

        sharedDefaults?.set(true, forKey: "isCurrentlyBlocking")
        sharedDefaults?.synchronize()
    }

    private func checkHasCompletedToday() -> Bool {
        if let ts = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), ts > 0 {
            return Calendar.current.isDateInToday(Date(timeIntervalSince1970: ts))
        }
        return false
    }

    private func wasScriptureUnlockedToday() -> Bool {
        guard let ts = sharedDefaults?.double(forKey: "lastScriptureUnlockTimestamp"), ts > 0 else { return false }
        return Calendar.current.isDateInToday(Date(timeIntervalSince1970: ts))
    }
}
