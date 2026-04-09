import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore(named: .init("godFirst"))
    let timeLimitStore = ManagedSettingsStore(named: .init("godFirstScreenTimeLimit"))
    let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private func syncDefaults() {
        sharedDefaults?.synchronize()
    }

    private var isGodFirstModeActive: Bool {
        syncDefaults()
        return sharedDefaults?.bool(forKey: "godFirstModeActive") == true
    }

    private var isGodFirstModeEnrolled: Bool {
        syncDefaults()
        return sharedDefaults?.bool(forKey: "godFirstModeEnrolled") == true
    }

    private var shouldEnforce: Bool {
        isGodFirstModeActive || isGodFirstModeEnrolled || hasAppsSelected
    }

    private func forceGodFirstModeOn() {
        sharedDefaults?.set(true, forKey: "godFirstModeActive")
        sharedDefaults?.set(true, forKey: "godFirstModeEnrolled")
        sharedDefaults?.synchronize()
    }

    private var hasCompletedToday: Bool {
        syncDefaults()
        if let timestamp = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), timestamp > 0 {
            let lastCompleted = Date(timeIntervalSince1970: timestamp)
            if Calendar.current.isDateInToday(lastCompleted) {
                return true
            }
        }
        return false
    }

    private var wasScriptureUnlockedToday: Bool {
        syncDefaults()
        guard let timestamp = sharedDefaults?.double(forKey: "lastScriptureUnlockTimestamp"), timestamp > 0 else {
            return false
        }
        let unlockDate = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(unlockDate)
    }

    private var hasAppsSelected: Bool {
        syncDefaults()
        guard let data = sharedDefaults?.data(forKey: "familyActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return false
        }
        return !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }

    private func loadSelection() -> FamilyActivitySelection? {
        syncDefaults()
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

        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)

        sharedDefaults?.set(true, forKey: "isCurrentlyBlocking")
        sharedDefaults?.synchronize()
    }

    private func clearStaleUnlockData() {
        syncDefaults()
        if let ts = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), ts > 0 {
            let d = Date(timeIntervalSince1970: ts)
            if !Calendar.current.isDateInToday(d) {
                sharedDefaults?.removeObject(forKey: "lastCompletedTimestamp")
            }
        }
        if let ts = sharedDefaults?.double(forKey: "lastScriptureUnlockTimestamp"), ts > 0 {
            let d = Date(timeIntervalSince1970: ts)
            if !Calendar.current.isDateInToday(d) {
                sharedDefaults?.removeObject(forKey: "lastScriptureUnlockTimestamp")
            }
        }
        sharedDefaults?.synchronize()
    }

    private func forceNewDayReset() {
        forceGodFirstModeOn()
        sharedDefaults?.removeObject(forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.removeObject(forKey: "lastCompletedTimestamp")
        sharedDefaults?.set(false, forKey: "manualFocusLockActive")
        sharedDefaults?.synchronize()
        applyShields()
    }

    private func alwaysEnforceBlocking() {
        clearStaleUnlockData()
        syncDefaults()

        let enrolled = isGodFirstModeEnrolled
        let active = isGodFirstModeActive
        let hasApps = hasAppsSelected

        if enrolled || active || hasApps {
            forceGodFirstModeOn()
            if !hasCompletedToday && !wasScriptureUnlockedToday {
                applyShields()
            }
        }
    }

    private func isScreenTimeLimitActivity(_ activity: DeviceActivityName) -> Bool {
        activity.rawValue == "godFirst.screenTimeLimit"
    }

    private func isPreMidnightActivity(_ activity: DeviceActivityName) -> Bool {
        let name = activity.rawValue
        return name == "godFirst.preMidnightLock" || name == "godFirst.lateNightPrep"
    }

    private func isMidnightActivity(_ activity: DeviceActivityName) -> Bool {
        activity.rawValue == "godFirst.midnightReblock"
    }

    private func isEveningActivity(_ activity: DeviceActivityName) -> Bool {
        let name = activity.rawValue
        return name == "godFirst.eveningEnforce" || name == "godFirst.nightEnforce"
    }

    private func isEarlyMorningActivity(_ activity: DeviceActivityName) -> Bool {
        let name = activity.rawValue
        return name == "godFirst.postMidnightBackup"
            || name == "godFirst.earlyMorningBackup"
            || name == "godFirst.preDawnBackup"
            || name == "godFirst.dawnBackup"
            || name == "godFirst.morningBackup"
            || name == "godFirst.lateMorningBackup"
            || name == "godFirst.middayBackup"
            || name == "godFirst.afternoonBackup"
            || name == "godFirst.lateAfternoonBackup"
    }

    // MARK: - DeviceActivityMonitor Callbacks

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        syncDefaults()

        if isScreenTimeLimitActivity(activity) {
            handleScreenTimeLimitIntervalStart()
            return
        }

        if isMidnightActivity(activity) {
            forceNewDayReset()
            clearTimeLimitDataForNewDay()
            return
        }

        if isPreMidnightActivity(activity) {
            forceNewDayReset()
            return
        }

        if isEarlyMorningActivity(activity) {
            forceNewDayReset()
            return
        }

        alwaysEnforceBlocking()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        syncDefaults()

        if isScreenTimeLimitActivity(activity) { return }

        if isMidnightActivity(activity) || isPreMidnightActivity(activity) || isEarlyMorningActivity(activity) {
            forceNewDayReset()
            return
        }

        alwaysEnforceBlocking()
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        syncDefaults()
        if isScreenTimeLimitActivity(activity) { return }
        alwaysEnforceBlocking()
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        syncDefaults()
        if isScreenTimeLimitActivity(activity) { return }

        if isPreMidnightActivity(activity) {
            forceNewDayReset()
            return
        }

        alwaysEnforceBlocking()
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        syncDefaults()

        if isScreenTimeLimitActivity(activity) {
            sharedDefaults?.set("eventDidReachThreshold fired: \(event.rawValue) at \(Date())", forKey: "screenTimeLimitLastEvent")
            sharedDefaults?.synchronize()

            guard !wasTimeLimitUnlockedToday else { return }
            applyTimeLimitShields()
        }
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        syncDefaults()

        if isScreenTimeLimitActivity(activity) {
            sharedDefaults?.set("eventWillReachThresholdWarning fired: \(event.rawValue) at \(Date())", forKey: "screenTimeLimitLastWarningEvent")
            sharedDefaults?.synchronize()

            guard !wasTimeLimitUnlockedToday else { return }
            applyTimeLimitShields()
        }
    }

    // MARK: - Screen Time Limit

    private func handleScreenTimeLimitIntervalStart() {
        syncDefaults()
        let isEnabled = sharedDefaults?.bool(forKey: "screenTimeLimitEnabled") == true
        guard isEnabled else { return }

        sharedDefaults?.set("intervalDidStart at \(Date())", forKey: "screenTimeLimitIntervalEvent")
        sharedDefaults?.synchronize()

        clearTimeLimitDataForNewDay()

        let alreadyLocked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") == true
        if alreadyLocked {
            if let ts = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), ts > 0 {
                let d = Date(timeIntervalSince1970: ts)
                if Calendar.current.isDateInToday(d) && !wasTimeLimitUnlockedToday {
                    applyTimeLimitShields()
                }
            }
        }
    }

    private var wasTimeLimitUnlockedToday: Bool {
        syncDefaults()
        guard let timestamp = sharedDefaults?.double(forKey: "lastTimeLimitUnlockTimestamp"), timestamp > 0 else {
            return false
        }
        let unlockDate = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(unlockDate)
    }

    private func loadTimeLimitSelection() -> FamilyActivitySelection? {
        syncDefaults()
        if let data = sharedDefaults?.data(forKey: "timeLimitActivitySelection"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data),
           !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty {
            return selection
        }
        if let data = sharedDefaults?.data(forKey: "familyActivitySelection"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data),
           !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty {
            return selection
        }
        return nil
    }

    private func applyTimeLimitShields() {
        syncDefaults()
        guard let selection = loadTimeLimitSelection() else {
            sharedDefaults?.set("applyTimeLimitShields: no selection found", forKey: "screenTimeLimitShieldError")
            sharedDefaults?.synchronize()
            return
        }
        let apps = selection.applicationTokens
        let categories = selection.categoryTokens
        let webDomains = selection.webDomainTokens

        guard !apps.isEmpty || !categories.isEmpty else {
            sharedDefaults?.set("applyTimeLimitShields: empty tokens", forKey: "screenTimeLimitShieldError")
            sharedDefaults?.synchronize()
            return
        }

        let alreadyLocked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") == true

        timeLimitStore.shield.applications = apps.isEmpty ? nil : apps
        timeLimitStore.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        timeLimitStore.shield.webDomains = webDomains.isEmpty ? nil : webDomains

        sharedDefaults?.set(true, forKey: "isTimeLimitLocked")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "timeLimitLockTimestamp")
        sharedDefaults?.set(true, forKey: "isTimeLimitBlocking")
        sharedDefaults?.set("shields applied at \(Date())", forKey: "screenTimeLimitShieldStatus")
        sharedDefaults?.synchronize()

        if !alreadyLocked {
            sendTimeLimitNotification()
        }
    }

    private func clearTimeLimitDataForNewDay() {
        syncDefaults()
        if let ts = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), ts > 0 {
            let d = Date(timeIntervalSince1970: ts)
            if !Calendar.current.isDateInToday(d) {
                sharedDefaults?.set(false, forKey: "isTimeLimitLocked")
                sharedDefaults?.set(false, forKey: "isTimeLimitBlocking")
                sharedDefaults?.removeObject(forKey: "lastTimeLimitUnlockTimestamp")
                sharedDefaults?.removeObject(forKey: "timeLimitLockTimestamp")
                sharedDefaults?.synchronize()
                timeLimitStore.shield.applications = nil
                timeLimitStore.shield.applicationCategories = nil
                timeLimitStore.shield.webDomains = nil
            }
        }
    }

    private func shouldThrottleNotification(key: String) -> Bool {
        syncDefaults()
        let lastSentKey = "lastNotifTime_\(key)"
        let lastSent = sharedDefaults?.double(forKey: lastSentKey) ?? 0
        let now = Date().timeIntervalSince1970
        if now - lastSent < 3600 {
            return true
        }
        sharedDefaults?.set(now, forKey: lastSentKey)
        sharedDefaults?.synchronize()
        return false
    }

    private func sendTimeLimitNotification() {
        guard !shouldThrottleNotification(key: "timeLimitMonitor") else { return }

        let content = UNMutableNotificationContent()
        content.title = "Screen Time Limit Reached"
        content.body = "Your apps are now locked. Complete a challenge to unlock."
        content.sound = .default
        content.categoryIdentifier = "SCREEN_TIME_LIMIT"
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0
        content.userInfo = [
            "deepLink": "putgodfirst://time-limit-unlock",
            "isTimeLimitChallenge": true
        ]

        let request = UNNotificationRequest(
            identifier: "godFirst.timeLimit.locked.\(Int(Date().timeIntervalSince1970))",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
