import SwiftUI
import Observation
import RevenueCat

@Observable
final class AppViewModel {
    var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
            KeychainPersistenceService.shared.saveBool(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    var prayerDurationMinutes: Int {
        didSet { UserDefaults.standard.set(prayerDurationMinutes, forKey: "prayerDurationMinutes") }
    }
    var journeyStyle: JourneyStyle {
        didSet { UserDefaults.standard.set(journeyStyle.rawValue, forKey: "journeyStyle") }
    }
    var currentStreak: Int {
        didSet {
            UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
            KeychainPersistenceService.shared.saveInt(currentStreak, forKey: "currentStreak")
        }
    }
    var totalDaysCompleted: Int {
        didSet {
            UserDefaults.standard.set(totalDaysCompleted, forKey: "totalDaysCompleted")
            KeychainPersistenceService.shared.saveInt(totalDaysCompleted, forKey: "totalDaysCompleted")
        }
    }
    var lastCompletedDate: Date? {
        didSet {
            if let date = lastCompletedDate {
                UserDefaults.standard.set(date, forKey: "lastCompletedDate")
                KeychainPersistenceService.shared.saveDate(date, forKey: "lastCompletedDate")
            }
            ScreenTimeService.shared.syncCompletionDate(lastCompletedDate)
        }
    }
    var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
            KeychainPersistenceService.shared.saveString(userName, forKey: "userName")
        }
    }
    var sessionState: SessionState = .locked
    var favoritePrayerIDs: Set<UUID> {
        didSet {
            let array = favoritePrayerIDs.map { $0.uuidString }
            UserDefaults.standard.set(array, forKey: "favoritePrayerIDs")
        }
    }
    var todayContent: DailyContent
    var isLoadingContent: Bool = false
    var showPaywall: Bool = false
    var showCompletionPopup: Bool = false
    var showAppBlockingSetup: Bool = false
    var pendingScriptureUnlock: Bool = false
    var pendingOpenSession: Bool = false
    var pendingTimeLimitUnlock: Bool = false
    var selectedPrayerMode: PrayerMode = .pickPrayer
    var hasSeenLockTimeSetup: Bool {
        didSet { UserDefaults.standard.set(hasSeenLockTimeSetup, forKey: "hasSeenLockTimeSetup") }
    }
    var denomination: String {
        didSet {
            UserDefaults.standard.set(denomination, forKey: "denomination")
            KeychainPersistenceService.shared.saveString(denomination, forKey: "denomination")
        }
    }
    var spiritualGoals: [String] {
        didSet {
            UserDefaults.standard.set(spiritualGoals, forKey: "spiritualGoals")
            KeychainPersistenceService.shared.saveCodable(spiritualGoals, forKey: "spiritualGoals")
        }
    }
    var sessionHistory: SessionHistory {
        didSet {
            if let data = try? JSONEncoder().encode(sessionHistory) {
                UserDefaults.standard.set(data, forKey: "sessionHistory")
            }
            KeychainPersistenceService.shared.saveCodable(sessionHistory, forKey: "sessionHistory")
        }
    }
    var earnedBadges: Set<Int> {
        didSet {
            UserDefaults.standard.set(Array(earnedBadges), forKey: "earnedBadges")
            KeychainPersistenceService.shared.saveCodable(Array(earnedBadges), forKey: "earnedBadges")
        }
    }

    var hasCompletedToday: Bool {
        guard let last = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    init() {
        let defaults = UserDefaults.standard
        let keychain = KeychainPersistenceService.shared

        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
            || (keychain.loadBool(forKey: "hasCompletedOnboarding") ?? false)

        self.prayerDurationMinutes = max(defaults.integer(forKey: "prayerDurationMinutes"), 5)
        let styleRaw = defaults.string(forKey: "journeyStyle") ?? JourneyStyle.guided.rawValue
        self.journeyStyle = JourneyStyle(rawValue: styleRaw) ?? .guided

        let udStreak = defaults.integer(forKey: "currentStreak")
        let kcStreak = keychain.loadInt(forKey: "currentStreak") ?? 0
        self.currentStreak = max(udStreak, kcStreak)

        let udTotal = defaults.integer(forKey: "totalDaysCompleted")
        let kcTotal = keychain.loadInt(forKey: "totalDaysCompleted") ?? 0
        self.totalDaysCompleted = max(udTotal, kcTotal)

        let udDate = defaults.object(forKey: "lastCompletedDate") as? Date
        let kcDate = keychain.loadDate(forKey: "lastCompletedDate")
        if let a = udDate, let b = kcDate {
            self.lastCompletedDate = max(a, b)
        } else {
            self.lastCompletedDate = udDate ?? kcDate
        }

        let savedIDs = (defaults.array(forKey: "favoritePrayerIDs") as? [String]) ?? []

        let udName = defaults.string(forKey: "userName") ?? ""
        let kcName = keychain.loadString(forKey: "userName")
        self.userName = udName.isEmpty ? (kcName ?? "") : udName

        self.hasSeenLockTimeSetup = defaults.bool(forKey: "hasSeenLockTimeSetup")

        let udDenom = defaults.string(forKey: "denomination") ?? ""
        let kcDenom = keychain.loadString(forKey: "denomination")
        self.denomination = udDenom.isEmpty ? (kcDenom ?? "") : udDenom

        let udGoals = (defaults.array(forKey: "spiritualGoals") as? [String]) ?? []
        let kcGoals = keychain.loadCodable([String].self, forKey: "spiritualGoals")
        self.spiritualGoals = udGoals.isEmpty ? (kcGoals ?? []) : udGoals

        self.favoritePrayerIDs = Set(savedIDs.compactMap { UUID(uuidString: $0) })

        if let histData = defaults.data(forKey: "sessionHistory"),
           let hist = try? JSONDecoder().decode(SessionHistory.self, from: histData) {
            self.sessionHistory = hist
        } else if let kcHist = keychain.loadCodable(SessionHistory.self, forKey: "sessionHistory") {
            self.sessionHistory = kcHist
        } else {
            self.sessionHistory = SessionHistory()
        }

        let savedBadges = (defaults.array(forKey: "earnedBadges") as? [Int]) ?? []
        let kcBadges = keychain.loadCodable([Int].self, forKey: "earnedBadges") ?? []
        self.earnedBadges = Set(savedBadges.isEmpty ? kcBadges : savedBadges)

        self.todayContent = ContentLibrary.contentForToday()

        Task {
            await loadTodayContent()
            await SubscriptionService.shared.checkSubscriptionStatus()
        }

        if let last = lastCompletedDate, Calendar.current.isDateInToday(last) {
            self.sessionState = .completed
        }

        checkStreakReset()
        migrateEarnedBadgesIfNeeded()
        syncToKeychain()
        ScreenTimeService.shared.syncCompletionDate(lastCompletedDate)
        ScreenTimeService.shared.checkAndApplyBlocking(hasCompletedToday: hasCompletedToday)
        NotificationService.scheduleAllNotifications()
    }

    private func syncToKeychain() {
        let kc = KeychainPersistenceService.shared
        kc.saveBool(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        kc.saveInt(currentStreak, forKey: "currentStreak")
        kc.saveInt(totalDaysCompleted, forKey: "totalDaysCompleted")
        if let date = lastCompletedDate {
            kc.saveDate(date, forKey: "lastCompletedDate")
        }
        kc.saveString(userName, forKey: "userName")
        kc.saveString(denomination, forKey: "denomination")
        kc.saveCodable(spiritualGoals, forKey: "spiritualGoals")
        kc.saveCodable(sessionHistory, forKey: "sessionHistory")
        kc.saveCodable(Array(earnedBadges), forKey: "earnedBadges")
    }

    private func migrateEarnedBadgesIfNeeded() {
        if earnedBadges.isEmpty {
            let bestStreak = sessionHistory.longestStreak
            for milestone in BadgeMilestone.allCases {
                if bestStreak >= milestone.daysRequired {
                    earnedBadges.insert(milestone.rawValue)
                }
            }
        }
    }

    func completeSession() {
        let now = Date.now
        if let last = lastCompletedDate {
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
            if Calendar.current.isDate(last, inSameDayAs: yesterday) {
                currentStreak += 1
            } else if !Calendar.current.isDateInToday(last) {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        totalDaysCompleted += 1
        lastCompletedDate = now
        sessionState = .completed
        let record = SessionRecord(prayerMinutes: prayerDurationMinutes, streakAtTime: currentStreak)
        sessionHistory.addRecord(record)
        checkBadgeEarnings()
        ScreenTimeService.shared.clearManualFocusLock()
        ScreenTimeService.shared.unblockApps()
        NotificationService.rescheduleAfterCompletion()
    }

    func overrideUnlock() {
        sessionState = .completed
        ScreenTimeService.shared.unblockApps()
    }

    func toggleFavorite(_ prayer: Prayer) {
        if favoritePrayerIDs.contains(prayer.id) {
            favoritePrayerIDs.remove(prayer.id)
        } else {
            favoritePrayerIDs.insert(prayer.id)
        }
    }

    func isFavorite(_ prayer: Prayer) -> Bool {
        favoritePrayerIDs.contains(prayer.id)
    }

    func requestReview() {
        if let url = URL(string: "https://apps.apple.com/app/id6759613793?action=write-review") {
            UIApplication.shared.open(url)
        }
    }

    @MainActor
    func loadTodayContent() async {
        isLoadingContent = true
        let content = await DevotionalService.shared.fetchTodayContent()
        todayContent = content
        isLoadingContent = false
    }

    var isProUser: Bool {
        SubscriptionService.shared.isProUser
    }

    func checkDailyReset() {
        let completedToday = hasCompletedToday
        if !completedToday && sessionState == .completed {
            sessionState = .locked
            todayContent = ContentLibrary.contentForToday()
            Task {
                await loadTodayContent()
            }
        }
        checkStreakReset()
        ScreenTimeService.shared.syncCompletionDate(lastCompletedDate)
        ScreenTimeService.shared.checkAndApplyBlocking(hasCompletedToday: completedToday)

        if ScreenTimeService.shared.godFirstModeActive && ScreenTimeService.shared.isAuthorized {
            ScreenTimeService.shared.scheduleAllMonitoring()
        }

        Task {
            await SubscriptionService.shared.checkSubscriptionStatus()
        }
    }

    private func checkBadgeEarnings() {
        for milestone in BadgeMilestone.allCases {
            if currentStreak >= milestone.daysRequired {
                earnedBadges.insert(milestone.rawValue)
            }
        }
    }

    func hasBadge(_ milestone: BadgeMilestone) -> Bool {
        earnedBadges.contains(milestone.rawValue)
    }

    var nextUnearnedBadge: BadgeMilestone? {
        BadgeMilestone.allCases.first { !earnedBadges.contains($0.rawValue) }
    }

    private func checkStreakReset() {
        guard let last = lastCompletedDate else { return }
        let now = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        if !Calendar.current.isDate(last, inSameDayAs: yesterday) && !Calendar.current.isDateInToday(last) {
            currentStreak = 0
        }
    }
}
