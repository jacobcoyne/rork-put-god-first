import Foundation

@Observable
final class ScriptureUnlockService {
    static let shared = ScriptureUnlockService()

    private let sharedDefaults = UserDefaults(suiteName: "group.app.rork.god-first-app-c1nigyo")

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "scriptureUnlockEnabled")
            sharedDefaults?.set(isEnabled, forKey: "scriptureUnlockEnabled")
            sharedDefaults?.synchronize()
        }
    }

    var wantToMemorize: Bool {
        didSet { UserDefaults.standard.set(wantToMemorize, forKey: "wantToMemorizeScripture") }
    }

    var bibleReadingFrequency: String {
        didSet { UserDefaults.standard.set(bibleReadingFrequency, forKey: "bibleReadingFrequency") }
    }

    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "scriptureUnlockEnabled")
        self.wantToMemorize = UserDefaults.standard.bool(forKey: "wantToMemorizeScripture")
        self.bibleReadingFrequency = UserDefaults.standard.string(forKey: "bibleReadingFrequency") ?? ""
        sharedDefaults?.set(self.isEnabled, forKey: "scriptureUnlockEnabled")
        sharedDefaults?.synchronize()
    }

    func unlockAppsWithScripture() {
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "lastScriptureUnlockTimestamp")
        sharedDefaults?.synchronize()
    }
}
