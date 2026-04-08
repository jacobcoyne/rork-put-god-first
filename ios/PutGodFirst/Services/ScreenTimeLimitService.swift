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

        self.isEnabled = shared?.bool(forKey: "screenTimeLimitEnabled") ?? UserDefaults.standard.bool(forKey: "screenTimeLimitEnabled")
        let savedMinutes = shared?.integer(forKey: "screenTimeLimitMinutes") ?? UserDefaults.standard.integer(forKey: "screenTimeLimitMinutes")
        self.dailyLimitMinutes = savedMinutes > 0 ? savedMinutes : 30

        if let data = shared?.data(forKey: "timeLimitActivitySelection"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.timeLimitSelection = selection
        } else if let data = UserDefaults.standard.data(forKey: "timeLimitActivitySelection"),
                  let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.timeLimitSelection = selection
        } else {
            self.timeLimitSelection = FamilyActivitySelection()
        }

        if isEnabled && hasTimeLimitAppsSelected {
            clearStaleLockData()
            if isTimeLimitLocked && !wasTimeLimitUnlockedToday() {
                reapplyShields()
            }
            ensureMonitoringActive()
        }
    }

    func applySettingsAndStartMonitoring(selection: FamilyActivitySelection, minutes: Int, enabled: Bool) {
        timeLimitSelection = selection
        dailyLimitMinutes = minutes

        UserDefaults.standard.set(minutes, forKey: "screenTimeLimitMinutes")
        sharedDefaults?.set(minutes, forKey: "screenTimeLimitMinutes")
        UserDefaults.standard.set(enabled, forKey: "screenTimeLimitEnabled")
        sharedDefaults?.set(enabled, forKey: "screenTimeLimitEnabled")
        saveTimeLimitSelection()
        sharedDefaults?.synchronize()

        if !enabled {
            isEnabled = enabled
            return
        }

        isEnabled = enabled

        guard hasTimeLimitAppsSelected else { return }

        stopMonitoring()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            startMonitoringFresh()
        }
    }

    func ensureMonitoringActive() {
        guard isEnabled else { return }
        guard hasTimeLimitAppsSelected else { return }
        guard ScreenTimeService.shared.isAuthorized else { return }

        let center = DeviceActivityCenter()
        let alreadyRunning = center.activities.contains(.screenTimeLimit)

        if alreadyRunning {
            isMonitoringActive = true
        } else {
            startMonitoringFresh()
        }
    }

    private func startMonitoringFresh() {
        guard ScreenTimeService.shared.isAuthorized else { return }
        guard hasTimeLimitAppsSelected else { return }
        guard dailyLimitMinutes > 0 else { return }

        saveTimeLimitSelection()
        sharedDefaults?.synchronize()

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
        let webDomains = timeLimitSelection.webDomainTokens

        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomains = webDomains.isEmpty ? nil : webDomains

        isTimeLimitLocked = true
        sharedDefaults?.set(true, forKey: "isTimeLimitBlocking")
        sharedDefaults?.synchronize()
    }

    func unlockTimeLimitedApps() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
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
        reloadTimeLimitSelection()
        sharedDefaults?.synchronize()
        let locked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") ?? false
        let isToday = isTimeLimitLockFromToday()
        if locked && isToday && !wasTimeLimitUnlockedToday() {
            reapplyShields()
        }
        if isEnabled && hasTimeLimitAppsSelected {
            ensureMonitoringActive()
        }
    }

    func checkAndEnforceFromForeground() {
        guard isEnabled else { return }
        guard hasTimeLimitAppsSelected else { return }
        guard ScreenTimeService.shared.isAuthorized else { return }

        clearStaleLockData()
        reloadTimeLimitSelection()

        if isTimeLimitLocked && !wasTimeLimitUnlockedToday() {
            reapplyShields()
            return
        }

        let locked = sharedDefaults?.bool(forKey: "isTimeLimitLocked") ?? false
        if locked && isTimeLimitLockFromToday() && !wasTimeLimitUnlockedToday() {
            reapplyShields()
            return
        }

        ensureMonitoringActive()
    }

    private func reloadTimeLimitSelection() {
        sharedDefaults?.synchronize()
        if let data = sharedDefaults?.data(forKey: "timeLimitActivitySelection"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            timeLimitSelection = selection
        } else if let data = UserDefaults.standard.data(forKey: "timeLimitActivitySelection"),
                  let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            timeLimitSelection = selection
        }
    }

    private func reapplyShields() {
        let apps = timeLimitSelection.applicationTokens
        let categories = timeLimitSelection.categoryTokens
        let webDomains = timeLimitSelection.webDomainTokens
        if !apps.isEmpty {
            store.shield.applications = apps
        }
        if !categories.isEmpty {
            store.shield.applicationCategories = .specific(categories)
        }
        if !webDomains.isEmpty {
            store.shield.webDomains = webDomains
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
                store.shield.webDomains = nil
            }
        }
    }

    private func saveTimeLimitSelection() {
        if let data = try? JSONEncoder().encode(timeLimitSelection) {
            UserDefaults.standard.set(data, forKey: "timeLimitActivitySelection")
            sharedDefaults?.set(data, forKey: "timeLimitActivitySelection")
            sharedDefaults?.synchronize()
        }
    }
}
