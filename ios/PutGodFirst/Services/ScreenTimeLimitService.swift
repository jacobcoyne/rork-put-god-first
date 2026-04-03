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
            UserDefaults.standard.set(isEnabled, forKey: "screenTimeLimitEnabled")
            sharedDefaults?.set(isEnabled, forKey: "screenTimeLimitEnabled")
            sharedDefaults?.synchronize()
            if isEnabled {
                startMonitoring()
            } else {
                stopMonitoring()
                unlockTimeLimitedApps()
            }
        }
    }

    var dailyLimitMinutes: Int {
        didSet {
            UserDefaults.standard.set(dailyLimitMinutes, forKey: "screenTimeLimitMinutes")
            sharedDefaults?.set(dailyLimitMinutes, forKey: "screenTimeLimitMinutes")
            sharedDefaults?.synchronize()
            if isEnabled {
                startMonitoring()
            }
        }
    }

    var timeLimitSelection: FamilyActivitySelection {
        didSet {
            saveTimeLimitSelection()
            if isEnabled {
                startMonitoring()
            }
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
            startMonitoring()
        }
    }

    func startMonitoring() {
        guard ScreenTimeService.shared.isAuthorized else { return }
        guard hasTimeLimitAppsSelected else { return }

        let center = DeviceActivityCenter()
        center.stopMonitoring([.screenTimeLimit])

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true,
            warningTime: nil
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
        } catch {}
    }

    func stopMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring([.screenTimeLimit])
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
