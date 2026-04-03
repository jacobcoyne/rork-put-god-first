import SwiftUI
import FamilyControls

struct AppBlockingSetupView: View {
    @Bindable var viewModel: AppViewModel
    @State private var step: Int = 0
    @State private var textReveal: [Bool] = Array(repeating: false, count: 6)
    @State private var shieldPulse: Bool = false
    @State private var shieldAppear: Bool = false
    @State private var showingPicker: Bool = false
    @State private var permissionGranted: Bool = false
    @State private var celebrationBurst: Bool = false
    @State private var activitySelection: FamilyActivitySelection = ScreenTimeService.shared.activitySelection

    private let sunriseGold = Color(red: 1.0, green: 0.82, blue: 0.42)
    private let horizonWarm = Color(red: 1.0, green: 0.68, blue: 0.28)

    private var selectedCount: Int {
        activitySelection.applicationTokens.count + activitySelection.categoryTokens.count
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            RadialGradient(
                colors: [
                    Theme.logoIndigo.opacity(shieldPulse ? 0.08 : 0.03),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.15),
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()

            switch step {
            case 0: chooseAppsStep
            case 1: instructionsStep
            case 2: permissionStep
            default: EmptyView()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                shieldPulse = true
            }
            let status = AuthorizationCenter.shared.authorizationStatus
            if status == .approved {
                permissionGranted = true
                ScreenTimeService.shared.isAuthorized = true
            }
        }
    }

