import SwiftUI
import FamilyControls

struct ActivityView: View {
    @Bindable var viewModel: AppViewModel
    @State private var pulseGlow: Bool = false
    @State private var ringRotation: Double = 0
    @State private var showScriptureUnlock: Bool = false
    @State private var showDevotional: Bool = false
    @State private var showAppBlockingSetup: Bool = false
    @State private var currentLockMessage: ActivityLockMessage = ActivityLockMessage.all[0]
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }
    private var isLocked: Bool { ScreenTimeService.shared.isBlocking }
    private var isGodFirstActive: Bool { ScreenTimeService.shared.godFirstModeActive || ScreenTimeService.shared.godFirstModeEnrolled }

    private var selectedAppCount: Int {
        ScreenTimeService.shared.activitySelection.applicationTokens.count + ScreenTimeService.shared.activitySelection.categoryTokens.count
    }

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                activityContent(now: context.date)
            }
            .background(activityBg)
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { pulseGlow = true }
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) { ringRotation = 360 }
                currentLockMessage = ActivityLockMessage.all.randomElement() ?? ActivityLockMessage.all[0]
            }
        }
        .sheet(isPresented: $showScriptureUnlock) {
            ScriptureUnlockView { ScreenTimeService.shared.refreshBlockingState() }
        }
        .fullScreenCover(isPresented: $showDevotional) {
            DevotionalReadingView(
                devotional: viewModel.todayContent.devotional,
                verse: viewModel.todayContent.verse,
                onDismiss: { showDevotional = false },
                onComplete: { showDevotional = false; viewModel.completeSession() }
            )
        }
        .sheet(isPresented: $showAppBlockingSetup) {
            GodFirstModeSetupSheet {
                if ScreenTimeService.shared.hasAppsSelected { ScreenTimeService.shared.activateGodFirstMode() }
            }
        }
    }

    private func activityContent(now: Date) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                timerHero(now: now).padding(.top, 8).padding(.bottom, 24)
                statusCard.padding(.horizontal, 20).padding(.bottom, 16)
                if isLocked && !viewModel.hasCompletedToday {
                    unlockActions.padding(.horizontal, 20).padding(.bottom, 16)
                } else if !isGodFirstActive {
                    enableCard.padding(.horizontal, 20).padding(.bottom, 16)
                }
                todayTimeline.padding(.horizontal, 20).padding(.bottom, 16)
                lockInfoCard.padding(.horizontal, 20).padding(.bottom, 60)
            }
        }
    }

    // MARK: - Timer Hero

    private func timerHero(now: Date) -> some View {
        let lockColor = Color(red: 0.85, green: 0.22, blue: 0.28)
        let activeColor = isLocked ? lockColor : Theme.successEmerald
        let t = now.timeIntervalSince(Calendar.current.startOfDay(for: now))
        let timerStr = String(format: "%d:%02d:%02d", Int(t) / 3600, (Int(t) % 3600) / 60, Int(t) % 60)
        let hour = Calendar.current.component(.hour, from: now)
        let greeting = hour < 5 ? "Late Night" : hour < 12 ? "Morning" : hour < 17 ? "Afternoon" : hour < 21 ? "Evening" : "Night"

        return VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [activeColor.opacity(pulseGlow ? 0.15 : 0.05), .clear], center: .center, startRadius: 40, endRadius: 140))
                    .frame(width: 280, height: 280)

                Circle()
                    .stroke(
                        AngularGradient(colors: [activeColor.opacity(0.6), activeColor.opacity(0.2), activeColor.opacity(0.6)], center: .center),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 4])
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(ringRotation))

                Circle()
                    .stroke(activeColor.opacity(isDark ? 0.15 : 0.10), lineWidth: 1.5)
                    .frame(width: 200, height: 200)

                VStack(spacing: 8) {
                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(activeColor)
                        .contentTransition(.symbolEffect(.replace.downUp.byLayer))
                        .shadow(color: activeColor.opacity(0.4), radius: 8)

                    if isLocked && !viewModel.hasCompletedToday {
                        Text(timerStr)
                            .font(.system(size: 42, weight: .black, design: .monospaced))
                            .foregroundStyle(Theme.textPrimary)
                            .contentTransition(.numericText(countsDown: false))
                    } else if viewModel.hasCompletedToday {
                        Text("Done")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.successEmerald)
                    } else {
                        Text("--:--")
                            .font(.system(size: 42, weight: .black, design: .monospaced))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }

                    Text(isLocked ? "LOCKED SINCE MIDNIGHT" : (viewModel.hasCompletedToday ? "GOD FIRST \u{2714}\u{FE0F}" : "APPS UNLOCKED"))
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(activeColor)
                        .tracking(2.0)
                }
            }

            HStack(spacing: 24) {
                activityStat(value: "\(selectedAppCount)", label: selectedAppCount == 1 ? "App" : "Apps", icon: "app.badge.fill", color: Theme.icePurple)
                activityStat(value: "\(viewModel.currentStreak)", label: "Streak", icon: "flame.fill", color: Theme.dawnAmber)
                activityStat(value: greeting, label: "Session", icon: "clock.fill", color: Theme.iceBlue)
            }
            .padding(.top, 4)
        }
    }

    private func activityStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(color.opacity(isDark ? 0.12 : 0.10)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(color)
            }
            Text(value).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.textPrimary).lineLimit(1).minimumScaleFactor(0.7)
            Text(label.uppercased()).font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.textSecondary).tracking(0.8)
        }
        .frame(width: 80)
    }

    // MARK: - Status Card

    private var statusCard: some View {
        let msg: (String, String, String, String) = {
            if !isGodFirstActive {
                return ("\u{1F6E1}\u{FE0F}", "God First Mode Inactive", "Enable to lock apps until your morning session", "Set it up and never miss a morning with God")
            }
            if viewModel.hasCompletedToday {
                return ("\u{2705}", "Session Complete", "You put God first today!", "Apps unlocked \u{2022} Walk in peace \u{1F54A}\u{FE0F}")
            }
            if isLocked {
                let m = currentLockMessage
                return (m.emoji, m.title, m.subtitle, m.detail)
            }
            return ("\u{1F513}", "Apps Unlocked", "Complete your session to keep the streak", "Don\u{2019}t forget to put God first today")
        }()

        let accentColor = isLocked && !viewModel.hasCompletedToday
            ? Color(red: 0.85, green: 0.22, blue: 0.28)
            : (viewModel.hasCompletedToday ? Theme.successEmerald : Theme.iceBlue)

        return HStack(spacing: 14) {
            Text(msg.0).font(.system(size: 36))
            VStack(alignment: .leading, spacing: 4) {
                Text(msg.1).font(.system(size: 17, weight: .bold)).foregroundStyle(Theme.textPrimary)
                Text(msg.2).font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.textSecondary).fixedSize(horizontal: false, vertical: true)
                Text(msg.3).font(.system(size: 11, weight: .medium)).foregroundStyle(Theme.textSecondary.opacity(0.7)).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [accentColor.opacity(isDark ? 0.16 : 0.12), accentColor.opacity(isDark ? 0.06 : 0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 20).strokeBorder(accentColor.opacity(isDark ? 0.30 : 0.20), lineWidth: 0.8)
            }
            .shadow(color: accentColor.opacity(isDark ? 0.10 : 0.08), radius: 14, y: 4)
        )
    }

    // MARK: - Unlock Actions

    private var unlockActions: some View {
        VStack(spacing: 10) {
            Button { showDevotional = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sunrise.fill").font(.system(size: 18))
                    Text("Start Morning Session").font(.system(size: 16, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 18).padding(.vertical, 16)
                .background(
                    Capsule().fill(LinearGradient(colors: [Color(red: 0.28, green: 0.52, blue: 0.98), Color(red: 0.40, green: 0.28, blue: 0.90)], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: Color(red: 0.32, green: 0.42, blue: 0.95).opacity(0.30), radius: 12, y: 5)
                )
            }

            Button { showScriptureUnlock = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "mic.fill").font(.system(size: 16))
                    Text("Recite Scripture to Unlock").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textSecondary.opacity(0.5))
                }
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 18).padding(.vertical, 14)
                .background(
                    Capsule().fill(isDark ? Theme.cardBg : Color(red: 0.96, green: 0.95, blue: 0.93))
                        .overlay(Capsule().strokeBorder(Theme.darkCardBorder, lineWidth: 0.8))
                )
            }
        }
    }

    // MARK: - Enable Card

    private var enableCard: some View {
        Button { showAppBlockingSetup = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Theme.icePurple.opacity(0.12)).frame(width: 48, height: 48)
                    Image(systemName: "shield.lefthalf.filled").font(.system(size: 20, weight: .semibold)).foregroundStyle(Theme.icePurple)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Enable God First Mode").font(.system(size: 16, weight: .bold)).foregroundStyle(Theme.textPrimary)
                    Text("Lock apps until you complete your morning session").font(.system(size: 12, weight: .medium)).foregroundStyle(Theme.textSecondary).fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textSecondary)
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                    RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [Theme.icePurple.opacity(isDark ? 0.14 : 0.10), Theme.iceBlue.opacity(isDark ? 0.08 : 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.icePurple.opacity(isDark ? 0.25 : 0.18), lineWidth: 0.8)
                }
                .shadow(color: Theme.icePurple.opacity(isDark ? 0.10 : 0.08), radius: 14, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today Timeline

    private var todayTimeline: some View {
        let dateStr: String = {
            let f = DateFormatter(); f.dateFormat = "EEEE, MMM d"; return f.string(from: Date())
        }()

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("TODAY\u{2019}S TIMELINE").font(.system(size: 11, weight: .black)).foregroundStyle(Theme.textSecondary).tracking(1.2)
                Spacer()
                Text(dateStr).font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.textSecondary.opacity(0.7))
            }

            VStack(spacing: 0) {
                activityTimelineRow(time: "12:00 AM", event: "Apps Locked Automatically", icon: "lock.fill", color: Color(red: 0.85, green: 0.22, blue: 0.28), isActive: isGodFirstActive, showLine: true)

                if viewModel.hasCompletedToday {
                    let ft: String = { let f = DateFormatter(); f.dateFormat = "h:mm a"; return f.string(from: viewModel.lastCompletedDate ?? .now) }()
                    activityTimelineRow(time: ft, event: "Session Completed \u{2728}", icon: "checkmark.seal.fill", color: Theme.successEmerald, isActive: true, showLine: true)
                    activityTimelineRow(time: ft, event: "Apps Unlocked", icon: "lock.open.fill", color: Theme.successEmerald, isActive: true, showLine: false)
                } else if ScreenTimeService.shared.wasScriptureUnlockedToday() {
                    activityTimelineRow(time: "Earlier", event: "Scripture Unlock \u{1F399}\u{FE0F}", icon: "waveform", color: Theme.icePurple, isActive: true, showLine: false)
                } else if isLocked {
                    activityTimelineRow(time: "Now", event: "Waiting for Session...", icon: "hourglass", color: Theme.dawnAmber, isActive: true, showLine: false)
                } else {
                    activityTimelineRow(time: "Tomorrow", event: "Apps Lock at Midnight", icon: "moon.fill", color: Theme.textSecondary.opacity(0.5), isActive: false, showLine: false)
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.darkCardBorder, lineWidth: 0.8)
            }
            .shadow(color: .black.opacity(isDark ? 0.15 : 0.06), radius: 12, y: 4)
        )
    }

    private func activityTimelineRow(time: String, event: String, icon: String, color: Color, isActive: Bool, showLine: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(color.opacity(isActive ? 0.15 : 0.06)).frame(width: 32, height: 32)
                    Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundStyle(color.opacity(isActive ? 1.0 : 0.4))
                }
                if showLine { Rectangle().fill(color.opacity(isActive ? 0.20 : 0.08)).frame(width: 2, height: 24) }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(event).font(.system(size: 14, weight: .semibold)).foregroundStyle(isActive ? Theme.textPrimary : Theme.textSecondary.opacity(0.6))
                Text(time).font(.system(size: 12, weight: .medium)).foregroundStyle(Theme.textSecondary.opacity(isActive ? 0.8 : 0.4))
            }
            .padding(.top, 5)
            Spacer()
        }
    }

    // MARK: - Lock Info

    private var lockInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill").font(.system(size: 14)).foregroundStyle(Theme.iceBlue)
                Text("HOW IT WORKS").font(.system(size: 11, weight: .black)).foregroundStyle(Theme.textSecondary).tracking(1.2)
            }
            VStack(alignment: .leading, spacing: 10) {
                activityInfoRow(text: "At midnight, your selected apps lock automatically", emoji: "\u{1F319}")
                activityInfoRow(text: "Complete your morning session or recite scripture", emoji: "\u{1F4D6}")
                activityInfoRow(text: "Apps unlock for the rest of the day", emoji: "\u{1F513}")
                activityInfoRow(text: "Repeat tomorrow \u{2014} build your streak!", emoji: "\u{1F525}")
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(isDark ? Theme.cardBg : Color(red: 0.99, green: 0.98, blue: 0.96))
                RoundedRectangle(cornerRadius: 20).fill(LinearGradient(colors: [Theme.iceBlue.opacity(isDark ? 0.10 : 0.06), Theme.icePurple.opacity(isDark ? 0.06 : 0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.iceBlue.opacity(isDark ? 0.20 : 0.14), lineWidth: 0.8)
            }
            .shadow(color: Theme.iceBlue.opacity(isDark ? 0.08 : 0.06), radius: 12, y: 4)
        )
    }

    private func activityInfoRow(text: String, emoji: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(emoji).font(.system(size: 16)).frame(width: 24)
            Text(text).font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.textPrimary.opacity(0.85)).fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Background

    private var activityBg: some View {
        ZStack {
            let accent = (isLocked ? Color(red: 0.85, green: 0.22, blue: 0.28) : Theme.successEmerald)
            if isDark {
                LinearGradient(colors: [Color(red: 0.02, green: 0.02, blue: 0.04), Color(red: 0.03, green: 0.02, blue: 0.05), Color(red: 0.04, green: 0.03, blue: 0.06)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                RadialGradient(colors: [accent.opacity(0.04), .clear], center: .init(x: 0.5, y: 0.15), startRadius: 20, endRadius: 300).ignoresSafeArea()
            } else {
                LinearGradient(colors: [Color(red: 0.99, green: 0.98, blue: 0.96), Color(red: 0.98, green: 0.97, blue: 0.95), Color(red: 0.97, green: 0.96, blue: 0.94)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                RadialGradient(colors: [accent.opacity(0.06), .clear], center: .init(x: 0.5, y: 0.15), startRadius: 20, endRadius: 300).ignoresSafeArea()
            }
        }
    }
}

struct ActivityLockMessage {
    let emoji: String
    let title: String
    let subtitle: String
    let detail: String

    static let all: [ActivityLockMessage] = [
        ActivityLockMessage(emoji: "\u{1F512}", title: "Apps Locked \u{1F6E1}\u{FE0F}", subtitle: "God first, everything else second", detail: "Complete your morning session to unlock"),
        ActivityLockMessage(emoji: "\u{1F31E}", title: "Rise & Pray First", subtitle: "Your apps are paused until you spend time with God", detail: "The feed can wait. Your soul can\u{2019}t. \u{1F54A}\u{FE0F}"),
        ActivityLockMessage(emoji: "\u{2615}", title: "God Before the Gram", subtitle: "Apps locked until your morning session is done", detail: "Coffee + Jesus > Coffee + Doomscrolling \u{2615}\u{2728}"),
        ActivityLockMessage(emoji: "\u{1F6A7}", title: "Hold Up Fam!", subtitle: "Complete your session to unlock apps for the day", detail: "Your past self set this up because they believe in you \u{1F4AA}"),
        ActivityLockMessage(emoji: "\u{1F525}", title: "Morning Armor Active", subtitle: "Start your day in the Word before the world", detail: "You\u{2019}re literally choosing God over TikTok rn. Legend. \u{1F3C6}"),
        ActivityLockMessage(emoji: "\u{1F64F}", title: "Pray First, Scroll Later", subtitle: "Your morning with God comes before everything else", detail: "TikTok isn\u{2019}t going anywhere. But your peace is waiting. \u{1F338}"),
        ActivityLockMessage(emoji: "\u{1F4F5}", title: "Phone Down, Prayer Up", subtitle: "Spend time with God to unlock your day", detail: "5 minutes with God > 5 hours of scrolling. No cap. \u{1F9E2}"),
        ActivityLockMessage(emoji: "\u{26F0}\u{FE0F}", title: "Seek Him First", subtitle: "Apps unlock after you put God first today", detail: "\u{201C}Seek first the kingdom of God\u{201D} \u{2014} Matthew 6:33 \u{1F451}"),
    ]
}
