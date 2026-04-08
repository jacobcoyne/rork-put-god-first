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

    private init() {}

    func consumeAction() -> DeepLinkAction? {
        let action = pendingAction
        pendingAction = nil
        return action
    }
}
