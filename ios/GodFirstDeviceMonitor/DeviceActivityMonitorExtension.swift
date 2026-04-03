import Foundation
import DeviceActivity
import ManagedSettings
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore(named: .init("godFirst"))
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

    private func handleBlockingCheck(for activity: DeviceActivityName, isStart: Bool) {
        sharedDefaults?.synchronize()

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
}
