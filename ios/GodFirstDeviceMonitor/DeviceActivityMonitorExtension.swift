import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: .init("godFirst"))
    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    override func intervalDidStart(for activity: DeviceActivityName) {
        reblockIfNeeded()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        reblockIfNeeded()
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        reblockIfNeeded()
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        reblockIfNeeded()
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        reblockIfNeeded()
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

        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)

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
