import SwiftUI
import FamilyControls

struct ScreenTimeLimitSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isEnabled: Bool = ScreenTimeLimitService.shared.isEnabled
    @State private var dailyMinutes: Int = ScreenTimeLimitService.shared.dailyLimitMinutes
    @State private var activitySelection: FamilyActivitySelection = ScreenTimeLimitService.shared.timeLimitSelection
    @State private var showingAppPicker: Bool = false
    @State private var entranceAnimation: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    private let presetMinutes: [Int] = [15, 30, 45, 60, 90, 120]

    private var selectedCount: Int {
        activitySelection.applicationTokens.count + activitySelection.categoryTokens.count
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    headerCard
                        .opacity(entranceAnimation ? 1 : 0)
                        .offset(y: entranceAnimation ? 0 : 20)

                    enableToggleSection
                        .opacity(entranceAnimation ? 1 : 0)
                        .offset(y: entranceAnimation ? 0 : 16)

                    if isEnabled {
                        timeLimitSection
                            .transition(.opacity.combined(with: .move(edge: .top)))

                        appSelectionSection
                            .transition(.opacity.combined(with: .move(edge: .top)))

                        howItWorksSection
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationTitle("Screen Time Limits")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        applySettings()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.iceBlue)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    entranceAnimation = true
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isEnabled)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Theme.dawnAmber.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "hourglass")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.dawnGold, Theme.dawnAmber],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text("Daily Screen Time Limits")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text("Set a daily time limit on chosen apps.\nOnce exceeded, complete a faith challenge to unlock.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.vertical, 20)
    }

    private var enableToggleSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [Theme.dawnGold.opacity(0.15), Theme.dawnAmber.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: "timer")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.dawnAmber)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Screen Time Limits")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(isEnabled ? "Active" : "Disabled")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isEnabled ? Theme.successEmerald : Theme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(Theme.dawnAmber)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            isEnabled ? Theme.dawnAmber.opacity(0.3) : Color.clear,
                            lineWidth: 1.5
                        )
                )
        )
    }

    private var timeLimitSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.dawnGold)
                Text("Daily Time Limit")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(presetMinutes, id: \.self) { minutes in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                dailyMinutes = minutes
                            }
                            let gen = UIImpactFeedbackGenerator(style: .light)
                            gen.impactOccurred()
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(minutes)")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                Text("min")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundStyle(dailyMinutes == minutes ? .white : Theme.textPrimary)
                            .frame(width: 64, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        dailyMinutes == minutes
                                            ? LinearGradient(
                                                colors: [Theme.dawnGold, Theme.dawnAmber],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                              )
                                            : LinearGradient(
                                                colors: [Theme.cardBg, Theme.cardBg],
                                                startPoint: .top,
                                                endPoint: .bottom
                                              )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        dailyMinutes == minutes
                                            ? Color.clear
                                            : Theme.textSecondary.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                            .scaleEffect(dailyMinutes == minutes ? 1.05 : 1.0)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .contentMargins(.horizontal, 0)

            Stepper(value: $dailyMinutes, in: 5...480, step: 5) {
                HStack(spacing: 6) {
                    Text("Custom:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(dailyMinutes) min")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.dawnAmber)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.cardBg)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDark ? Color.white.opacity(0.03) : Color.white.opacity(0.6))
        )
    }

    private var appSelectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "app.badge.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.icePurple)
                Text("Apps to Limit")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }

            Button {
                showingAppPicker = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.icePurple.opacity(0.15), Theme.iceBlue.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)

                        Image(systemName: "apps.iphone")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.icePurple)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Select Apps & Categories")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        if selectedCount > 0 {
                            Text("\(selectedCount) item\(selectedCount == 1 ? "" : "s") selected")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.icePurple)
                        } else {
                            Text("Tap to choose apps to limit")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Theme.cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(
                                    selectedCount > 0 ? Theme.icePurple.opacity(0.3) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                )
            }
            .familyActivityPicker(
                isPresented: $showingAppPicker,
                selection: $activitySelection
            )

            if selectedCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.successEmerald)
                    Text("\(selectedCount) app\(selectedCount == 1 ? "" : "s") will be time-limited")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.successEmerald)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDark ? Color.white.opacity(0.03) : Color.white.opacity(0.6))
        )
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.dawnGold)
                Text("How It Works")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }

            VStack(spacing: 12) {
                howItWorksRow(
                    step: "1",
                    icon: "clock.fill",
                    text: "Use your chosen apps up to the daily limit",
                    color: Theme.iceBlue
                )
                howItWorksRow(
                    step: "2",
                    icon: "shield.fill",
                    text: "Once exceeded, apps lock with a shield",
                    color: Theme.coral
                )
                howItWorksRow(
                    step: "3",
                    icon: "sparkles",
                    text: "Recite scripture or photograph your open Bible",
                    color: Theme.icePurple
                )
                howItWorksRow(
                    step: "4",
                    icon: "lock.open.fill",
                    text: "Complete the challenge to unlock your apps",
                    color: Theme.successEmerald
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDark ? Color.white.opacity(0.03) : Color.white.opacity(0.6))
        )
    }

    private func howItWorksRow(step: String, icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(color)
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }

    private func applySettings() {
        ScreenTimeLimitService.shared.applySettingsAndStartMonitoring(
            selection: activitySelection,
            minutes: dailyMinutes,
            enabled: isEnabled
        )
    }
}
