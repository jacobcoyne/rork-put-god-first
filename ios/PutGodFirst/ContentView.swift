import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()
    @State private var showLaunchAnimation: Bool = true
    @Environment(\.scenePhase) private var scenePhase

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
                }
                .ignoresSafeArea()
                .zIndex(200)
            }
        }
        .onAppear {
            handlePendingDeepLink()
            ensureInitialLocking()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                let st = ScreenTimeService.shared
                st.refreshAuthStatus()
                st.refreshBlockingState()
                viewModel.checkDailyReset()

                if st.isAuthorized && (st.godFirstModeActive || st.godFirstModeEnrolled) {
                    st.scheduleAllMonitoring()
                    if !viewModel.hasCompletedToday {
                        st.blockApps()
                    }
                }

                NotificationService.cancelTodayNotifications()
                NotificationService.scheduleMidnightRelockNotifications()
                handlePendingDeepLink()
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

    private func ensureInitialLocking() {
        let st = ScreenTimeService.shared
        if st.isAuthorized && st.hasAppsSelected && (st.godFirstModeActive || st.godFirstModeEnrolled) {
            if !viewModel.hasCompletedToday {
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
        case .scriptureUnlock, .openSession:
            viewModel.pendingScriptureUnlock = true
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
                Tab("Chat", systemImage: "bubble.left.fill", value: 3) {
                    GuideChatView()
                }
                Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                    SettingsView(viewModel: viewModel)
                }
            }
            .tint(Theme.iceBlue)

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
    }
}
