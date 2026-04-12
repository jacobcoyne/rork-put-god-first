import DeviceActivity
import ManagedSettings

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: .init("godFirst"))

    override func intervalDidStart(for activity: DeviceActivityName) {
        reapplyShields()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        reapplyShields()
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        reapplyShields()
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        reapplyShields()
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        reapplyShields()
    }

    private func reapplyShields() {
        let hasAppShields = store.shield.applications != nil
        let hasCategoryShields = store.shield.applicationCategories != nil

        if !hasAppShields && !hasCategoryShields {
            return
        }
    }
}
