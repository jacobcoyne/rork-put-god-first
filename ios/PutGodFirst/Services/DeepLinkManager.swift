import SwiftUI

nonisolated enum DeepLinkAction: Sendable, Equatable {
    case scriptureUnlock
    case openSession
    case timeLimitUnlock
}

@Observable
final class DeepLinkManager {
    static let shared = DeepLinkManager()
    var pendingAction: DeepLinkAction? = nil

    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    private init() {}

    func consumeAction() -> DeepLinkAction? {
        let action = pendingAction
        pendingAction = nil
        return action
    }

    func checkSharedDefaultsForPendingLink() {
        sharedDefaults?.synchronize()
        guard let linkKey = sharedDefaults?.string(forKey: "pendingShieldDeepLink"), !linkKey.isEmpty else { return }

        sharedDefaults?.removeObject(forKey: "pendingShieldDeepLink")
        sharedDefaults?.synchronize()

        if pendingAction != nil { return }

        switch linkKey {
        case "scripture-unlock":
            pendingAction = .scriptureUnlock
        case "start-session":
            pendingAction = .openSession
        case "time-limit-unlock":
            pendingAction = .timeLimitUnlock
        default:
            break
        }
    }
}
