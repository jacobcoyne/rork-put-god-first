import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore(named: .init("godFirst"))
    let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private var isGodFirstModeEnrolled: Bool {
        sharedDefaults?.synchronize()
        return sharedDefaults?.bool(forKey: "godFirstModeEnrolled") == true
    }

    private var isGodFirstModeActive: Bool {
        sharedDefaults?.synchronize()
        return sharedDefaults?.bool(forKey: "godFirstModeActive") == true
    }

    private var hasCompletedToday: Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), timestamp > 0 else {
            return false
        }
        let lastCompleted = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(lastCompleted)
    }

    private var hasAppsSelected: Bool {
        guard let selection = loadSelection() else { return false }
        return !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }

    private func loadSelection() -> FamilyActivitySelection? {
        sharedDefaults?.synchronize()
        guard let data = sharedDefaults?.data(forKey: "familyActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return nil
        }
        return selection
    }

    private func applyShields() {
        guard let selection = loadSelection() else { return }

        let apps = selection.applicationTokens
        let categories = selection.categoryTokens

        guard !apps.isEmpty || !categories.isEmpty else { return }

        if !apps.isEmpty {
            store.shield.applications = apps
        }
        if !categories.isEmpty {
            store.shield.applicationCategories = .specific(categories)
        }
        sharedDefaults?.set(true, forKey: "isCurrentlyBlocking")
        sharedDefaults?.synchronize()
    }

    private func isNewDaySinceLastReset() -> Bool {
        sharedDefaults?.synchronize()
        let lastResetTimestamp = sharedDefaults?.double(forKey: "lastMidnightResetTimestamp") ?? 0
        if lastResetTimestamp == 0 { return true }
        let lastReset = Date(timeIntervalSince1970: lastResetTimestamp)
        return !Calendar.current.isDateInToday(lastReset)
    }

    private func performNewDayReset() {
        sharedDefaults?.synchronize()

        sharedDefaults?.set(true, forKey: "godFirstModeActive")
        sharedDefaults?.set(true, forKey: "godFirstModeEnrolled")
        sharedDefaults?.removeObject(forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.removeObject(forKey: "lastCompletedTimestamp")
        sharedDefaults?.set(false, forKey: "manualFocusLockActive")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "lastMidnightResetTimestamp")
        sharedDefaults?.synchronize()

        applyShields()

        sendMorningNotification()
    }

    private func enforceBlocking() {
        sharedDefaults?.synchronize()

        guard isGodFirstModeEnrolled || isGodFirstModeActive || hasAppsSelected else { return }

        if isNewDaySinceLastReset() {
            performNewDayReset()
            return
        }

        if !hasCompletedToday {
            sharedDefaults?.set(true, forKey: "godFirstModeActive")
            sharedDefaults?.synchronize()
            applyShields()
        }
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        enforceBlocking()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        enforceBlocking()
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        enforceBlocking()
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        enforceBlocking()
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        enforceBlocking()
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        enforceBlocking()
    }

    private func sendMorningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Put God First \u{2728}"
        content.body = "Good morning! Your apps are locked. Complete your daily session to unlock them."
        content.sound = .default
        content.categoryIdentifier = "OPEN_APP"
        content.interruptionLevel = .timeSensitive
        content.userInfo = ["relockTrigger": true]

        let request = UNNotificationRequest(
            identifier: "godFirst.morningBlock.\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
