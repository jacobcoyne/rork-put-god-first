import BackgroundTasks
import Foundation

enum BackgroundEnforcementService {
    static let midnightReblockTaskID = "app.rork.god-first-app-c1nigyo.midnightReblock"
    static let enforcementCheckTaskID = "app.rork.god-first-app-c1nigyo.enforcementCheck"

    static func registerTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: midnightReblockTaskID, using: nil) { task in
            handleMidnightReblock(task: task as! BGProcessingTask)
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: enforcementCheckTaskID, using: nil) { task in
            handleEnforcementCheck(task: task as! BGAppRefreshTask)
        }
    }

    static func scheduleAll() {
        scheduleMidnightReblock()
        scheduleEnforcementCheck()
    }

    static func scheduleMidnightReblock() {
        let request = BGProcessingTaskRequest(identifier: midnightReblockTaskID)
        let calendar = Calendar.current
        var midnight = calendar.startOfDay(for: Date())
        midnight = calendar.date(byAdding: .day, value: 1, to: midnight) ?? midnight
        request.earliestBeginDate = midnight
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        try? BGTaskScheduler.shared.submit(request)
    }

    static func scheduleEnforcementCheck() {
        let request = BGAppRefreshTaskRequest(identifier: enforcementCheckTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handleMidnightReblock(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        let st = ScreenTimeService.shared
        if st.isAuthorized && (st.godFirstModeActive || st.godFirstModeEnrolled) {
            st.performMidnightReset()
        }

        task.setTaskCompleted(success: true)

        scheduleMidnightReblock()
        scheduleEnforcementCheck()
    }

    private static func handleEnforcementCheck(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        let st = ScreenTimeService.shared
        if st.isAuthorized && (st.godFirstModeActive || st.godFirstModeEnrolled) {
            st.enforceFromBackground()
        }

        let stl = ScreenTimeLimitService.shared
        stl.checkAndEnforceFromForeground()
        stl.ensureMonitoringActive()

        task.setTaskCompleted(success: true)

        scheduleEnforcementCheck()
    }
}