    private var chooseAppsStep: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    finishSetup()
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 8)

                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Theme.logoIndigo.opacity(shieldPulse ? 0.2 : 0.08),
                                            Theme.logoBlue.opacity(0.05),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 110, height: 110)
                                .scaleEffect(shieldAppear ? (shieldPulse ? 1.08 : 0.95) : 0.3)

                            Image(systemName: "shield.checkered")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.logoBlue, Theme.logoIndigo],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Theme.logoIndigo.opacity(0.4), radius: 12)
                                .scaleEffect(shieldAppear ? 1 : 0.3)
                                .opacity(shieldAppear ? 1 : 0)
                        }

                        Text("Choose Apps to Block")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .opacity(textReveal[0] ? 1 : 0)
                            .offset(y: textReveal[0] ? 0 : 16)

                        Text("Select apps and categories from your device.\nThey\u{2019}ll be blocked when God First Mode\nis turned on.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 10)
                    }

                    VStack(spacing: 14) {
                        Button {
                            showingPicker = true
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.logoBlue.opacity(0.15), Theme.logoIndigo.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 52, height: 52)

                                    Image(systemName: "apps.iphone")
                                        .font(.system(size: 24))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Theme.logoBlue, Theme.logoIndigo],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Select Apps & Categories")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.textPrimary)

                                    if selectedCount > 0 {
                                        Text("\(selectedCount) item\(selectedCount == 1 ? "" : "s") selected")
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundStyle(Theme.logoBlue)
                                    } else {
                                        Text("Tap to choose from your installed apps")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Theme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(
                                                selectedCount > 0 ? Theme.logoBlue.opacity(0.3) : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                        }
                        .familyActivityPicker(
                            isPresented: $showingPicker,
                            selection: $activitySelection
                        )
                        .onChange(of: activitySelection) { _, newValue in
                            ScreenTimeService.shared.activitySelection = newValue
                        }

                        if selectedCount > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.limeGreen)
                                Text("\(selectedCount) app\(selectedCount == 1 ? "" : "s") & categor\(selectedCount == 1 ? "y" : "ies") will be blocked")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.limeGreen)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .opacity(textReveal[2] ? 1 : 0)
                    .offset(y: textReveal[2] ? 0 : 20)

                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.blueAccent.opacity(0.7))
                        Text("You can change these anytime in Settings.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary.opacity(0.7))
                    }
                    .opacity(textReveal[3] ? 1 : 0)

                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            step = 1
                        }
                        resetTextReveals()
                        revealSequence(count: 5, baseDelay: 0.3, interval: 0.35)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .shadow(color: Theme.logoIndigo.opacity(0.4), radius: 12, y: 6)
                    }
                    .opacity(selectedCount == 0 ? 0.5 : 1.0)
                    .disabled(selectedCount == 0)

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                shieldAppear = true
            }
            revealSequence(count: 4, baseDelay: 0.3, interval: 0.3)
        }
    }

    private var instructionsStep: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { step = 0 }
                    resetTextReveals()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Button {
                    finishSetup()
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 16)

                    VStack(spacing: 14) {
                        Image(systemName: "gearshape.2.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.logoBlue, Theme.logoIndigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .opacity(textReveal[0] ? 1 : 0)
                            .scaleEffect(textReveal[0] ? 1 : 0.5)

                        Text("How App Blocking Works")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .opacity(textReveal[0] ? 1 : 0)
                            .offset(y: textReveal[0] ? 0 : 14)

                        Text("We use Apple\u{2019}s Screen Time to keep you focused.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(textReveal[1] ? 1 : 0)
                    }

                    VStack(spacing: 14) {
                        instructionCard(
                            step: 1,
                            icon: "shield.checkered",
                            title: "Turn On God First Mode",
                            description: "Toggle God First Mode on the Home tab to block distracting apps whenever you want.",
                            color: Theme.logoIndigo,
                            index: 1
                        )
                        instructionCard(
                            step: 2,
                            icon: "sunrise.fill",
                            title: "Complete Your Session",
                            description: "Read your verse, devotional, and pray. When you finish, your apps unlock automatically.",
                            color: sunriseGold,
                            index: 2
                        )
                        instructionCard(
                            step: 3,
                            icon: "mic.fill",
                            title: "Recite Scripture to Unlock",
                            description: "If apps are blocked later, recite a verse aloud to unlock them\u{2014}or simply turn off God First Mode.",
                            color: Theme.limeGreen,
                            index: 3
                        )
                        instructionCard(
                            step: 4,
                            icon: "flame.fill",
                            title: "Build Your Streak",
                            description: "Every day you put God first builds your streak. Watch your spiritual discipline grow stronger.",
                            color: Theme.dawnAmber,
                            index: 4
                        )
                    }

                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.limeGreen)
                            Text("100% private. We never see your data.")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.limeGreen)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "arrow.uturn.left.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.textSecondary.opacity(0.6))
                            Text("You can always override or change apps in Settings.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textSecondary.opacity(0.6))
                        }
                    }
                    .opacity(textReveal[4] ? 1 : 0)

                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            step = 2
                        }
                        resetTextReveals()
                        revealSequence(count: 4, baseDelay: 0.3, interval: 0.4)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Enable App Blocking")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .shadow(color: Theme.logoIndigo.opacity(0.4), radius: 12, y: 6)
                    }

                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var permissionStep: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (permissionGranted ? Theme.limeGreen : Theme.logoIndigo).opacity(shieldPulse ? 0.2 : 0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(shieldPulse ? 1.1 : 0.95)

                    if celebrationBurst {
                        ForEach(0..<12, id: \.self) { i in
                            let angle = Double(i) * 30.0
                            let rad = angle * .pi / 180
                            Circle()
                                .fill([Theme.limeGreen, sunriseGold, Theme.logoBlue, Theme.mint, horizonWarm, Theme.skyBlue][i % 6])
                                .frame(width: CGFloat([4, 5, 3, 6, 4, 5, 3, 4, 6, 3, 5, 4][i]))
                                .offset(
                                    x: celebrationBurst ? cos(rad) * 100 : 0,
                                    y: celebrationBurst ? sin(rad) * 100 : 0
                                )
                                .opacity(celebrationBurst ? 0 : 0.9)
                        }
                    }

                    Image(systemName: permissionGranted ? "checkmark.shield.fill" : "shield.checkered")
                        .font(.system(size: 56, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: permissionGranted
                                    ? [Theme.limeGreen, Theme.mint]
                                    : [Theme.logoBlue, Theme.logoIndigo],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: (permissionGranted ? Theme.limeGreen : Theme.logoIndigo).opacity(0.5), radius: 16)
                        .opacity(textReveal[0] ? 1 : 0)
                        .scaleEffect(textReveal[0] ? 1 : 0.3)
                        .symbolEffect(.bounce, value: permissionGranted)
                }

                VStack(spacing: 14) {
                    Text(permissionGranted ? "You\u{2019}re All Set!" : "One Last Step")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 16)

                    Text(permissionGranted
                         ? "Your \(selectedCount) selected item\(selectedCount == 1 ? "" : "s") will be blocked each morning until you spend time with God."
                         : "Allow Screen Time access so God First can block distracting apps until you\u{2019}ve had your morning time with the Lord.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 10)
                }

                if !permissionGranted {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.blueAccent)
                                .frame(width: 24)
                            Text("Apple will ask for Screen Time permission")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.limeGreen)
                                .frame(width: 24)
                            Text("Tap \u{201C}Allow\u{201D} to enable app blocking")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        HStack(spacing: 10) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.lavender)
                                .frame(width: 24)
                            Text("Your data stays on your device")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Theme.cardBg)
                    )
                    .opacity(textReveal[3] ? 1 : 0)
                    .offset(y: textReveal[3] ? 0 : 12)
                }
            }

            Spacer()

            VStack(spacing: 14) {
                if permissionGranted {
                    Button {
                        ScreenTimeService.shared.activateGodFirstMode()
                        finishSetup()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Let\u{2019}s Put God First")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Theme.limeGreen, Theme.mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .shadow(color: Theme.limeGreen.opacity(0.4), radius: 12, y: 6)
                    }
                } else {
                    Button {
                        requestScreenTimePermission()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 15, weight: .bold))
                            Text("Allow Screen Time Access")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .shadow(color: Theme.logoIndigo.opacity(0.4), radius: 12, y: 6)
                    }

                    Button {
                        finishSetup()
                    } label: {
                        Text("I\u{2019}ll do this later")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 24)
    }

    private func instructionCard(step: Int, icon: String, title: String, description: String, color: Color, index: Int) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("STEP \(step)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(color)
                        .tracking(1)
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
                Text(description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.cardBg)
        )
        .opacity(textReveal[min(index, textReveal.count - 1)] ? 1 : 0)
        .offset(y: textReveal[min(index, textReveal.count - 1)] ? 0 : 14)
    }

    private func requestScreenTimePermission() {
        Task {
            let success = await ScreenTimeService.shared.requestAuthorization()
            if success {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    permissionGranted = true
                }
                withAnimation(.easeOut(duration: 0.8)) {
                    celebrationBurst = true
                }
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)


            } else {
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.error)
            }
        }
    }

    private func finishSetup() {
        let st = ScreenTimeService.shared
        if st.isAuthorized && st.hasAppsSelected {
            st.activateGodFirstMode()
            if !viewModel.hasCompletedToday {
                st.blockApps()
            }
        }
        viewModel.showAppBlockingSetup = false
    }

    private func resetTextReveals() {
        textReveal = Array(repeating: false, count: 6)
    }

    private func revealSequence(count: Int, baseDelay: Double, interval: Double) {
        for i in 0..<min(count, textReveal.count) {
            let delay = baseDelay + Double(i) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.5)) {
                    textReveal[i] = true
                }
                let g = UIImpactFeedbackGenerator(style: .light)
                g.impactOccurred(intensity: 0.4)
            }
        }
    }
}
