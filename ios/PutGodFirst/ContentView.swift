import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @State private var showLaunchAnimation: Bool = true
    @State private var showScreenTimeLimitOnboarding: Bool = false
    @State private var showAppLockingReminder: Bool = false
    @State private var showNotificationReminder: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    private let screenTimeLimitOnboardingKey = "hasSeenScreenTimeLimitOnboarding"
    private let lastLaunchedVersionKey = "lastLaunchedAppVersion"

    var body: some View {
        ZStack {
            Group {
                if viewModel.hasCompletedOnboarding {
                    if viewModel.showAppBlockingSetup {
                        AppBlockingSetupView(viewModel: viewModel)
                    } else {
                        MainTabView(viewModel: viewModel)
                    }
                } else {
                    OnboardingView(viewModel: viewModel)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.hasCompletedOnboarding)
            .animation(.easeInOut(duration: 0.4), value: viewModel.showAppBlockingSetup)

            if showLaunchAnimation && viewModel.hasCompletedOnboarding && !viewModel.showAppBlockingSetup {
                LaunchAnimationView {
                    showLaunchAnimation = false
                    checkScreenTimeLimitOnboarding()
                    checkAppUpdateLockingReminder()
                    checkNotificationPermissionReminder()
                }
                .ignoresSafeArea()
                .zIndex(200)
            }
        }
        .alert("Enable Notifications?", isPresented: $showNotificationReminder) {
            Button("Enable") {
                NotificationService.requestPermission()
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("Turn on notifications so you never miss your morning reminder to put God first.")
        }
        .alert("Enable App Locking?", isPresented: $showAppLockingReminder) {
            Button("Enable") {
                viewModel.showAppBlockingSetup = true
            }
            Button("Not Now", role: .cancel) {}
        } message: {
            Text("Lock your apps every morning until you spend time with God. This is the best way to build a daily habit of putting God first.")
        }
        .fullScreenCover(isPresented: $showScreenTimeLimitOnboarding) {
            ScreenTimeLimitOnboardingView(
                onEnable: {
                    UserDefaults.standard.set(true, forKey: screenTimeLimitOnboardingKey)
                    showScreenTimeLimitOnboarding = false
                    viewModel.showScreenTimeLimitOnboarding = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        viewModel.pendingTimeLimitUnlock = false
                        navigateToScreenTimeLimitSettings()
                    }
                },
                onSkip: {
                    UserDefaults.standard.set(true, forKey: screenTimeLimitOnboardingKey)
                    showScreenTimeLimitOnboarding = false
                    viewModel.showScreenTimeLimitOnboarding = false
                }
            )
        }
        .onAppear {
            handlePendingDeepLink()
            ensureInitialLocking()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                performForegroundEnforcement()
                NotificationService.cancelTodayNotifications()
                handlePendingDeepLink()
                BackgroundEnforcementService.scheduleAll()
            } else if newPhase == .background {
                BackgroundEnforcementService.scheduleAll()
            }
        }
        .onChange(of: DeepLinkManager.shared.pendingAction) { _, newAction in
            if newAction != nil {
                handlePendingDeepLink()
            }
        }
        .onChange(of: viewModel.showAppBlockingSetup) { _, newValue in
            if !newValue && viewModel.hasCompletedOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ensureInitialLocking()
                }
            }
        }
    }

    private func performForegroundEnforcement() {
        let st = ScreenTimeService.shared
        st.refreshAuthStatus()
        st.refreshBlockingState()
        viewModel.checkDailyReset()

        if st.isAuthorized && (st.godFirstModeActive || st.godFirstModeEnrolled) {
            st.clearStaleData()
            if !viewModel.hasCompletedToday && !st.wasScriptureUnlockedToday() {
                st.blockApps()
            }
            st.scheduleAllMonitoring()
        }

        let stl = ScreenTimeLimitService.shared
        stl.checkAndEnforceFromForeground()
        if stl.isEnabled && stl.isTimeLimitLocked && !stl.wasTimeLimitUnlockedToday() {
            stl.lockTimeLimitedApps()
            if DeepLinkManager.shared.pendingAction == nil {
                DeepLinkManager.shared.pendingAction = .timeLimitUnlock
            }
        }
    }

    private func ensureInitialLocking() {
        let st = ScreenTimeService.shared
        if st.isAuthorized && st.hasAppsSelected && (st.godFirstModeActive || st.godFirstModeEnrolled) {
            if !viewModel.hasCompletedToday && !st.wasScriptureUnlockedToday() {
                st.blockApps()
                st.scheduleAllMonitoring()
            } else {
                st.scheduleAllMonitoring()
            }
        } else if st.isAuthorized && st.godFirstModeEnrolled && !st.hasAppsSelected {
            st.scheduleAllMonitoring()
        }
    }

    private func handlePendingDeepLink() {
        guard let action = DeepLinkManager.shared.consumeAction() else { return }
        switch action {
        case .scriptureUnlock:
            viewModel.pendingScriptureUnlock = true
        case .openSession:
            viewModel.pendingOpenSession = true
        case .timeLimitUnlock:
            viewModel.pendingTimeLimitUnlock = true
        }
    }

    private func checkScreenTimeLimitOnboarding() {
        let hasSeen = UserDefaults.standard.bool(forKey: screenTimeLimitOnboardingKey)
        if !hasSeen && viewModel.hasCompletedOnboarding && !ScreenTimeLimitService.shared.isEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showScreenTimeLimitOnboarding = true
            }
        }
    }

    private func navigateToScreenTimeLimitSettings() {
        viewModel.showScreenTimeLimitOnboarding = true
    }

    private func checkAppUpdateLockingReminder() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let lastVersion = UserDefaults.standard.string(forKey: lastLaunchedVersionKey)

        UserDefaults.standard.set(currentVersion, forKey: lastLaunchedVersionKey)

        guard let lastVersion, lastVersion != currentVersion else { return }
        guard viewModel.hasCompletedOnboarding else { return }

        let st = ScreenTimeService.shared
        let isLockingEnabled = st.godFirstModeActive || st.godFirstModeEnrolled
        if !isLockingEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showAppLockingReminder = true
            }
        }
    }

    private func checkNotificationPermissionReminder() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let lastVersion = UserDefaults.standard.string(forKey: lastLaunchedVersionKey)

        guard let lastVersion, lastVersion != currentVersion else { return }
        guard viewModel.hasCompletedOnboarding else { return }

        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            if settings.authorizationStatus != .authorized {
                try? await Task.sleep(for: .seconds(showAppLockingReminder ? 2.5 : 1.5))
                showNotificationReminder = true
            }
        }
    }
}

