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

    private func forceGodFirstModeOn() {
        sharedDefaults?.set(true, forKey: "godFirstModeActive")
        sharedDefaults?.set(true, forKey: "godFirstModeEnrolled")
        sharedDefaults?.synchronize()
    }

    private var hasCompletedToday: Bool {
        syncDefaults()
        guard let timestamp = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), timestamp > 0 else {
            return false
        }
        let lastCompleted = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(lastCompleted)
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

    private func forceNewDayReset() {
        forceGodFirstModeOn()
        sharedDefaults?.removeObject(forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.removeObject(forKey: "lastCompletedTimestamp")
        sharedDefaults?.set(false, forKey: "manualFocusLockActive")
        sharedDefaults?.synchronize()

        applyShields()
    }

    private func forceReblockIfNeeded() {
        forceGodFirstModeOn()
        clearStaleUnlockData()
        syncDefaults()
        if !hasCompletedToday && !wasScriptureUnlockedToday {
            applyShields()
        }
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

    private func forcePreMidnightLock() {
        forceGodFirstModeOn()
        sharedDefaults?.removeObject(forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.removeObject(forKey: "lastCompletedTimestamp")
        sharedDefaults?.synchronize()
        applyShields()
    }

    private func handleBlockingCheck(for activity: DeviceActivityName, isStart: Bool) {
        syncDefaults()

        if activity.rawValue == "godFirst.screenTimeLimit" {
            if isStart {
                handleScreenTimeLimitIntervalStart()
            }
            return
        }

        let isMidnight = activity.rawValue == "godFirst.midnightReblock"
        let isEarlyMorning = activity.rawValue == "godFirst.earlyMorningBackup"
        let isPreDawn = activity.rawValue == "godFirst.preDawnBackup"
        let isMorning = activity.rawValue == "godFirst.morningBackup"
        let isLateNight = activity.rawValue == "godFirst.lateNightPrep"
        let isPreMidnight = activity.rawValue == "godFirst.preMidnightLock"

        let shouldForceOn = isGodFirstModeActive || isGodFirstModeEnrolled || hasAppsSelected

        if isPreMidnight && isStart {
            guard shouldForceOn else { return }
            forcePreMidnightLock()
            return
        }

        if isMidnight && isStart {
            guard shouldForceOn else { return }
            forceNewDayReset()
            clearTimeLimitDataForNewDay()
            return
        }

        if (isEarlyMorning || isPreDawn || isMorning) && isStart {
            guard shouldForceOn else { return }
            forceReblockIfNeeded()
            return
        }

        if isLateNight && isStart {
            guard shouldForceOn else { return }
            forceGodFirstModeOn()
            if !hasCompletedToday && !wasScriptureUnlockedToday {
                applyShields()
            }
            return
        }

        guard isGodFirstModeActive || isGodFirstModeEnrolled else { return }

        if wasScriptureUnlockedToday { return }

        if !hasCompletedToday {
            applyShields()
        }
    }

    private func handleScreenTimeLimitIntervalStart() {
        syncDefaults()
        let isEnabled = sharedDefaults?.bool(forKey: "screenTimeLimitEnabled") == true
        guard isEnabled else { return }
        guard !wasTimeLimitUnlockedToday else { return }

        let alreadyLocked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") == true
        if alreadyLocked {
            if let ts = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), ts > 0 {
                let d = Date(timeIntervalSince1970: ts)
                if Calendar.current.isDateInToday(d) {
                    applyTimeLimitShields()
                    return
                }
            }
        }

        restartTimeLimitMonitoringForNewDay()
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        handleBlockingCheck(for: activity, isStart: true)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        syncDefaults()

        let isLateNight = activity.rawValue == "godFirst.lateNightPrep"
        let isPreMidnight = activity.rawValue == "godFirst.preMidnightLock"
        let shouldForceOn = isGodFirstModeActive || isGodFirstModeEnrolled || hasAppsSelected

        if activity.rawValue == "godFirst.screenTimeLimit" {
            return
        }

        if (isLateNight || isPreMidnight) && shouldForceOn {
            forcePreMidnightLock()
            return
        }

        guard isGodFirstModeActive || isGodFirstModeEnrolled else { return }

        if wasScriptureUnlockedToday { return }

        if !hasCompletedToday {
            applyShields()
        }
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        syncDefaults()

        if activity.rawValue == "godFirst.screenTimeLimit" {
            return
        }

        guard isGodFirstModeActive || isGodFirstModeEnrolled else { return }
        if wasScriptureUnlockedToday { return }

        if !hasCompletedToday {
            applyShields()
        }
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        syncDefaults()

        if activity.rawValue == "godFirst.screenTimeLimit" {
            return
        }

        guard isGodFirstModeActive || isGodFirstModeEnrolled else { return }
        if wasScriptureUnlockedToday { return }

        if !hasCompletedToday {
            applyShields()
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        syncDefaults()

        if activity.rawValue == "godFirst.screenTimeLimit" && event.rawValue == "godFirst.timeLimitReached" {
            let isEnabled = sharedDefaults?.bool(forKey: "screenTimeLimitEnabled") == true
            guard isEnabled else { return }

            guard !wasTimeLimitUnlockedToday else { return }

            applyTimeLimitShields()
        }
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
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
        guard let data = sharedDefaults?.data(forKey: "timeLimitActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return nil
        }
        return selection
    }

    private func applyTimeLimitShields() {
        guard let selection = loadTimeLimitSelection() else { return }
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

        sendTimeLimitNotification()
    }

    private func clearTimeLimitDataForNewDay() {
        sharedDefaults?.set(false, forKey: "isTimeLimitLocked")
        sharedDefaults?.set(false, forKey: "isTimeLimitBlocking")
        sharedDefaults?.removeObject(forKey: "lastTimeLimitUnlockTimestamp")
        sharedDefaults?.removeObject(forKey: "timeLimitLockTimestamp")
        sharedDefaults?.synchronize()
        timeLimitStore.shield.applications = nil
        timeLimitStore.shield.applicationCategories = nil
        timeLimitStore.shield.webDomains = nil
        restartTimeLimitMonitoringForNewDay()
    }

    private func restartTimeLimitMonitoringForNewDay() {
        syncDefaults()
        let isEnabled = sharedDefaults?.bool(forKey: "screenTimeLimitEnabled") == true
        guard isEnabled else { return }

        guard let selection = loadTimeLimitSelection() else { return }
        guard !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty else { return }

        let minutes = sharedDefaults?.integer(forKey: "screenTimeLimitMinutes") ?? 30
        guard minutes > 0 else { return }

        let center = DeviceActivityCenter()
        let activityName = DeviceActivityName("godFirst.screenTimeLimit")
        center.stopMonitoring([activityName])

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true,
            warningTime: nil
        )

        let eventName = DeviceActivityEvent.Name("godFirst.timeLimitReached")
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: minutes)
        )

        try? center.startMonitoring(
            activityName,
            during: schedule,
            events: [eventName: event]
        )
    }

    private func sendTimeLimitNotification() {
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
            identifier: "godFirst.timeLimit.locked",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
