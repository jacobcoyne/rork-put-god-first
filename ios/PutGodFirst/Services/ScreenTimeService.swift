import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

nonisolated extension DeviceActivityName {
    static let midnightReblock = Self("godFirst.midnightReblock")
    static let earlyMorningBackup = Self("godFirst.earlyMorningBackup")
    static let preDawnBackup = Self("godFirst.preDawnBackup")
    static let morningBackup = Self("godFirst.morningBackup")
    static let lateNightPrep = Self("godFirst.lateNightPrep")
}

nonisolated extension ManagedSettingsStore.Name {
    static let godFirst = Self("godFirst")
}

@Observable
final class ScreenTimeService {
    static let shared = ScreenTimeService()

    var isAuthorized: Bool = false
    var isBlocking: Bool = false
    var godFirstModeActive: Bool {
        didSet {
            UserDefaults.standard.set(godFirstModeActive, forKey: "godFirstModeActive")
            sharedDefaults?.set(godFirstModeActive, forKey: "godFirstModeActive")
            sharedDefaults?.synchronize()
        }
    }
    var godFirstModeEnrolled: Bool {
        didSet {
            UserDefaults.standard.set(godFirstModeEnrolled, forKey: "godFirstModeEnrolled")
            sharedDefaults?.set(godFirstModeEnrolled, forKey: "godFirstModeEnrolled")
            sharedDefaults?.synchronize()
        }
    }
    var activitySelection: FamilyActivitySelection {
        didSet {
            saveSelection()
        }
    }

    private let store = ManagedSettingsStore(named: .godFirst)
    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private init() {
        let standardBlocking = UserDefaults.standard.bool(forKey: "isCurrentlyBlocking")
        let shared = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")
        shared?.synchronize()
        let sharedBlocking = shared?.bool(forKey: "isCurrentlyBlocking") ?? false
        isBlocking = standardBlocking || sharedBlocking
        if sharedBlocking && !standardBlocking {
            UserDefaults.standard.set(true, forKey: "isCurrentlyBlocking")
        }
        godFirstModeActive = UserDefaults.standard.bool(forKey: "godFirstModeActive")
        let udEnrolled = UserDefaults.standard.bool(forKey: "godFirstModeEnrolled")
        let sharedEnrolled = shared?.bool(forKey: "godFirstModeEnrolled") ?? false
        godFirstModeEnrolled = udEnrolled || sharedEnrolled

        if let data = UserDefaults.standard.data(forKey: "familyActivitySelection"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            activitySelection = selection
            shared?.set(data, forKey: "familyActivitySelection")
            shared?.synchronize()
        } else if let data = shared?.data(forKey: "familyActivitySelection"),
                  let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            activitySelection = selection
        } else {
            activitySelection = FamilyActivitySelection()
        }

        if godFirstModeEnrolled && !godFirstModeActive {
            godFirstModeActive = true
        }

        sharedDefaults?.set(godFirstModeActive, forKey: "godFirstModeActive")
        sharedDefaults?.set(godFirstModeEnrolled, forKey: "godFirstModeEnrolled")
        sharedDefaults?.synchronize()

        let status = AuthorizationCenter.shared.authorizationStatus
        isAuthorized = (status == .approved)