struct LatinCrossShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let armThickness = w * 0.28
        let crossbarY = h * 0.28
        let crossbarHeight = armThickness
        let verticalX = (w - armThickness) / 2
        path.addRoundedRect(in: CGRect(x: verticalX, y: 0, width: armThickness, height: h), cornerSize: CGSize(width: armThickness * 0.2, height: armThickness * 0.2))
        path.addRoundedRect(in: CGRect(x: 0, y: crossbarY, width: w, height: crossbarHeight), cornerSize: CGSize(width: crossbarHeight * 0.2, height: crossbarHeight * 0.2))
        return path
    }
}

struct MainTabView: View {
    @Bindable var viewModel: AppViewModel
    @State private var selectedTab: Int = 0
    @State private var showTimeLimitChallenge: Bool = false
    @State private var showScreenTimeLimitSettings: Bool = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: 0) {
                    TodayView(viewModel: viewModel)
                }
                Tab("Bible", systemImage: "book.closed.fill", value: 1) {
                    BibleView()
                }
                Tab(value: 2) {
                    PrayerLibraryView(viewModel: viewModel)
                } label: {
                    Label {
                        Text("Prayers")
                    } icon: {
                        Image(size: CGSize(width: 22, height: 26)) { ctx in
                            ctx.fill(LatinCrossShape().path(in: CGRect(origin: .zero, size: CGSize(width: 22, height: 26))), with: .foreground)
                        }
                        .renderingMode(.template)
                    }
                }
                Tab("Activity", systemImage: "shield.lefthalf.filled", value: 3) {
                    ActivityView(viewModel: viewModel)
                }
                Tab("Chat", systemImage: "bubble.left.fill", value: 4) {
                    GuideChatView()
                }
                Tab("Settings", systemImage: "gearshape.fill", value: 5) {
                    SettingsView(viewModel: viewModel)
                }
            }
            .tint(Theme.iceBlue)
            .onChange(of: viewModel.pendingScriptureUnlock) { _, newValue in
                if newValue {
                    selectedTab = 0
                }
            }
            .onChange(of: viewModel.pendingOpenSession) { _, newValue in
                if newValue {
                    selectedTab = 0
                }
            }
            .onChange(of: viewModel.pendingTimeLimitUnlock) { _, newValue in
                if newValue {
                    viewModel.pendingTimeLimitUnlock = false
                    presentTimeLimitChallenge()
                }
            }

            if viewModel.showCompletionPopup {
                CompletionPopup(viewModel: viewModel) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        viewModel.showCompletionPopup = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(100)
            }
        }
        .sheet(isPresented: $showTimeLimitChallenge) {
            TimeLimitChallengeView {
                ScreenTimeLimitService.shared.unlockWithChallenge()
                ScreenTimeService.shared.refreshBlockingState()
            }
        }
        .sheet(isPresented: $showScreenTimeLimitSettings) {
            ScreenTimeLimitSettingsView()
        }
        .onChange(of: viewModel.showScreenTimeLimitOnboarding) { _, newValue in
            if newValue {
                viewModel.showScreenTimeLimitOnboarding = false
                selectedTab = 5
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showScreenTimeLimitSettings = true
                }
            }
        }
        .onAppear {
            if ScreenTimeLimitService.shared.isTimeLimitLocked && !ScreenTimeLimitService.shared.wasTimeLimitUnlockedToday() {
                presentTimeLimitChallenge()
            }
        }
    }

    private func presentTimeLimitChallenge() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showTimeLimitChallenge = true
        }
    }
}
