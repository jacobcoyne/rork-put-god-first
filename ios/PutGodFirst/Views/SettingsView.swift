import SwiftUI
import FamilyControls
import AuthenticationServices
import RevenueCat

struct SettingsView: View {
    @Bindable var viewModel: AppViewModel
    @State private var showResetAlert: Bool = false
    @State private var showSignOutAlert: Bool = false
    @State private var showDeleteAccountAlert: Bool = false
    @State private var showingAppPicker: Bool = false
    @State private var isPurchasingLifetime: Bool = false
    @State private var showLifetimeError: Bool = false
    @State private var lifetimeErrorMessage: String = ""
    @State private var activitySelection: FamilyActivitySelection = ScreenTimeService.shared.activitySelection
    @State private var morningReminderTime: Date = NotificationService.savedReminderTime
    @State private var showTimePicker: Bool = false
    @State private var showScreenTimeLimitSettings: Bool = false

    private let authService = AuthenticationService.shared

    var body: some View {
        NavigationStack {
            List {
                accountSection
                progressSection
                scriptureUnlockSection
                screenTimeLimitSection
                sessionSection
                notificationsSection
                screenTimeSection
                subscriptionSection
                shareSection
                legalSection
                resetSection
                dangerZoneSection
            }
            .background(Theme.bg)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Onboarding?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    viewModel.hasCompletedOnboarding = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will show the onboarding flow again.")
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
            .alert("Sign Out?", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can sign back in anytime with your Apple ID.")
            }
            .alert("Delete Account?", isPresented: $showDeleteAccountAlert) {
                Button("Delete", role: .destructive) {
                    authService.deleteAccount()
                    viewModel.hasCompletedOnboarding = false
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and erase all your data, including streaks, progress, and preferences. This cannot be undone.")
            }
            .sheet(isPresented: $showScreenTimeLimitSettings) {
                ScreenTimeLimitSettingsView()
            }
            .alert("Purchase Error", isPresented: $showLifetimeError) {
                Button("OK") {}
            } message: {
                Text(lifetimeErrorMessage)
            }
            .onAppear {
                authService.checkCredentialState()
            }
            .task {
                if SubscriptionService.shared.offerings == nil {
                    await SubscriptionService.shared.fetchOfferings()
                }
            }
            .onChange(of: authService.isSignedIn) { _, newValue in
                if newValue && !authService.userDisplayName.isEmpty {
                    viewModel.userName = authService.userDisplayName
                }
            }
        }
    }

    private var accountSection: some View {
        Section {
            if authService.isSignedIn {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.icePurple)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(authService.userDisplayName.isEmpty ? "Apple ID User" : authService.userDisplayName)
                            .font(.system(size: 16, weight: .semibold))
                        if !authService.userEmail.isEmpty {
                            Text(authService.userEmail)
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.green)
                }

                Button(role: .destructive) {
                    showSignOutAlert = true
                } label: {
                    HStack {
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14))
                    }
                }
            } else {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    authService.handleSignInResult(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }
        } header: {
            Text("Account")
                .font(.system(size: 13, weight: .bold))
        }
    }

    private var progressSection: some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Text("Current Streak")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Text("\(viewModel.currentStreak) days")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 12) {
                Image(systemName: "cross.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.dawnGold, Theme.dawnAmber],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Text("Total Days")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Text("\(viewModel.totalDaysCompleted)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.iceLavender)
            }
        } header: {
            Text("Progress")
                .font(.system(size: 13, weight: .bold))
        }
    }

    private var scriptureUnlockSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { ScriptureUnlockService.shared.isEnabled },
                set: { ScriptureUnlockService.shared.isEnabled = $0 }
            )) {
                HStack(spacing: 12) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.52, green: 0.35, blue: 0.95))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scripture Unlock")
                            .font(.system(size: 16, weight: .medium))
                        Text("Recite a verse to re-unlock apps")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .tint(Color(red: 0.52, green: 0.35, blue: 0.95))
        } header: {
            Text("Scripture Memorization")
                .font(.system(size: 13, weight: .bold))
        } footer: {
            Text("After completing your morning session, recite scripture aloud to unlock apps again later in the day.")
                .font(.system(size: 12))
        }
    }

    private var screenTimeLimitSection: some View {
        Section {
            Button {
                showScreenTimeLimitSettings = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.dawnAmber)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Screen Time Limits")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)
                        Text(ScreenTimeLimitService.shared.isEnabled ? "\(ScreenTimeLimitService.shared.dailyLimitMinutes) min daily limit" : "Set daily app time limits")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(ScreenTimeLimitService.shared.isEnabled ? Theme.dawnAmber : Theme.textSecondary)
                    }
                    Spacer()
                    if ScreenTimeLimitService.shared.isEnabled {
                        Text("On")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Theme.successEmerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.successEmerald.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }

            if ScreenTimeLimitService.shared.isTimeLimitLocked {
                HStack(spacing: 10) {
                    Image(systemName: "hourglass.tophalf.filled")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.dawnAmber)
                    Text("Time limit exceeded \u{2014} challenge required")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.dawnAmber)
                    Spacer()
                }
                .listRowBackground(Theme.dawnAmber.opacity(0.08))
            }
        } header: {
            Text("Screen Time Limits")
                .font(.system(size: 13, weight: .bold))
        } footer: {
            Text("Limit daily usage on chosen apps. Exceed the limit and you\u{2019}ll need to recite scripture or photograph your open Bible to unlock.")
                .font(.system(size: 12))
        }
    }

    private var sessionSection: some View {
        Section {
            HStack {
                Label("Prayer Duration", systemImage: "clock")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Text("\(viewModel.prayerDurationMinutes) min")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.prayerTeal)
            }

            Picker("Prayer Mode", selection: $viewModel.selectedPrayerMode) {
                ForEach(PrayerMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .font(.system(size: 16, weight: .medium))
        } header: {
            Text("Session")
                .font(.system(size: 13, weight: .bold))
        }
    }

    private var notificationsSection: some View {
        Section {
            Button {
                withAnimation { showTimePicker.toggle() }
            } label: {
                HStack {
                    Label("Morning Reminder", systemImage: "bell")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(morningReminderTime, format: .dateTime.hour().minute())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                        .rotationEffect(.degrees(showTimePicker ? 90 : 0))
                }
            }

            if showTimePicker {
                DatePicker("Reminder Time", selection: $morningReminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .onChange(of: morningReminderTime) { _, newValue in
                        NotificationService.saveReminderTime(newValue)
                        NotificationService.scheduleAllNotifications()
                    }
            }
        } header: {
            Text("Notifications")
                .font(.system(size: 13, weight: .bold))
        }
    }

    private var screenTimeSection: some View {
        Section {
            if ScreenTimeService.shared.isAuthorized {
                Button {
                    showingAppPicker = true
                } label: {
                    HStack {
                        HStack(spacing: 12) {
                            Image(systemName: "app.badge.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.dawnAmber)
                            Text("Blocked Apps")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        Spacer()
                        let count = activitySelection.applicationTokens.count + activitySelection.categoryTokens.count
                        Text(count > 0 ? "\(count) selected" : "None")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                }
                .familyActivityPicker(
                    isPresented: $showingAppPicker,
                    selection: $activitySelection
                )
                .onChange(of: activitySelection) { _, newValue in
                    ScreenTimeService.shared.activitySelection = newValue
                    if ScreenTimeService.shared.godFirstModeActive {
                        ScreenTimeService.shared.blockApps()
                    }
                }

                if ScreenTimeService.shared.isBlocking {
                    HStack(spacing: 10) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.coral)
                        Text("Apps are currently blocked")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.coral)
                        Spacer()
                    }
                    .listRowBackground(Theme.coral.opacity(0.08))
                }
            } else {
                Button {
                    Task {
                        await ScreenTimeService.shared.requestAuthorization()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.dawnAmber)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable App Blocking")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.textPrimary)
                            Text("Block distracting apps with God First Mode")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
            }
        } header: {
            Text("Screen Time")
                .font(.system(size: 13, weight: .bold))
        } footer: {
            Text("Use the God First Mode toggle on the Home tab to block and unblock apps. Recite scripture to unlock when blocked.")
                .font(.system(size: 12))
        }
    }

    private var subscriptionSection: some View {
        Section {
            if SubscriptionService.shared.isLifetimeUser {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.dawnGold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("God First Pro")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Lifetime access")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.successEmerald)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.green)
                }
            } else if SubscriptionService.shared.isProUser {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.dawnGold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("God First Pro")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Active subscription")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.green)
                }

                Button {
                    Task { await purchaseLifetime() }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "infinity")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.dawnGold)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Lifetime")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text(lifetimePriceLabel)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        if isPurchasingLifetime {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textSecondary.opacity(0.4))
                        }
                    }
                }
                .disabled(isPurchasingLifetime)
            } else {
                Button {
                    viewModel.showPaywall = true
                } label: {
                    HStack {
                        Label("Upgrade to God First Pro", systemImage: "crown")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                }

                Button {
                    Task { await purchaseLifetime() }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "infinity")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.dawnGold)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Get Lifetime Access")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text(lifetimePriceLabel)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        if isPurchasingLifetime {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textSecondary.opacity(0.4))
                        }
                    }
                }
                .disabled(isPurchasingLifetime)
            }

            Button("Restore Purchases") {
                Task {
                    _ = await SubscriptionService.shared.restorePurchases()
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Theme.icePurple)
        } header: {
            Text("Subscription")
                .font(.system(size: 13, weight: .bold))
        }
    }



    private var shareSection: some View {
        Section {
            Button {
                viewModel.requestReview()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.yellow)
                    Text("Rate God First")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }

            Button {
                let text = "I\u{2019}m putting God first every morning with the God First app \u{2728}\n\nJoin me and start your mornings with God \u{1F64F}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"
                let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = windowScene.windows.first?.rootViewController {
                    root.present(activityVC, animated: true)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.icePurple)
                    Text("Share with a Friend")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
        } header: {
            Text("Share the Love")
                .font(.system(size: 13, weight: .bold))
        }
    }

    private var legalSection: some View {
        Section {
            Link(destination: URL(string: "https://www.putgodfirstapp.com/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }

            Link(destination: URL(string: "https://www.putgodfirstapp.com/terms")!) {
                HStack {
                    Text("Terms of Use")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
        } header: {
            Text("Legal")
                .font(.system(size: 13, weight: .bold))
        }
    }

    private var resetSection: some View {
        Section {
            Button("Reset Onboarding") {
                showResetAlert = true
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private var dangerZoneSection: some View {
        if authService.isSignedIn {
            Section {
                Button(role: .destructive) {
                    showDeleteAccountAlert = true
                } label: {
                    HStack {
                        Label("Delete Account", systemImage: "person.crop.circle.badge.minus")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                }
            } header: {
                Text("Danger Zone")
                    .font(.system(size: 13, weight: .bold))
            } footer: {
                Text("Permanently deletes your account and all associated data. This action cannot be undone.")
                    .font(.system(size: 12))
            }
        }
    }

    private var lifetimePriceLabel: String {
        if let pkg = SubscriptionService.shared.lifetimePackage {
            return "One-time payment of \(pkg.storeProduct.localizedPriceString)"
        }
        return "One-time payment of $99.99"
    }

    private func purchaseLifetime() async {
        guard let pkg = SubscriptionService.shared.lifetimePackage else {
            if SubscriptionService.shared.offerings == nil {
                await SubscriptionService.shared.fetchOfferings()
            }
            if SubscriptionService.shared.lifetimePackage == nil {
                lifetimeErrorMessage = "Unable to load lifetime option. Please try again."
                showLifetimeError = true
            }
            return
        }
        isPurchasingLifetime = true
        let success = await SubscriptionService.shared.purchase(package: pkg)
        isPurchasingLifetime = false
        if !success, let err = SubscriptionService.shared.errorMessage {
            lifetimeErrorMessage = err
            showLifetimeError = true
            SubscriptionService.shared.errorMessage = nil
        }
    }
}
