import Foundation
import BranchSDK

class BranchService {
    static let shared = BranchService()

    private init() {}

    func configure() {
        let branchKey = Config.EXPO_PUBLIC_BRANCH_KEY
        guard !branchKey.isEmpty else {
            print("[Branch] No Branch key configured, skipping initialization")
            return
        }

        #if DEBUG
        Branch.setUseTestBranchKey(true)
        Branch.enableLogging()
        #endif
    }

    func initSession(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Branch.getInstance().initSession(launchOptions: launchOptions) { params, error in
            if let error {
                print("[Branch] Init error: \(error.localizedDescription)")
                return
            }
            guard let params else { return }
            print("[Branch] Init params: \(params)")

            if let clickedBranchLink = params["+clicked_branch_link"] as? Bool, clickedBranchLink {
                self.handleDeepLinkParams(params)
            }
        }
    }

    func handleURL(_ url: URL) -> Bool {
        Branch.getInstance().handleDeepLink(url)
        return true
    }

    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }

    func logEvent(_ eventName: String, params: [String: Any]? = nil) {
        let event = BranchEvent.customEvent(withName: eventName)
        if let params {
            for (key, value) in params {
                if let stringValue = value as? String {
                    event.customData[key] = stringValue
                } else {
                    event.customData[key] = "\(value)"
                }
            }
        }
        event.logEvent()
    }

    func logStandardEvent(_ standardEvent: BranchStandardEvent, params: [String: String]? = nil) {
        let event = BranchEvent.standardEvent(standardEvent)
        if let params {
            for (key, value) in params {
                event.customData[key] = value
            }
        }
        event.logEvent()
    }

    func setUserIdentity(_ userId: String) {
        Branch.getInstance().setIdentity(userId)
    }

    func logout() {
        Branch.getInstance().logout()
    }

    private func handleDeepLinkParams(_ params: [AnyHashable: Any]) {
        if let action = params["action"] as? String {
            switch action {
            case "scripture_unlock":
                Task { @MainActor in
                    DeepLinkManager.shared.pendingAction = .scriptureUnlock
                }
            case "open_session":
                Task { @MainActor in
                    DeepLinkManager.shared.pendingAction = .openSession
                }
            default:
                break
            }
        }
    }
}
