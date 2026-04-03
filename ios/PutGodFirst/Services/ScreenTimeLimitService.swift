import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

nonisolated extension DeviceActivityName {
    static let screenTimeLimit = Self("godFirst.screenTimeLimit")
}

nonisolated extension DeviceActivityEvent.Name {
    static let timeLimitReached = Self("godFirst.timeLimitReached")
}

nonisolated extension ManagedSettingsStore.Name {
    static let screenTimeLimit = Self("godFirstScreenTimeLimit")
}

@Observable
final class ScreenTimeLimitService {
    static let shared = ScreenTimeLimitService()

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            UserDefaults.standard.set(isEnabled, forKey: "screenTimeLimitEnabled")
            sharedDefaults?.set(isEnabled, forKey: "screenTimeLimitEnabled")
            sharedDefaults?.synchronize()
            if !isEnabled {
                stopMonitoring()
                unlockTimeLimitedApps()
            }
        }
    }

    var dailyLimitMinutes: Int {
        didSet {
            guard dailyLimitMinutes != oldValue else { return }
            UserDefaults.standard.set(dailyLimitMinutes, forKey: "screenTimeLimitMinutes")
            sharedDefaults?.set(dailyLimitMinutes, forKey: "screenTimeLimitMinutes")
            sharedDefaults?.synchronize()
        }
    }

    var timeLimitSelection: FamilyActivitySelection {
        didSet {
            saveTimeLimitSelection()
        }
    }

    var isTimeLimitLocked: Bool {
        get {
            sharedDefaults?.synchronize()
            let locked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") ?? false
            let isToday = isTimeLimitLockFromToday()
            return locked && isToday
        }
        set {
            sharedDefaults?.set(newValue, forKey: "isTimeLimitLocked")
            if newValue {
                sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "timeLimitLockTimestamp")
            }
            sharedDefaults?.synchronize()
            UserDefaults.standard.set(newValue, forKey: "isTimeLimitLocked")
        }
    }

    private let store = ManagedSettingsStore(named: .screenTimeLimit)
    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")
    private var isMonitoringActive: Bool = false

    var hasTimeLimitAppsSelected: Bool {
        !timeLimitSelection.applicationTokens.isEmpty || !timeLimitSelection.categoryTokens.isEmpty
    }

    private init() {
        let shared = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")
        shared?.synchronize()

        self.isEnabled = UserDefaults.standard.bool(forKey: "screenTimeLimitEnabled")
        let savedMinutes = max(UserDefaults.standard.integer(forKey: "screenTimeLimitMinutes"), 0)
        self.dailyLimitMinutes = savedMinutes == 0 ? 30 : savedMinutes

        if let data = UserDefaults.standard.data(forKey: "timeLimitActivitySelection"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.timeLimitSelection = selection
        } else if let data = shared?.data(forKey: "timeLimitActivitySelection"),
                  let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.timeLimitSelection = selection
        } else {
            self.timeLimitSelection = FamilyActivitySelection()
        }

        if isEnabled && hasTimeLimitAppsSelected {
            clearStaleLockData()
            ensureMonitoringActive()
        }
    }

    func applySettingsAndStartMonitoring(selection: FamilyActivitySelection, minutes: Int, enabled: Bool) {
        let selectionChanged = selection.applicationTokens != timeLimitSelection.applicationTokens ||
            selection.categoryTokens != timeLimitSelection.categoryTokens
        let minutesChanged = minutes != dailyLimitMinutes
        let enabledChanged = enabled != isEnabled

        timeLimitSelection = selection
        dailyLimitMinutes = minutes

        UserDefaults.standard.set(minutes, forKey: "screenTimeLimitMinutes")
        sharedDefaults?.set(minutes, forKey: "screenTimeLimitMinutes")
        UserDefaults.standard.set(enabled, forKey: "screenTimeLimitEnabled")
        sharedDefaults?.set(enabled, forKey: "screenTimeLimitEnabled")
        saveTimeLimitSelection()
        sharedDefaults?.synchronize()

        isEnabled = enabled

        if !enabled {
            return
        }

        guard hasTimeLimitAppsSelected else { return }

        let center = DeviceActivityCenter()
        let isSystemMonitoring = center.activities.contains(.screenTimeLimit)

        if selectionChanged || minutesChanged || enabledChanged || !isSystemMonitoring {
            startMonitoringFresh()
        }
    }

    func ensureMonitoringActive() {
        guard isEnabled else { return }
        guard hasTimeLimitAppsSelected else { return }
        guard ScreenTimeService.shared.isAuthorized else { return }

        let center = DeviceActivityCenter()
        if center.activities.contains(.screenTimeLimit) {
            isMonitoringActive = true
            return
        }

        startMonitoringFresh()
    }

    private func startMonitoringFresh() {
        guard ScreenTimeService.shared.isAuthorized else { return }
        guard hasTimeLimitAppsSelected else { return }

        saveTimeLimitSelection()
        sharedDefaults?.synchronize()

        let center = DeviceActivityCenter()
        center.stopMonitoring([.screenTimeLimit])

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: DateComponents(minute: 1)
        )

        let event = DeviceActivityEvent(
            applications: timeLimitSelection.applicationTokens,
            categories: timeLimitSelection.categoryTokens,
            webDomains: timeLimitSelection.webDomainTokens,
            threshold: DateComponents(minute: dailyLimitMinutes)
        )

        do {
            try center.startMonitoring(
                .screenTimeLimit,
                during: schedule,
                events: [.timeLimitReached: event]
            )
            isMonitoringActive = true
            sharedDefaults?.set(true, forKey: "screenTimeLimitMonitoringActive")
            sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "screenTimeLimitMonitoringStarted")
            sharedDefaults?.synchronize()
        } catch {
            isMonitoringActive = false
        }
    }

    func stopMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring([.screenTimeLimit])
        isMonitoringActive = false
        sharedDefaults?.set(false, forKey: "screenTimeLimitMonitoringActive")
        sharedDefaults?.synchronize()
    }

    func lockTimeLimitedApps() {
        guard ScreenTimeService.shared.isAuthorized else { return }
        guard hasTimeLimitAppsSelected else { return }

        let apps = timeLimitSelection.applicationTokens
        let categories = timeLimitSelection.categoryTokens

        if !apps.isEmpty {
            store.shield.applications = apps
        }
        if !categories.isEmpty {
            store.shield.applicationCategories = .specific(categories)
        }

        isTimeLimitLocked = true
        sharedDefaults?.set(true, forKey: "isTimeLimitBlocking")
        sharedDefaults?.synchronize()

        sendTimeLimitNotification()
    }

    func unlockTimeLimitedApps() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.clearAllSettings()
        isTimeLimitLocked = false
        sharedDefaults?.set(false, forKey: "isTimeLimitBlocking")
        sharedDefaults?.synchronize()
    }

    func unlockWithChallenge() {
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "lastTimeLimitUnlockTimestamp")
        sharedDefaults?.synchronize()
        unlockTimeLimitedApps()
    }

    func wasTimeLimitUnlockedToday() -> Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastTimeLimitUnlockTimestamp"), timestamp > 0 else {
            return false
        }
        let unlockDate = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(unlockDate)
    }

    func refreshLockState() {
        sharedDefaults?.synchronize()
        let locked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") ?? false
        let isToday = isTimeLimitLockFromToday()
        if locked && isToday && !wasTimeLimitUnlockedToday() {
            let apps = timeLimitSelection.applicationTokens
            let categories = timeLimitSelection.categoryTokens
            if !apps.isEmpty {
                store.shield.applications = apps
            }
            if !categories.isEmpty {
                store.shield.applicationCategories = .specific(categories)
            }
        }
    }

    private func isTimeLimitLockFromToday() -> Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), timestamp > 0 else {
            return false
        }
        let lockDate = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(lockDate)
    }

    private func clearStaleLockData() {
        sharedDefaults?.synchronize()
        if let ts = sharedDefaults?.double(forKey: "timeLimitLockTimestamp"), ts > 0 {
            let d = Date(timeIntervalSince1970: ts)
            if !Calendar.current.isDateInToday(d) {
                sharedDefaults?.set(false, forKey: "isTimeLimitLocked")
                sharedDefaults?.set(false, forKey: "isTimeLimitBlocking")
                sharedDefaults?.removeObject(forKey: "lastTimeLimitUnlockTimestamp")
                sharedDefaults?.removeObject(forKey: "timeLimitLockTimestamp")
                sharedDefaults?.synchronize()
                store.shield.applications = nil
                store.shield.applicationCategories = nil
                store.clearAllSettings()
            }
        }
    }

    private func sendTimeLimitNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Screen Time Limit Reached \u{23F0}"
        content.body = "You've used your daily screen time. Complete a challenge to unlock!"
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

    private func saveTimeLimitSelection() {
        if let data = try? JSONEncoder().encode(timeLimitSelection) {
            UserDefaults.standard.set(data, forKey: "timeLimitActivitySelection")
            sharedDefaults?.set(data, forKey: "timeLimitActivitySelection")
            sharedDefaults?.synchronize()
        }
    }
}