        if (godFirstModeActive || godFirstModeEnrolled) && isAuthorized {
            if godFirstModeEnrolled && !godFirstModeActive {
                godFirstModeActive = true
            }
            if !checkHasCompletedToday() && !wasScriptureUnlockedToday() {
                blockApps()
            } else if isBlocking {
                blockApps()
            }
            scheduleAllMonitoring()
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isAuthorized = true
            return true
        } catch {
            isAuthorized = false
            return false
        }
    }

    func blockApps() {
        guard isAuthorized else { return }

        forceReloadSelection()

        let apps = activitySelection.applicationTokens
        let categories = activitySelection.categoryTokens

        guard !apps.isEmpty || !categories.isEmpty else { return }

        if !apps.isEmpty {
            store.shield.applications = apps
        }
        if !categories.isEmpty {
            store.shield.applicationCategories = .specific(categories)
        }

        isBlocking = true
        UserDefaults.standard.set(true, forKey: "isCurrentlyBlocking")
        sharedDefaults?.set(true, forKey: "isCurrentlyBlocking")
        sharedDefaults?.synchronize()

        saveSelection()
    }

    func manualLockForFocus() {
        guard isAuthorized else { return }
        forceReloadSelection()
        guard hasAppsSelected else { return }
        if !godFirstModeActive {
            godFirstModeActive = true
            godFirstModeEnrolled = true
        }
        sharedDefaults?.removeObject(forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.synchronize()
        UserDefaults.standard.set(true, forKey: "manualFocusLockActive")
        sharedDefaults?.set(true, forKey: "manualFocusLockActive")
        sharedDefaults?.synchronize()
        blockApps()
        scheduleAllMonitoring()
    }

    func isManualFocusLockActive() -> Bool {
        sharedDefaults?.synchronize()
        return sharedDefaults?.bool(forKey: "manualFocusLockActive") ?? UserDefaults.standard.bool(forKey: "manualFocusLockActive")
    }

    func clearManualFocusLock() {
        UserDefaults.standard.set(false, forKey: "manualFocusLockActive")
        sharedDefaults?.set(false, forKey: "manualFocusLockActive")
        sharedDefaults?.synchronize()
    }

    func activateGodFirstMode() {
        guard isAuthorized else { return }
        forceReloadSelection()
        guard hasAppsSelected else { return }
        godFirstModeActive = true
        godFirstModeEnrolled = true
        blockApps()
        scheduleAllMonitoring()
    }

    func deactivateGodFirstMode() {
        godFirstModeActive = false
        godFirstModeEnrolled = false
        unblockApps()
        stopAllMonitoring()
    }

    func unblockApps() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.clearAllSettings()
        isBlocking = false
        UserDefaults.standard.set(false, forKey: "isCurrentlyBlocking")
        sharedDefaults?.set(false, forKey: "isCurrentlyBlocking")
        sharedDefaults?.synchronize()
        scheduleAllMonitoring()
    }

    func checkAndApplyBlocking(hasCompletedToday: Bool) {
        guard isAuthorized else { return }

        refreshAuthStatus()
        forceReloadSelection()

        if isManualFocusLockActive() {
            if !isBlocking {
                blockApps()
            }
            return
        }

        if wasScriptureUnlockedToday() {
            if isBlocking {
                unblockApps()
            }
            return
        }

        if !godFirstModeActive && !godFirstModeEnrolled {
            if isBlocking {
                unblockApps()
            }
            return
        }

        if !hasCompletedToday {
            blockApps()
        } else {
            if isBlocking {
                unblockApps()
            }
        }

        scheduleAllMonitoring()
    }

    func wasScriptureUnlockedToday() -> Bool {
        sharedDefaults?.synchronize()
        guard let timestamp = sharedDefaults?.double(forKey: "lastScriptureUnlockTimestamp"), timestamp > 0 else {
            return false
        }
        let unlockDate = Date(timeIntervalSince1970: timestamp)
        return Calendar.current.isDateInToday(unlockDate)
    }

    func syncCompletionDate(_ date: Date?) {
        if let date = date {
            sharedDefaults?.set(date.timeIntervalSince1970, forKey: "lastCompletedTimestamp")
        } else {
            sharedDefaults?.removeObject(forKey: "lastCompletedTimestamp")
        }
        sharedDefaults?.synchronize()
    }

    func refreshBlockingState() {
        sharedDefaults?.synchronize()
        let sharedBlocking = sharedDefaults?.bool(forKey: "isCurrentlyBlocking") ?? false
        if sharedBlocking != isBlocking {
            isBlocking = sharedBlocking
            UserDefaults.standard.set(sharedBlocking, forKey: "isCurrentlyBlocking")
        }
    }

    var hasAppsSelected: Bool {
        !activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty
    }

    func checkHasCompletedToday() -> Bool {
        sharedDefaults?.synchronize()
        if let timestamp = sharedDefaults?.double(forKey: "lastCompletedTimestamp"), timestamp > 0 {
            let lastCompleted = Date(timeIntervalSince1970: timestamp)
            return Calendar.current.isDateInToday(lastCompleted)
        }
        let lastDate = UserDefaults.standard.object(forKey: "lastCompletedDate") as? Date
        return lastDate.map { Calendar.current.isDateInToday($0) } ?? false
    }

    func refreshAuthStatus() {
        let status = AuthorizationCenter.shared.authorizationStatus
        isAuthorized = (status == .approved)
    }

    private func forceReloadSelection() {
        sharedDefaults?.synchronize()
        if let data = sharedDefaults?.data(forKey: "familyActivitySelection"),
           let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            activitySelection = saved
        } else if let data = UserDefaults.standard.data(forKey: "familyActivitySelection"),
                  let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            activitySelection = saved
        }
    }

    func scheduleAllMonitoring() {
        guard isAuthorized else { return }
        guard godFirstModeActive || godFirstModeEnrolled || hasAppsSelected else { return }
        let center = DeviceActivityCenter()

        let allActivities: [DeviceActivityName] = [
            .midnightReblock, .earlyMorningBackup, .preDawnBackup,
            .morningBackup, .lateNightPrep
        ]
        center.stopMonitoring(allActivities)

        let schedules: [(DeviceActivityName, Int, Int, Int, Int)] = [
            (.midnightReblock,     0,  0,  0, 30),
            (.earlyMorningBackup,  3,  0,  3, 30),
            (.preDawnBackup,       5,  0,  5, 30),
            (.morningBackup,       7,  0,  7, 30),
            (.lateNightPrep,      23, 30, 23, 55),
        ]

        for (name, startH, startM, endH, endM) in schedules {
            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: startH, minute: startM, second: 0),
                intervalEnd: DateComponents(hour: endH, minute: endM, second: 0),
                repeats: true,
                warningTime: nil
            )
            do {
                try center.startMonitoring(name, during: schedule)
            } catch {}
        }
    }

    func stopAllMonitoring() {
        let center = DeviceActivityCenter()
        center.stopMonitoring([
            .midnightReblock, .earlyMorningBackup, .preDawnBackup,
            .morningBackup, .lateNightPrep
        ])
    }

    func scheduleMidnightReblock() {
        scheduleAllMonitoring()
    }

    private func saveSelection() {
        if let data = try? JSONEncoder().encode(activitySelection) {
            UserDefaults.standard.set(data, forKey: "familyActivitySelection")
            sharedDefaults?.set(data, forKey: "familyActivitySelection")
            sharedDefaults?.synchronize()
        }
    }
}
