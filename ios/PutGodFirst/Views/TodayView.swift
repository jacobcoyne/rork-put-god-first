import SwiftUI

struct TodayView: View {
    @Bindable var viewModel: AppViewModel
    @State private var showDevotional: Bool = false
    @State private var showPrayerSetup: Bool = false
    @State private var showScriptureUnlock: Bool = false
    @State private var appearAnimation: Bool = false
    @State private var glowPhase: Bool = false
    @State private var shieldGlow: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var shareItems: [Any] = []
    @State private var showVerseExpanded: Bool = false
    @State private var showDevotionalExpanded: Bool = false
    @State private var selectedBadge: BadgeMilestone? = nil
    @State private var showChat: Bool = false
    @State private var showDeclarationExpanded: Bool = false
    @State private var showProgressDetail: Bool = false
    @State private var showSkipConfirm: Bool = false
    @State private var godFirstModeToggle: Bool = ScreenTimeService.shared.godFirstModeActive
    @State private var shieldBounce: Bool = false
    @State private var shimmerPhase: CGFloat = -1.0
    @State private var lockRotation: Double = 0
    @State private var lockScale: Double = 1.0
    @State private var showAppBlockingFromGodFirst: Bool = false
    @State private var showTimeLimitChallenge: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        else if hour < 17 { return "Good afternoon" }
        else { return "Good evening" }
    }

    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "sun.horizon.fill" }
        else if hour < 17 { return "sun.max.fill" }
        else { return "moon.stars.fill" }
    }

    private var greetingColor: Color {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return Theme.dawnGold }
        else if hour < 17 { return Theme.dawnAmber }
        else { return Theme.icePurple }
    }

    private var content: DailyContent { viewModel.todayContent }

    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private let calendar = Calendar.current
    private var isDark: Bool { colorScheme == .dark }

    private var verseDayThemeIndex: Int {
        Calendar.current.component(.weekday, from: Date()) - 1
    }

    private let cardBackgroundNames: [String] = [
        "CardBG1", "CardBG2", "CardBG3", "CardBG4", "CardBG5",
        "CardBG6", "CardBG7", "CardBG8", "CardBG9", "CardBG10",
        "CardBG11", "CardBG12", "CardBG13", "CardBG14", "CardBG15"
    ]

    private var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    }

    private var verseBackgroundName: String {
        cardBackgroundNames[(dayOfYear) % cardBackgroundNames.count]
    }

    private var devotionalBackgroundName: String {
        cardBackgroundNames[(dayOfYear + 5) % cardBackgroundNames.count]
    }

    private var declarationBackgroundName: String {
        cardBackgroundNames[(dayOfYear + 10) % cardBackgroundNames.count]
    }

    private var currentShieldMilestone: BadgeMilestone {
        if let next = viewModel.nextUnearnedBadge {
            return next
        }
        return BadgeMilestone.allCases.last(where: { viewModel.hasBadge($0) }) ?? .sevenDays
    }

    private var shieldTierColor: Color { currentShieldMilestone.accentColor }
    private var shieldGlowColor: Color { currentShieldMilestone.glowColor }

    private var progressToNextMilestone: Double {
        let streak = viewModel.currentStreak
        if let next = viewModel.nextUnearnedBadge {
            let target = next.daysRequired
            guard target > 0 else { return 0 }
            return min(max(Double(streak) / Double(target), 0), 1.0)
        }
        return 1.0
    }

    private var currentShieldTierName: String {
        if viewModel.nextUnearnedBadge != nil {
            if let highest = BadgeMilestone.allCases.last(where: { viewModel.hasBadge($0) }) {
                return highest.badgeName.replacingOccurrences(of: " Shield", with: "")
            }
            return "New"
        }
        return currentShieldMilestone.badgeName.replacingOccurrences(of: " Shield", with: "")
    }

    private var nextShieldInfo: (name: String, days: Int, color: Color)? {
        guard let next = viewModel.nextUnearnedBadge else { return nil }
        return (next.badgeName, next.daysRequired, next.accentColor)
    }

    private var isAppsLocked: Bool { ScreenTimeService.shared.isBlocking }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                        .padding(.bottom, 20)

                    sessionAction
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)

                    lockStatusPill
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    Button { showProgressDetail = true } label: {
                        streakAndProgress
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    dailyContentSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    guideQuickAccess
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    journeySection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                    sharePromo
                        .padding(.horizontal, 20)
                        .padding(.bottom, 60)
                }
            }
            .background(warmBackground)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                ShareItemsSheet(items: shareItems)
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appearAnimation = true }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) { glowPhase = true }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: false)) { shimmerPhase = 2.0 }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { shieldGlow = true }
            godFirstModeToggle = ScreenTimeService.shared.godFirstModeActive
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                handlePendingActions()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                godFirstModeToggle = ScreenTimeService.shared.godFirstModeActive
                handlePendingActions()
            }
        }
        .onChange(of: viewModel.pendingScriptureUnlock) { _, newValue in
            if newValue {
                viewModel.pendingScriptureUnlock = false
                presentScriptureUnlock()
            }
        }
        .onChange(of: viewModel.pendingOpenSession) { _, newValue in
            if newValue {
                viewModel.pendingOpenSession = false
                if !viewModel.hasCompletedToday {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showDevotional = true
                    }
                }
            }
        }
        .sheet(isPresented: $showVerseExpanded) {
            VerseExpandedSheet(verse: content.verse)
        }
        .sheet(isPresented: $showDevotionalExpanded) {
            DevotionalExpandedSheet(devotional: content.devotional, verse: content.verse)
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailSheet(
                milestone: badge,
                isUnlocked: viewModel.hasBadge(badge),
                currentStreak: viewModel.currentStreak,
                totalDays: viewModel.totalDaysCompleted,
                userName: viewModel.userName
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
        }
        .fullScreenCover(isPresented: $showDevotional) {
            DevotionalReadingView(
                devotional: content.devotional,
                verse: content.verse,
                onDismiss: { showDevotional = false },
                onComplete: {
                    showDevotional = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showPrayerSetup = true
                    }
                }
            )
        }
        .sheet(isPresented: $showChat) {
            GuideChatView(presentedAsSheet: true)
        }
        .sheet(isPresented: $showScriptureUnlock) {
            ScriptureUnlockView {
                ScreenTimeService.shared.refreshBlockingState()
                godFirstModeToggle = ScreenTimeService.shared.godFirstModeActive
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    animateLockToggle()
                }
            }
        }
        .alert("Already completed your session?", isPresented: $showSkipConfirm) {
            Button("Yes, I Put God First") {
                viewModel.completeSession()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        viewModel.showCompletionPopup = true
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will count as today\u{2019}s session. Use this only if you\u{2019}ve already spent time with God outside the app.")
        }
        .sheet(isPresented: $showDeclarationExpanded) {
            DeclarationExpandedSheet(declaration: todayDeclaration)
        }
        .sheet(isPresented: $showProgressDetail) {
            ProgressDetailSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showTimeLimitChallenge) {
            TimeLimitChallengeView {
                ScreenTimeLimitService.shared.unlockWithChallenge()
                ScreenTimeService.shared.refreshBlockingState()
            }
        }
        .onChange(of: viewModel.pendingTimeLimitUnlock) { _, newValue in
            if newValue {
                viewModel.pendingTimeLimitUnlock = false
                presentTimeLimitChallenge()
            }
        }
        .sheet(isPresented: $showAppBlockingFromGodFirst) {
            GodFirstModeSetupSheet {
                if ScreenTimeService.shared.hasAppsSelected {
                    ScreenTimeService.shared.activateGodFirstMode()
                    godFirstModeToggle = true
                    animateLockToggle()
                }
            }
        }
        .fullScreenCover(isPresented: $showPrayerSetup) {
            PrayerSetupView(
                viewModel: viewModel,
                onDismiss: { showPrayerSetup = false },
                onComplete: {
                    showPrayerSetup = false
                    viewModel.completeSession()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.showCompletionPopup = true
                        }
                    }
                }
            )
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(todayDateString.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(1.5)

                    HStack(spacing: 8) {
                        Text("\(timeBasedGreeting),")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(viewModel.userName.isEmpty ? "Friend" : viewModel.userName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(greetingColor)
                    }
                }

                Spacer()

                lockIndicatorButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 16)

            if viewModel.hasCompletedToday {
                completedBanner
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Lock Indicator

    private var lockIndicatorButton: some View {
        Button {
            handleLockTap()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        isAppsLocked
                            ? (isDark ? Color(red: 0.22, green: 0.06, blue: 0.06) : Color(red: 1.0, green: 0.93, blue: 0.91))
                            : (isDark ? Color(red: 0.04, green: 0.16, blue: 0.10) : Color(red: 0.91, green: 0.99, blue: 0.94))
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isAppsLocked
                                    ? Theme.coral.opacity(isDark ? 0.5 : 0.6)
                                    : Theme.successEmerald.opacity(isDark ? 0.45 : 0.55),
                                lineWidth: 2
                            )
                    )
                    .frame(width: 46, height: 46)

                Image(systemName: isAppsLocked ? "lock.fill" : "lock.open.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isAppsLocked ? Theme.coral : Theme.successEmerald)
                    .contentTransition(.symbolEffect(.replace.downUp.byLayer))
                    .scaleEffect(lockScale)
                    .rotationEffect(.degrees(lockRotation))
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.8), trigger: shieldBounce)
    }

    private func animateLockToggle() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            lockScale = 1.25
            lockRotation = isAppsLocked ? -15 : 15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                lockScale = 1.0
                lockRotation = 0
            }
        }
        shieldBounce.toggle()
    }

    private func handleLockTap() {
        if !ScreenTimeService.shared.isAuthorized {
            Task {
                let success = await ScreenTimeService.shared.requestAuthorization()
                if success && ScreenTimeService.shared.hasAppsSelected {
                    ScreenTimeService.shared.activateGodFirstMode()
                    godFirstModeToggle = true
                    animateLockToggle()
                } else if success {
                    showAppBlockingFromGodFirst = true
                }
            }
            return
        }

        if !ScreenTimeService.shared.hasAppsSelected {
            showAppBlockingFromGodFirst = true
            return
        }

        if isAppsLocked {
            showScriptureUnlock = true
        } else {
            ScreenTimeService.shared.manualLockForFocus()
            godFirstModeToggle = true
            animateLockToggle()
        }
    }

    // MARK: - Completed Banner

    private var completedBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.successEmerald.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.successEmerald)
                    .symbolEffect(.bounce, value: viewModel.hasCompletedToday)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Session Complete")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Your apps are unlocked. Walk in peace.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDark ? Theme.successEmerald.opacity(0.06) : Color(red: 0.94, green: 1.0, blue: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Theme.successEmerald.opacity(isDark ? 0.2 : 0.35), lineWidth: 1)
                )
        )
    }

    // MARK: - Session Action

    private var sessionAction: some View {
        Group {
            if !viewModel.hasCompletedToday {
                VStack(spacing: 10) {
                    Button { showDevotional = true } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sunrise.fill")
                                .font(.system(size: 20))
                            Text("Begin Today\u{2019}s Session")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.28, green: 0.52, blue: 0.98),
                                            Color(red: 0.40, green: 0.28, blue: 0.90)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [
                                            .clear,
                                            .white.opacity(0.10),
                                            .white.opacity(0.18),
                                            .white.opacity(0.10),
                                            .clear
                                        ],
                                        startPoint: UnitPoint(x: shimmerPhase - 0.4, y: 0.5),
                                        endPoint: UnitPoint(x: shimmerPhase + 0.4, y: 0.5)
                                    )
                                )
                                .blendMode(.softLight)
                            }
                            .shadow(color: Color(red: 0.32, green: 0.42, blue: 0.95).opacity(0.30), radius: 12, y: 5)
                        )
                    }
                    .sensoryFeedback(.impact(flexibility: .soft), trigger: showDevotional)

                    Button {
                        showSkipConfirm = true
                    } label: {
                        Text("I already put God first today")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.textSecondary.opacity(0.6))
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Lock Status

    private var lockStatusPill: some View {
        Group {
            if isAppsLocked && !viewModel.hasCompletedToday {
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Circle().fill(Color(red: 0.85, green: 0.25, blue: 0.30)).frame(width: 6, height: 6)
                        Text("Apps locked \u{2014} tap \(Image(systemName: "lock.fill")) to unlock")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 0.85, green: 0.25, blue: 0.30).opacity(0.8))
                        Text("Complete today\u{2019}s session to unlock your apps")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.97, blue: 0.96))
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.22, blue: 0.28).opacity(isDark ? 0.18 : 0.14),
                                        Color(red: 0.75, green: 0.18, blue: 0.35).opacity(isDark ? 0.12 : 0.10),
                                        Color(red: 0.60, green: 0.15, blue: 0.40).opacity(isDark ? 0.10 : 0.07),
                                        Color(red: 0.90, green: 0.30, blue: 0.25).opacity(isDark ? 0.12 : 0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.22, blue: 0.28).opacity(isDark ? 0.14 : 0.12),
                                        Color(red: 0.70, green: 0.18, blue: 0.40).opacity(isDark ? 0.06 : 0.05),
                                        .clear
                                    ],
                                    center: .bottomLeading,
                                    startRadius: 10,
                                    endRadius: 180
                                )
                            )
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.60, green: 0.15, blue: 0.40).opacity(isDark ? 0.10 : 0.07),
                                        .clear
                                    ],
                                    center: .topTrailing,
                                    startRadius: 10,
                                    endRadius: 140
                                )
                            )
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.25, blue: 0.30).opacity(isDark ? 0.35 : 0.25),
                                        Color(red: 0.70, green: 0.20, blue: 0.40).opacity(isDark ? 0.20 : 0.15),
                                        Color(red: 0.85, green: 0.30, blue: 0.35).opacity(isDark ? 0.25 : 0.18)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    }
                    .shadow(color: Color(red: 0.85, green: 0.22, blue: 0.28).opacity(isDark ? 0.12 : 0.08), radius: 16, y: 5)
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            } else if isAppsLocked {
                HStack(spacing: 8) {
                    Circle().fill(Color(red: 0.85, green: 0.25, blue: 0.30)).frame(width: 6, height: 6)
                    Text("Apps locked \u{2014} tap \(Image(systemName: "lock.fill")) to unlock")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.97, blue: 0.96))
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.22, blue: 0.28).opacity(isDark ? 0.18 : 0.14),
                                        Color(red: 0.75, green: 0.18, blue: 0.35).opacity(isDark ? 0.12 : 0.10),
                                        Color(red: 0.60, green: 0.15, blue: 0.40).opacity(isDark ? 0.10 : 0.07),
                                        Color(red: 0.90, green: 0.30, blue: 0.25).opacity(isDark ? 0.12 : 0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.22, blue: 0.28).opacity(isDark ? 0.14 : 0.12),
                                        Color(red: 0.70, green: 0.18, blue: 0.40).opacity(isDark ? 0.06 : 0.05),
                                        .clear
                                    ],
                                    center: .bottomLeading,
                                    startRadius: 10,
                                    endRadius: 180
                                )
                            )
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.85, green: 0.25, blue: 0.30).opacity(isDark ? 0.35 : 0.25),
                                        Color(red: 0.70, green: 0.20, blue: 0.40).opacity(isDark ? 0.20 : 0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    }
                    .shadow(color: Color(red: 0.85, green: 0.22, blue: 0.28).opacity(isDark ? 0.12 : 0.08), radius: 16, y: 5)
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            } else if viewModel.hasCompletedToday || godFirstModeToggle {
                HStack(spacing: 8) {
                    Circle().fill(Theme.successEmerald).frame(width: 6, height: 6)
                    Text(viewModel.hasCompletedToday ? "Session complete \u{2014} apps unlocked" : "Apps unlocked")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Capsule().fill(isDark ? Theme.successEmerald.opacity(0.06) : Theme.successEmerald.opacity(0.05)))
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isAppsLocked)
    }

    // MARK: - Daily Content (Full Width Mesh Gradient)

    private var dailyContentSection: some View {
        VStack(spacing: 14) {
            verseCard
            devotionalCard
            Button { showDeclarationExpanded = true } label: {
                declarationCard
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Verse Card

    private func cardImageBackground(_ imageName: String) -> some View {
        Color.clear
            .overlay {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .allowsHitTesting(false)
            }
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.15), .black.opacity(0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
    }

    private var verseCard: some View {
        Button { showVerseExpanded = true } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 10))
                        Text("VERSE OF THE DAY")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.2)
                    }
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(.white.opacity(0.18)))

                    Spacer()

                    Button {
                        shareVerseAsImage()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Share")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(.white.opacity(0.15)))
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 10) {
                    if viewModel.isLoadingContent {
                        HStack(spacing: 8) {
                            ProgressView().tint(.white.opacity(0.7))
                            Text("Loading...")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .frame(height: 60)
                    } else {
                        Text("\u{201C}\(content.verse.text)\u{201D}")
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(.white)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)

                        Text("\u{2014} \(content.verse.reference)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 0)
            }
            .frame(minHeight: 180)
            .background(
                cardImageBackground(verseBackgroundName)
            )
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(isDark ? 0.3 : 0.12), radius: 14, y: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Devotional Card

    private var devotionalCard: some View {
        Button { showDevotionalExpanded = true } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "text.book.closed.fill")
                        .font(.system(size: 10))
                    Text("TODAY\u{2019}S DEVOTIONAL")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.2)
                }
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(.white.opacity(0.18)))
                .padding(.leading, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 10) {
                    if viewModel.isLoadingContent {
                        HStack(spacing: 8) {
                            ProgressView().tint(.white.opacity(0.7))
                            Text("Loading...")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .frame(height: 60)
                    } else {
                        Text(content.devotional.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)

                        Text(String(content.devotional.body.prefix(120)) + "...")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineSpacing(4)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10))
                            Text("\(content.devotional.readingTimeMinutes) min read")
                                .font(.system(size: 12, weight: .semibold))
                            Spacer()
                            HStack(spacing: 4) {
                                Text("Read")
                                    .font(.system(size: 12, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 11, weight: .bold))
                            }
                        }
                        .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 200)
            .background(
                cardImageBackground(devotionalBackgroundName)
            )
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(isDark ? 0.3 : 0.12), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Declaration Card

    private var todayDeclaration: DailyDeclaration {
        DeclarationLibrary.declarationForToday()
    }

    private var declarationCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                Text("TODAY\u{2019}S DECLARATION")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(1.2)
            }
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(.white.opacity(0.18)))
            .padding(.leading, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 10) {
                Text("\u{201C}\(todayDeclaration.text)\u{201D}")
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Text("\u{2014} \(todayDeclaration.reference)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))

                HStack(spacing: 4) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 9, weight: .bold))
                    Text("Declare it")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(.white.opacity(0.15))
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 200)
        .background(
            cardImageBackground(declarationBackgroundName)
        )
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .black.opacity(isDark ? 0.3 : 0.12), radius: 12, y: 4)
    }

    // MARK: - Streak & Progress

    private var streakAndProgress: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [shieldTierColor.opacity(0.25), shieldGlowColor.opacity(0.08), .clear],
                                center: .center,
                                startRadius: 5,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: progressToNextMilestone)
                        .stroke(
                            AngularGradient(
                                colors: [shieldTierColor, shieldGlowColor, shieldTierColor],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 84, height: 84)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: shieldTierColor.opacity(0.4), radius: 4)

                    Circle()
                        .stroke(shieldTierColor.opacity(0.08), lineWidth: 1)
                        .frame(width: 84, height: 84)

                    AsyncImage(url: URL(string: currentShieldMilestone.imageURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fit)
                        } else {
                            Image("ShieldLogo")
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .frame(width: 48, height: 54)
                    .shadow(color: shieldTierColor.opacity(shieldGlow ? 0.6 : 0.15), radius: shieldGlow ? 12 : 4)
                    .scaleEffect(shieldGlow ? 1.03 : 0.97)
                }
                .frame(width: 100)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(viewModel.currentStreak)")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [shieldTierColor, shieldGlowColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("DAY STREAK")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(shieldTierColor)
                            .tracking(1.5)
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 11))
                        Text("\(currentShieldTierName) Tier")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(shieldTierColor)

                    if let next = nextShieldInfo {
                        let remaining = next.days - viewModel.currentStreak
                        let progress = Double(viewModel.currentStreak) / Double(next.days)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(remaining)d to \(next.name)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(1)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(next.color.opacity(0.15))
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [shieldTierColor, next.color],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: max(geo.size.width * progress, 4))
                                        .shadow(color: next.color.opacity(0.3), radius: 2)
                                }
                            }
                            .frame(height: 5)

                            if let nextBadge = viewModel.nextUnearnedBadge {
                                Text("\(viewModel.currentStreak) of \(nextBadge.daysRequired) days to \(nextBadge.daysRequired)-day milestone")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
                }
            }

            thisWeekSection
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                shieldTierColor.opacity(isDark ? 0.22 : 0.16),
                                Color(red: 0.55, green: 0.35, blue: 0.85).opacity(isDark ? 0.14 : 0.10),
                                shieldGlowColor.opacity(isDark ? 0.16 : 0.12),
                                Color(red: 0.30, green: 0.70, blue: 0.80).opacity(isDark ? 0.10 : 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        RadialGradient(
                            colors: [
                                shieldTierColor.opacity(isDark ? 0.18 : 0.14),
                                shieldGlowColor.opacity(isDark ? 0.06 : 0.04),
                                .clear
                            ],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 220
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.55, green: 0.35, blue: 0.85).opacity(isDark ? 0.10 : 0.08),
                                .clear
                            ],
                            center: .bottomTrailing,
                            startRadius: 10,
                            endRadius: 180
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                shieldTierColor.opacity(isDark ? 0.45 : 0.35),
                                Color(red: 0.55, green: 0.35, blue: 0.85).opacity(isDark ? 0.28 : 0.22),
                                shieldGlowColor.opacity(isDark ? 0.20 : 0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isDark ? 0.8 : 1.2
                    )
            }
            .shadow(color: shieldTierColor.opacity(isDark ? 0.15 : 0.12), radius: 18, y: 6)
        )
    }

    private var thisWeekSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("THIS WEEK")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.2)
                Spacer()
                Text("\(viewModel.sessionHistory.thisWeekSessions) of 7 days")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(shieldTierColor)
            }
            weeklyDots
        }
    }

    private func statPill(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Dots (Inline)

    private var weeklyDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { i in
                let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now))!
                let dayDate = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
                let hasSession = viewModel.sessionHistory.hasSession(on: dayDate)
                let isToday = calendar.isDateInToday(dayDate)
                let dayName = calendar.shortWeekdaySymbols[i]

                VStack(spacing: 5) {
                    Text(String(dayName.prefix(1)))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isToday ? Theme.textPrimary : Theme.textSecondary)

                    ZStack {
                        if hasSession {
                            Circle()
                                .fill(isDark ? Color(red: 0.15, green: 0.08, blue: 0.04) : Color(red: 0.98, green: 0.93, blue: 0.86))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color(red: 1.0, green: 0.65, blue: 0.0).opacity(0.6), Color(red: 1.0, green: 0.3, blue: 0.0).opacity(0.3)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                            MiniFlameView(size: 18)
                                .offset(y: -2)
                        } else {
                            Circle()
                                .fill(isDark ? Theme.cardBg : Color.white.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            isToday
                                                ? LinearGradient(colors: [Theme.dawnGold.opacity(0.5), Theme.dawnAmber.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                : LinearGradient(colors: [Theme.darkCardBorder, Theme.darkCardBorder], startPoint: .top, endPoint: .bottom),
                                            lineWidth: isToday ? 2 : 1
                                        )
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Guide Quick Access

    private var guideQuickAccess: some View {
        Button { showChat = true } label: {
            HStack(spacing: 10) {
                GuideLogoAnimated(size: 36)
                    .shadow(color: .white.opacity(0.3), radius: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text("God First Guide")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Ask a faith question")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(red: 0.45, green: 0.35, blue: 0.85))
            }
            .padding(.horizontal, 18)
            .frame(height: 72)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.30, blue: 0.82).opacity(isDark ? 0.22 : 0.16),
                                    Color(red: 0.38, green: 0.42, blue: 0.90).opacity(isDark ? 0.16 : 0.12),
                                    Color(red: 0.30, green: 0.52, blue: 0.95).opacity(isDark ? 0.14 : 0.10),
                                    Color(red: 0.42, green: 0.35, blue: 0.85).opacity(isDark ? 0.12 : 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.50, green: 0.30, blue: 0.90).opacity(isDark ? 0.18 : 0.14),
                                    Color(red: 0.35, green: 0.45, blue: 0.92).opacity(isDark ? 0.06 : 0.04),
                                    .clear
                                ],
                                center: .topLeading,
                                startRadius: 10,
                                endRadius: 200
                            )
                        )
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.28, green: 0.50, blue: 0.95).opacity(isDark ? 0.12 : 0.08),
                                    .clear
                                ],
                                center: .bottomTrailing,
                                startRadius: 10,
                                endRadius: 160
                            )
                        )
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.30, blue: 0.82).opacity(isDark ? 0.45 : 0.35),
                                    Color(red: 0.35, green: 0.45, blue: 0.90).opacity(isDark ? 0.25 : 0.20),
                                    Color(red: 0.30, green: 0.55, blue: 0.95).opacity(isDark ? 0.18 : 0.16)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isDark ? 0.8 : 1.2
                        )
                }
                .shadow(color: Color(red: 0.42, green: 0.32, blue: 0.88).opacity(isDark ? 0.15 : 0.12), radius: 16, y: 5)
            )
            .clipShape(.rect(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: showChat)
    }

    // MARK: - Journey

    private var journeySection: some View {
        let streak = viewModel.currentStreak
        let nextBadge = viewModel.nextUnearnedBadge
        let unlockedCount = BadgeMilestone.allCases.filter { viewModel.hasBadge($0) }.count

        return VStack(spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Journey")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(unlockedCount) of \(BadgeMilestone.allCases.count) shields earned")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "shield.checkered")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 0.22, green: 0.72, blue: 0.52))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(BadgeMilestone.allCases, id: \.rawValue) { milestone in
                        let unlocked = viewModel.hasBadge(milestone)
                        let progress = unlocked ? 1.0 : min(Double(streak) / Double(milestone.daysRequired), 1.0)
                        let isNext = milestone == nextBadge

                        Button { selectedBadge = milestone } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    if unlocked {
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [milestone.accentColor.opacity(0.3), milestone.accentColor.opacity(0.05)],
                                                    center: .center,
                                                    startRadius: 2,
                                                    endRadius: 30
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                    } else {
                                        Circle()
                                            .fill(isDark ? Theme.darkSurface : Color.white.opacity(0.9))
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                Circle()
                                                    .trim(from: 0, to: progress)
                                                    .stroke(
                                                        milestone.accentColor.opacity(0.4),
                                                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                                    )
                                                    .frame(width: 56, height: 56)
                                                    .rotationEffect(.degrees(-90))
                                            )
                                    }

                                    AsyncImage(url: URL(string: milestone.imageURL)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().scaledToFit()
                                        default:
                                            Image(systemName: "shield.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(milestone.accentColor.opacity(unlocked ? 0.8 : 0.3))
                                        }
                                    }
                                    .frame(width: 32, height: 32)
                                    .saturation(unlocked ? 1.0 : 0.1)
                                    .opacity(unlocked ? 1.0 : 0.4)

                                    if !unlocked {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 7, weight: .bold))
                                            .foregroundStyle(Theme.textSecondary)
                                            .offset(y: 22)
                                    }
                                }

                                Text(milestone.badgeName)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(unlocked ? milestone.accentColor : Theme.textSecondary)
                                    .lineLimit(1)

                                if isNext {
                                    Text("NEXT")
                                        .font(.system(size: 7, weight: .black))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(milestone.accentColor))
                                }
                            }
                            .frame(width: 72)
                        }
                        .sensoryFeedback(.impact(weight: .light), trigger: selectedBadge)
                    }
                }
            }
            .contentMargins(.horizontal, 4)

            if let badge = nextBadge {
                let remaining = max(badge.daysRequired - streak, 0)
                let progress = min(Double(streak) / Double(badge.daysRequired), 1.0)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(badge.accentColor)
                            Text("\(remaining) days to \(badge.title)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(badge.accentColor.opacity(0.1))
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [badge.accentColor, badge.glowColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * progress)
                                    .shadow(color: badge.accentColor.opacity(0.4), radius: 4, y: 1)
                            }
                        }
                        .frame(height: 5)
                    }
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(badge.accentColor)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(badge.accentColor.opacity(isDark ? 0.05 : 0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(badge.accentColor.opacity(0.12), lineWidth: 0.5)
                        )
                )
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.72, blue: 0.52).opacity(isDark ? 0.18 : 0.14),
                                Color(red: 0.30, green: 0.55, blue: 0.80).opacity(isDark ? 0.14 : 0.10),
                                Color(red: 0.50, green: 0.40, blue: 0.78).opacity(isDark ? 0.10 : 0.08),
                                Color(red: 0.35, green: 0.82, blue: 0.62).opacity(isDark ? 0.12 : 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.30, green: 0.80, blue: 0.60).opacity(isDark ? 0.14 : 0.10),
                                Color(red: 0.45, green: 0.55, blue: 0.85).opacity(isDark ? 0.06 : 0.04),
                                .clear
                            ],
                            center: .topTrailing,
                            startRadius: 10,
                            endRadius: 200
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.50, green: 0.40, blue: 0.78).opacity(isDark ? 0.08 : 0.06),
                                .clear
                            ],
                            center: .bottomLeading,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.72, blue: 0.52).opacity(isDark ? 0.40 : 0.32),
                                Color(red: 0.40, green: 0.55, blue: 0.80).opacity(isDark ? 0.22 : 0.18),
                                Color(red: 0.35, green: 0.82, blue: 0.62).opacity(isDark ? 0.15 : 0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isDark ? 0.8 : 1.2
                    )
            }
            .shadow(color: Color(red: 0.22, green: 0.72, blue: 0.52).opacity(isDark ? 0.12 : 0.10), radius: 16, y: 5)
        )
    }

    // MARK: - Share Promo

    private var sharePromo: some View {
        Button {
            shareItems = ["I\u{2019}m putting God first every morning with the God First app \u{2728}\n\nToday\u{2019}s verse: \u{201C}\(content.verse.text)\u{201D} \u{2014} \(content.verse.reference)\n\nJoin me and start your mornings with God \u{1F64F}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"]
            showShareSheet = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.90, green: 0.35, blue: 0.50).opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: "heart.text.clipboard.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(red: 0.90, green: 0.35, blue: 0.50))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Share God\u{2019}s Word")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Invite a friend to put God first")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.35, blue: 0.50).opacity(isDark ? 0.16 : 0.12),
                                    Color(red: 0.85, green: 0.50, blue: 0.70).opacity(isDark ? 0.10 : 0.08),
                                    Color(red: 0.70, green: 0.40, blue: 0.80).opacity(isDark ? 0.08 : 0.06),
                                    Color(red: 0.98, green: 0.50, blue: 0.45).opacity(isDark ? 0.10 : 0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.35, blue: 0.50).opacity(isDark ? 0.12 : 0.10),
                                    Color(red: 0.75, green: 0.40, blue: 0.75).opacity(isDark ? 0.05 : 0.04),
                                    .clear
                                ],
                                center: .bottomLeading,
                                startRadius: 10,
                                endRadius: 180
                            )
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.70, green: 0.40, blue: 0.80).opacity(isDark ? 0.08 : 0.06),
                                    .clear
                                ],
                                center: .topTrailing,
                                startRadius: 10,
                                endRadius: 140
                            )
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.90, green: 0.35, blue: 0.50).opacity(isDark ? 0.38 : 0.30),
                                    Color(red: 0.80, green: 0.45, blue: 0.70).opacity(isDark ? 0.22 : 0.18),
                                    Color(red: 0.98, green: 0.50, blue: 0.60).opacity(isDark ? 0.15 : 0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isDark ? 0.8 : 1.2
                        )
                }
                .shadow(color: Color(red: 0.90, green: 0.35, blue: 0.50).opacity(isDark ? 0.12 : 0.10), radius: 16, y: 5)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: showShareSheet)
    }

    // MARK: - Background

    private var warmBackground: some View {
        ZStack {
            if isDark {
                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.04),
                        Color(red: 0.03, green: 0.02, blue: 0.05),
                        Color(red: 0.04, green: 0.03, blue: 0.06),
                        Color(red: 0.03, green: 0.02, blue: 0.04)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.82, blue: 0.42).opacity(0.04),
                        Color(red: 1.0, green: 0.62, blue: 0.38).opacity(0.02),
                        .clear
                    ],
                    center: .init(x: 0.75, y: 0.08),
                    startRadius: 20,
                    endRadius: 350
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.99, green: 0.98, blue: 0.96),
                        Color(red: 0.98, green: 0.97, blue: 0.95),
                        Color(red: 0.97, green: 0.96, blue: 0.94),
                        Color(red: 0.96, green: 0.95, blue: 0.93)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color(red: 0.96, green: 0.94, blue: 0.90).opacity(0.3),
                        .clear
                    ],
                    center: .init(x: 0.75, y: 0.08),
                    startRadius: 20,
                    endRadius: 350
                )
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - Helpers

    private func handlePendingActions() {
        if viewModel.pendingTimeLimitUnlock {
            viewModel.pendingTimeLimitUnlock = false
            presentTimeLimitChallenge()
            return
        }
        if viewModel.pendingScriptureUnlock {
            viewModel.pendingScriptureUnlock = false
            presentScriptureUnlock()
            return
        }
        if viewModel.pendingOpenSession {
            viewModel.pendingOpenSession = false
            if !viewModel.hasCompletedToday {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showDevotional = true
                }
            }
            return
        }
        if let action = DeepLinkManager.shared.consumeAction() {
            switch action {
            case .scriptureUnlock:
                presentScriptureUnlock()
            case .openSession:
                if !viewModel.hasCompletedToday {
                    showDevotional = true
                }
            case .timeLimitUnlock:
                presentTimeLimitChallenge()
            }
        }

        if ScreenTimeLimitService.shared.isTimeLimitLocked && !ScreenTimeLimitService.shared.wasTimeLimitUnlockedToday() {
            presentTimeLimitChallenge()
        }
    }

    private func presentTimeLimitChallenge() {
        let anySheetOpen = showDevotional || showPrayerSetup || showChat || showVerseExpanded || showDevotionalExpanded || showDeclarationExpanded || showProgressDetail || showAppBlockingFromGodFirst || showScriptureUnlock
        let delay: TimeInterval = anySheetOpen ? 0.6 : 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            showTimeLimitChallenge = true
        }
    }

    private func presentScriptureUnlock() {
        let delay: TimeInterval = (showDevotional || showPrayerSetup || showChat || showVerseExpanded || showDevotionalExpanded || showDeclarationExpanded || showProgressDetail || showAppBlockingFromGodFirst) ? 0.6 : 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            showScriptureUnlock = true
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 { return "\(hours)h" }
        return "\(hours)h \(mins)m"
    }

    @MainActor
    private func shareVerseAsImage() {
        let cardView = ShareableVerseCard(verse: content.verse)
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3
        let text = "\u{201C}\(content.verse.text)\u{201D}\n\n\u{2014} \(content.verse.reference)\n\nShared from God First \u{2728}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"
        if let image = renderer.uiImage {
            shareItems = [image, text]
        } else {
            shareItems = [text]
        }
        showShareSheet = true
    }
}

struct ShareableVerseCard: View {
    let verse: DailyVerse

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.4))

                Text("\u{201C}\(verse.text)\u{201D}")
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)

                Rectangle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 40, height: 2)

                Text(verse.reference)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 28)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 12))
                Text("God First")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(.white.opacity(0.3))
            .padding(.bottom, 24)
        }
        .frame(width: 360, height: 480)
        .background(
            ZStack {
                Color(red: 0.06, green: 0.08, blue: 0.18)
                RadialGradient(
                    colors: [Theme.iceBlue.opacity(0.2), Theme.icePurple.opacity(0.1), .clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 220
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareItemsSheet: UIViewControllerRepresentable {
    let items: [Any]
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            context.coordinator.dismiss()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

    class Coordinator {
        let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }
    }
}
