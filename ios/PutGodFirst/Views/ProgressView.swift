import SwiftUI

struct ProgressTrackerView: View {
    @Bindable var viewModel: AppViewModel
    @State private var selectedMonth: Date = .now
    @State private var appearAnimation: Bool = false
    @State private var selectedDay: Date? = nil
    @State private var selectedBadge: BadgeMilestone? = nil
    @State private var badgeAnimationFlags: [BadgeMilestone: Bool] = [:]
    @State private var streakFlameScale: CGFloat = 1.0
    @State private var glowPhase: Bool = false

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return []
        }
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1
        var days: [Date?] = Array(repeating: nil, count: weekdayOfFirst)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    private var monthRecords: [SessionRecord] {
        viewModel.sessionHistory.records(for: selectedMonth)
    }

    private var nextStreakMilestone: Int {
        let streak = viewModel.currentStreak
        let milestones = [3, 7, 14, 21, 30, 50, 75, 100, 150, 200, 365]
        return milestones.first(where: { $0 > streak }) ?? (streak + 10)
    }

    private var streakMilestoneProgress: Double {
        let streak = viewModel.currentStreak
        let milestones = [0, 3, 7, 14, 21, 30, 50, 75, 100, 150, 200, 365]
        let prevMilestone = milestones.last(where: { $0 <= streak }) ?? 0
        let nextM = nextStreakMilestone
        guard nextM > prevMilestone else { return 1.0 }
        return Double(streak - prevMilestone) / Double(nextM - prevMilestone)
    }

    private var streakTitle: String {
        let streak = viewModel.currentStreak
        if streak >= 365 { return "Eternal Flame" }
        if streak >= 200 { return "Living Legend" }
        if streak >= 100 { return "Century Warrior" }
        if streak >= 50 { return "Faithful Fifty" }
        if streak >= 30 { return "Monthly Master" }
        if streak >= 21 { return "Habit Formed" }
        if streak >= 14 { return "Fortnight Strong" }
        if streak >= 7 { return "Week Warrior" }
        if streak >= 3 { return "Getting Started" }
        return "New Flame"
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    streakHeroCard
                    badgeShowcase
                    nextMilestoneCard
                    streakAndStats
                    calendarCard
                    if let day = selectedDay, let record = viewModel.sessionHistory.record(on: day) {
                        dayDetailCard(record)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    weeklyInsight
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .opacity(appearAnimation ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appearAnimation = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                streakFlameScale = 1.15
                glowPhase = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                for milestone in BadgeMilestone.allCases {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(milestone.rawValue) * 0.002)) {
                        badgeAnimationFlags[milestone] = true
                    }
                }
            }
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
    }

    private var streakHeroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(glowPhase ? 0.4 : 0.15), .clear],
                            center: .center,
                            startRadius: 5,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)

                Circle()
                    .trim(from: 0, to: streakMilestoneProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.orange, Color(red: 1.0, green: 0.4, blue: 0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .stroke(Color.orange.opacity(0.1), lineWidth: 5)
                    .frame(width: 100, height: 100)

                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.95, blue: 0.4), Color(red: 1.0, green: 0.55, blue: 0.0), Color(red: 0.95, green: 0.15, blue: 0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(streakFlameScale)

                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
            }

            VStack(spacing: 4) {
                Text(streakTitle)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Text("\(viewModel.currentStreak) day streak")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }

            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { i in
                    let startOfWeek = calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: .now)
                    let sunday = calendar.date(from: startOfWeek)!
                    let dayDate = calendar.date(byAdding: .day, value: i, to: sunday)!
                    let hasSession = viewModel.sessionHistory.hasSession(on: dayDate)
                    let isToday = calendar.isDateInToday(dayDate)

                    VStack(spacing: 4) {
                        Text(daysOfWeek[i])
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.textSecondary)

                        ZStack {
                            Circle()
                                .fill(
                                    hasSession
                                    ? LinearGradient(colors: [.orange, Color(red: 1.0, green: 0.4, blue: 0.1)], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [Theme.textSecondary.opacity(0.1), Theme.textSecondary.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 32, height: 32)

                            if hasSession {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            } else if isToday {
                                Circle()
                                    .strokeBorder(.orange.opacity(0.5), lineWidth: 2)
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.orange.opacity(0.2), Color(red: 1.0, green: 0.4, blue: 0.1).opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var badgeShowcase: some View {
        let streak = viewModel.currentStreak

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Cross Shields")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(BadgeMilestone.allCases.filter { viewModel.hasBadge($0) }.count)/\(BadgeMilestone.allCases.count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.logoBlue)
            }

            HStack(spacing: 12) {
                ForEach(BadgeMilestone.allCases, id: \.rawValue) { milestone in
                    let unlocked = viewModel.hasBadge(milestone)
                    let animated = badgeAnimationFlags[milestone] ?? false
                    let progress = unlocked ? 1.0 : min(Double(streak) / Double(milestone.daysRequired), 1.0)

                    Button {
                        selectedBadge = milestone
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                if unlocked {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [milestone.accentColor.opacity(0.3), .clear],
                                                center: .center,
                                                startRadius: 5,
                                                endRadius: 30
                                            )
                                        )
                                        .frame(width: 64, height: 64)
                                } else {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [milestone.glowColor.opacity(0.15), milestone.glowColor.opacity(0.03)],
                                                center: .center,
                                                startRadius: 2,
                                                endRadius: 30
                                            )
                                        )
                                        .frame(width: 64, height: 64)

                                    Circle()
                                        .trim(from: 0, to: progress)
                                        .stroke(
                                            milestone.accentColor.opacity(0.4),
                                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                                        )
                                        .frame(width: 58, height: 58)
                                        .rotationEffect(.degrees(-90))
                                }

                                AsyncImage(url: URL(string: milestone.imageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFit()
                                    default:
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(milestone.accentColor.opacity(0.12))
                                            .overlay {
                                                Image(systemName: "shield.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(milestone.accentColor.opacity(0.4))
                                            }
                                    }
                                }
                                .frame(width: 48, height: 48)
                                .saturation(unlocked ? 1.0 : 0.15)
                                .opacity(unlocked ? 1.0 : 0.5)

                                if !unlocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(milestone.accentColor.opacity(0.6))
                                        .offset(y: 20)
                                }
                            }
                            .scaleEffect(animated ? 1.0 : 0.3)
                            .opacity(animated ? 1.0 : 0)

                            VStack(spacing: 2) {
                                Text("\(milestone.daysRequired)d")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(unlocked ? milestone.accentColor : milestone.accentColor.opacity(0.6))

                                if !unlocked {
                                    Text(milestone.badgeName)
                                        .font(.system(size: 8, weight: .semibold))
                                        .foregroundStyle(milestone.accentColor.opacity(0.5))
                                        .lineLimit(1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: selectedBadge)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.cardBg)
        )
    }

    private var nextMilestoneCard: some View {
        let streak = viewModel.currentStreak
        let nextBadge = viewModel.nextUnearnedBadge

        return Group {
            if let badge = nextBadge {
                let remaining = max(badge.daysRequired - streak, 0)
                let progress = min(Double(streak) / Double(badge.daysRequired), 1.0)

                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [badge.glowColor.opacity(0.2), .clear],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 25
                                )
                            )
                            .frame(width: 56, height: 56)

                        AsyncImage(url: URL(string: badge.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit()
                            default:
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(badge.accentColor.opacity(0.5))
                            }
                        }
                        .frame(width: 40, height: 40)
                        .saturation(0.2)
                        .opacity(0.6)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text("Next: \(badge.title)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)

                            Text("\(remaining) days")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(badge.accentColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(badge.accentColor.opacity(0.12))
                                )
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
                            }
                        }
                        .frame(height: 6)

                        Text("\(Int(progress * 100))% complete")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Theme.cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(badge.accentColor.opacity(0.15), lineWidth: 1)
                        )
                )
            }
        }
    }

    private var streakAndStats: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "flame.fill",
                iconColor: .orange,
                value: "\(viewModel.currentStreak)",
                label: "Current Streak"
            )
            statCard(
                icon: "trophy.fill",
                iconColor: Theme.dawnAmber,
                value: "\(viewModel.sessionHistory.longestStreak)",
                label: "Best Streak"
            )
            statCard(
                icon: "clock.fill",
                iconColor: Theme.lavender,
                value: formatMinutes(viewModel.sessionHistory.totalMinutes),
                label: "Total Time"
            )
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.cardBg)
        )
    }

    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                        selectedDay = nil
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.blueAccent)
                        .frame(width: 36, height: 36)
                        .background(Theme.blueAccent.opacity(0.1))
                        .clipShape(Circle())
                }

                Spacer()

                Text(monthTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                        selectedDay = nil
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(calendar.isDate(selectedMonth, equalTo: .now, toGranularity: .month) ? Theme.textSecondary.opacity(0.3) : Theme.blueAccent)
                        .frame(width: 36, height: 36)
                        .background(Theme.blueAccent.opacity(0.1))
                        .clipShape(Circle())
                }
                .disabled(calendar.isDate(selectedMonth, equalTo: .now, toGranularity: .month))
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(height: 28)
                }

                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        calendarDay(date)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Theme.logoGradient)
                        .frame(width: 8, height: 8)
                    Text("Completed")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                HStack(spacing: 6) {
                    Circle()
                        .strokeBorder(Theme.logoBlue.opacity(0.6), lineWidth: 1.5)
                        .frame(width: 8, height: 8)
                    Text("Today")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Text("\(monthRecords.count) sessions")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.logoBlue)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.cardBg)
        )
    }

    private func calendarDay(_ date: Date) -> some View {
        let hasSession = viewModel.sessionHistory.hasSession(on: date)
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > .now
        let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let dayNum = calendar.component(.day, from: date)

        return Button {
            if hasSession {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedDay = isSelected ? nil : date
                }
            }
        } label: {
            ZStack {
                if hasSession {
                    Circle()
                        .fill(
                            isSelected
                                ? LinearGradient(colors: [Theme.logoBlue, Theme.logoPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Theme.logoBlue, Theme.logoIndigo], startPoint: .top, endPoint: .bottom)
                        )
                } else if isToday {
                    Circle()
                        .strokeBorder(Theme.logoBlue, lineWidth: 2)
                }

                Text("\(dayNum)")
                    .font(.system(size: 14, weight: hasSession ? .bold : .medium, design: .rounded))
                    .foregroundStyle(
                        hasSession ? .white :
                        isToday ? Theme.logoBlue :
                        isFuture ? Theme.textSecondary.opacity(0.3) :
                        Theme.textPrimary
                    )
            }
            .frame(height: 40)
        }
        .disabled(!hasSession)
    }

    private func dayDetailCard(_ record: SessionRecord) -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        let dateStr = formatter.string(from: record.date)

        return HStack(spacing: 16) {
            VStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.limeGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dateStr)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 12) {
                    Label("\(record.prayerMinutes) min", systemImage: "clock.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.blueAccent)
                    Label("\(record.streakAtTime) streak", systemImage: "flame.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.orange)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.limeGreen.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Theme.limeGreen.opacity(0.25), lineWidth: 1.5)
                )
        )
    }

    private var weeklyInsight: some View {
        let weekSessions = viewModel.sessionHistory.thisWeekSessions
        let monthMinutes = viewModel.sessionHistory.thisMonthMinutes
        let avg = viewModel.sessionHistory.averageMinutes

        return VStack(alignment: .leading, spacing: 14) {
            Text("Insights")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            VStack(spacing: 10) {
                insightRow(icon: "calendar.badge.clock", color: Theme.logoBlue, title: "This Week", value: "\(weekSessions) of 7 days")
                insightRow(icon: "clock.arrow.circlepath", color: Theme.lavender, title: "This Month", value: formatMinutes(monthMinutes))
                insightRow(icon: "chart.line.uptrend.xyaxis", color: Theme.limeGreen, title: "Avg Session", value: String(format: "%.0f min", avg))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.cardBg)
        )
    }

    private func insightRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 { return "\(hours)h" }
        return "\(hours)h \(mins)m"
    }
}

struct ProgressDetailSheet: View {
    @Bindable var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ProgressTrackerView(viewModel: viewModel)
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .padding(.trailing, 20)
                .padding(.top, 8)
            }
    }
}
