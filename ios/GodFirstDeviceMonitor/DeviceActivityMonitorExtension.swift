import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore(named: .init("godFirst"))
    let timeLimitStore = ManagedSettingsStore(named: .init("godFirstScreenTimeLimit"))
    let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private var isGodFirstModeActive: Bool {
        sharedDefaults?.synchronize()
        return sharedDefaults?.bool(forKey: "godFirstModeActive") == true
    }

    private var isGodFirstModeEnrolled: Bool {
        sharedDefaults?.synchronize()
        return sharedDefaults?.bool(forKey: "godFirstModeEnrolled") == true
    }

    private func forceGodFirstModeOn() {
        sharedDefaults?.set(true, forKey: "godFirstModeActive")
        sharedDefaults?.synchronize()
    }

    private var hasCompletedToday: Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), timestamp > 0 else {
            return false
        }
        let lastCompleted = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(lastCompleted)
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

    private var wasScriptureUnlockedToday: Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastScriptureUnlockTimestamp"), timestamp > 0 else {
            return false
        }
        let unlockDate = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(unlockDate)
    }

    private var hasAppsSelected: Bool {
        sharedDefaults?.synchronize()
        guard let data = sharedDefaults?.data(forKey: "familyActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return false
        }
        return !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }

    private func forceNewDayReset() {
        forceGodFirstModeOn()
        sharedDefaults?.set(true, forKey: "godFirstModeEnrolled")
        sharedDefaults?.removeObject(forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.removeObject(forKey: "lastCompletedTimestamp")
        sharedDefaults?.set(false, forKey: "manualFocusLockActive")
        sharedDefaults?.set(false, forKey: "isCurrentlyBlocking")
        sharedDefaults?.synchronize()
        applyShields()
    }

    private func forceReblockIfNeeded() {
        forceGodFirstModeOn()
        sharedDefaults?.set(true, forKey: "godFirstModeEnrolled")
        clearStaleUnlockData()
        sharedDefaults?.synchronize()
        if !hasCompletedToday && !wasScriptureUnlockedToday {
            applyShields()
        }
    }

    private func clearStaleUnlockData() {
        sharedDefaults?.synchronize()
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
        sharedDefaults?.set(true, forKey: "godFirstModeEnrolled")
        sharedDefaults?.synchronize()
        applyShields()
    }

    private var isScreenTimeLimitActivity: Bool {
        false
    }

    private func handleBlockingCheck(for activity: DeviceActivityName, isStart: Bool) {
        sharedDefaults?.synchronize()

        if activity.rawValue == "godFirst.screenTimeLimit" {
            return
        }

        let isMidnight = activity.rawValue == "godFirst.midnightReblock"
        let isEarlyMorning = activity.rawValue == "godFirst.earlyMorningBackup"
        let isPreDawn = activity.rawValue == "godFirst.preDawnBackup"
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

        if isEarlyMorning && isStart {
            guard shouldForceOn else { return }
            forceReblockIfNeeded()
            return
        }

        if isPreDawn && isStart {
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

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        handleBlockingCheck(for: activity, isStart: true)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        sharedDefaults?.synchronize()

        let isLateNight = activity.rawValue == "godFirst.lateNightPrep"
        let isPreMidnight = activity.rawValue == "godFirst.preMidnightLock"
        let shouldForceOn = isGodFirstModeActive || isGodFirstModeEnrolled || hasAppsSelected

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
        sharedDefaults?.synchronize()
        guard isGodFirstModeActive || isGodFirstModeEnrolled else { return }
        if wasScriptureUnlockedToday { return }

        if !hasCompletedToday {
            applyShields()
        }
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        sharedDefaults?.synchronize()
        guard isGodFirstModeActive || isGodFirstModeEnrolled else { return }
        if wasScriptureUnlockedToday { return }

        if !hasCompletedToday {
            applyShields()
        }
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        sharedDefaults?.synchronize()

        if activity.rawValue == "godFirst.screenTimeLimit" && event.rawValue == "godFirst.timeLimitReached" {
            let isEnabled = sharedDefaults?.bool(forKey: "screenTimeLimitEnabled") == true
            guard isEnabled else { return }

            let alreadyUnlocked = wasTimeLimitUnlockedToday
            guard !alreadyUnlocked else { return }

            let alreadyLocked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") == true
            if let ts = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), ts > 0 {
                let d = Date(timeIntervalSince1970: ts)
                if Calendar.current.isDateInToday(d) && alreadyLocked {
                    applyTimeLimitShields()
                    return
                }
            }

            applyTimeLimitShields()
        }
    }

    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        sharedDefaults?.synchronize()

        if activity.rawValue == "godFirst.screenTimeLimit" && event.rawValue == "godFirst.timeLimitReached" {
            let isEnabled = sharedDefaults?.bool(forKey: "screenTimeLimitEnabled") == true
            guard isEnabled else { return }
            guard !wasTimeLimitUnlockedToday else { return }

            sendTimeLimitWarningNotification()
        }
    }

    private var wasTimeLimitUnlockedToday: Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastTimeLimitUnlockTimestamp"), timestamp > 0 else {
            return false
        }
        let unlockDate = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(unlockDate)
    }

    private func loadTimeLimitSelection() -> (Set<ApplicationToken>, Set<ActivityCategoryToken>)? {
        sharedDefaults?.synchronize()
        guard let data = sharedDefaults?.data(forKey: "timeLimitActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return nil
        }
        return (selection.applicationTokens, selection.categoryTokens)
    }

    private func applyTimeLimitShields() {
        guard let (apps, categories) = loadTimeLimitSelection() else { return }
        guard !apps.isEmpty || !categories.isEmpty else { return }

        if !apps.isEmpty {
            timeLimitStore.shield.applications = apps
        }
        if !categories.isEmpty {
            timeLimitStore.shield.applicationCategories = .specific(categories)
        }

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
        timeLimitStore.clearAllSettings()
        restartTimeLimitMonitoringForNewDay()
    }

    private func restartTimeLimitMonitoringForNewDay() {
        sharedDefaults?.synchronize()
        let isEnabled = sharedDefaults?.bool(forKey: "screenTimeLimitEnabled") == true
        guard isEnabled else { return }

        guard let data = sharedDefaults?.data(forKey: "timeLimitActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }
        guard !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty else { return }

        let minutes = sharedDefaults?.integer(forKey: "screenTimeLimitMinutes") ?? 30
        guard minutes > 0 else { return }

        let center = DeviceActivityCenter()
        let activityName = DeviceActivityName("godFirst.screenTimeLimit")
        center.stopMonitoring([activityName])

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: DateComponents(minute: 1)
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
        content.title = "Screen Time Limit Reached \u{23F0}"
        content.body = "You\u{2019}ve hit your daily limit. Complete a challenge to unlock!"
        content.sound = .default
        content.categoryIdentifier = "SCREEN_TIME_LIMIT"
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0
        content.userInfo = [
            "deepLink": "putgodfirst://time-limit-unlock",
            "isTimeLimitChallenge": true
        ]

        let request = UNNotificationRequest(
            identifier: "godFirst.timeLimit.\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func sendTimeLimitWarningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Almost at your limit \u{26A0}\u{FE0F}"
        content.body = "You\u{2019}re about to hit your daily screen time limit. Wrap it up!"
        content.sound = .default
        content.interruptionLevel = .active

        let request = UNNotificationRequest(
            identifier: "godFirst.timeLimitWarning.\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
