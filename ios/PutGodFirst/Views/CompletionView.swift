import SwiftUI

struct CompletionPopup: View {
    let viewModel: AppViewModel
    let onDismiss: () -> Void
    @State private var appear: Bool = false
    @State private var emojiScale: Double = 0.0
    @State private var ringProgress: Double = 0.0
    @State private var showReviewPrompt: Bool = false
    @State private var streakBounce: Bool = false
    @State private var glowPulse: Bool = false
    @State private var showLifeChange: Bool = false
    @State private var showUnlockBanner: Bool = false
    @State private var confettiVisible: Bool = false
    @State private var personalMessageVisible: Bool = false
    @State private var starBurst: Bool = false
    @State private var showBadgeReveal: Bool = false
    @State private var badgeScale: CGFloat = 0.0
    @State private var badgeGlow: Bool = false
    @State private var badgeConfettiWave2: Bool = false

    private var headline: String {
        let streak = viewModel.currentStreak
        let name = viewModel.userName.isEmpty ? "" : viewModel.userName
        let headlines: [String]

        if streak == 1 {
            headlines = [
                "You Did It\(name.isEmpty ? "" : ", \(name)")!",
                "Day One. Let\u{2019}s Go!",
                "The Journey Begins!",
                "First Step Taken!",
            ]
        } else if streak < 4 {
            headlines = [
                "You Put God First Again!",
                "Look at You Go\(name.isEmpty ? "" : ", \(name)")!",
                "Back for More!",
                "Consistency Looks Good on You!",
            ]
        } else if streak < 8 {
            headlines = [
                "\(streak) Days Strong!",
                "You\u{2019}re on Fire\(name.isEmpty ? "" : ", \(name)")!",
                "This Is Becoming a Habit!",
                "God Sees Your Faithfulness!",
            ]
        } else if streak < 15 {
            headlines = [
                "\(streak) Days \u{2014} Unstoppable!",
                "A Rhythm of Faith!",
                "You\u{2019}re Changing\(name.isEmpty ? "" : ", \(name)")!",
                "Heaven Is Cheering!",
            ]
        } else if streak < 31 {
            headlines = [
                "\(streak) Days of Seeking Him!",
                "This Is Who You Are Now!",
                "Your Faithfulness Is Inspiring!",
                "God Honors Your Devotion!",
            ]
        } else if streak < 100 {
            headlines = [
                "\(streak) Days \u{2014} Extraordinary!",
                "A Life Transformed!",
                "Your Testimony Is Being Written!",
                "Unwavering Faith!",
            ]
        } else {
            headlines = [
                "\(streak) Days. Legendary.",
                "A Century of Faith!",
                "History-Making Devotion!",
                "You Inspire Generations!",
            ]
        }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return headlines[dayOfYear % headlines.count]
    }

    private var personalMessage: String {
        let streak = viewModel.currentStreak
        let total = viewModel.totalDaysCompleted
        let name = viewModel.userName

        if streak == 1 && total == 1 {
            return "Your very first session. This is the start of something beautiful\(name.isEmpty ? "" : ", \(name)"). God is smiling."
        }

        if streak == 3 {
            return "Three days in a row! Most people never get this far. You\u{2019}re different."
        }
        if streak == 7 {
            return "One full week of putting God first. Let that sink in. You\u{2019}re building something that lasts."
        }
        if streak == 14 {
            return "Two weeks of faithfulness. Your life is quietly, powerfully changing."
        }
        if streak == 21 {
            return "21 days \u{2014} they say that\u{2019}s what it takes to form a habit. This isn\u{2019}t just a habit though. It\u{2019}s a lifestyle."
        }
        if streak == 30 {
            return "A full month. 30 mornings of choosing God first. You are not the same person you were."
        }
        if streak == 50 {
            return "50 days. Half a hundred mornings surrendered to God. Your faithfulness echoes in eternity."
        }
        if streak == 100 {
            return "100 days. One hundred mornings. This kind of devotion changes families, communities, generations."
        }
        if streak == 365 {
            return "One full year. Every single day. Words can\u{2019}t capture what God has done in you."
        }

        let messages: [String] = [
            "Before the world got your attention, you gave it to God. That matters more than you know.",
            "While most people reached for their phone, you reached for God. That\u{2019}s powerful.",
            "You chose the better thing today. Jesus sees it. He\u{2019}s proud of you.",
            "This moment of surrender is shaping who you\u{2019}re becoming. Keep going.",
            "Your faithfulness today is planting seeds for a harvest you can\u{2019}t even imagine yet.",
            "God doesn\u{2019}t measure your prayer by its length. He treasures that you showed up.",
            "You\u{2019}re doing something most people only talk about. You\u{2019}re actually living it.",
            "Every morning you choose this, you become more of who God created you to be.",
            "The peace you feel right now? That\u{2019}s what happens when first things come first.",
            "You didn\u{2019}t just pray today. You declared that God matters most. And He heard you.",
        ]

        let seed = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return messages[seed % messages.count]
    }

    private var streakMessage: String {
        let streak = viewModel.currentStreak
        if streak >= 100 { return "Extraordinary faithfulness." }
        if streak >= 50 { return "Your dedication is inspiring." }
        if streak >= 30 { return "A month of seeking Him first." }
        if streak >= 14 { return "Two weeks strong. Keep going." }
        if streak >= 7 { return "One full week with God first." }
        if streak >= 3 { return "Building a beautiful rhythm." }
        return "A great beginning."
    }

    private var projectedHours: Int {
        viewModel.prayerDurationMinutes * 365 / 60
    }

    private var isMilestone: Bool {
        let streak = viewModel.currentStreak
        return [1, 3, 7, 14, 21, 30, 50, 100, 200, 365].contains(streak)
    }

    private var earnedBadge: BadgeMilestone? {
        let streak = viewModel.currentStreak
        return BadgeMilestone.allCases.reversed().first(where: { streak >= $0.daysRequired && streak - 1 < $0.daysRequired })
    }

    private var isBadgeMilestone: Bool {
        earnedBadge != nil
    }

    private var milestoneIcon: String {
        let streak = viewModel.currentStreak
        if streak >= 365 { return "crown.fill" }
        if streak >= 100 { return "trophy.fill" }
        if streak >= 50 { return "diamond.fill" }
        if streak >= 30 { return "star.fill" }
        if streak >= 21 { return "flame.fill" }
        if streak >= 14 { return "bolt.heart.fill" }
        if streak >= 7 { return "sparkles" }
        if streak >= 3 { return "rays" }
        return "cross.fill"
    }

    private var milestoneIconColor: Color {
        let streak = viewModel.currentStreak
        if streak >= 365 { return Theme.dawnGold }
        if streak >= 100 { return Theme.dawnAmber }
        if streak >= 50 { return Theme.lavender }
        if streak >= 30 { return Theme.dawnGold }
        if streak >= 21 { return .orange }
        if streak >= 14 { return Theme.coral }
        if streak >= 7 { return Theme.skyBlue }
        if streak >= 3 { return Theme.mint }
        return Theme.dawnGold
    }

    private var lifeChangeItems: [(icon: String, text: String, color: Color)] {
        [
            ("heart.fill", "Loneliness drops 38%", Theme.coral),
            ("flame.fill", "Anger issues drop 32%", Theme.hotPink),
            ("person.2.fill", "Bitterness in relationships drops 40%", Theme.lavender),
            ("brain.head.profile.fill", "Feeling spiritually stagnant drops 60%", Theme.skyBlue),
            ("hands.sparkles.fill", "Sharing your faith increases 200%", Theme.limeGreen),
            ("book.fill", "Discipling others increases 238%", Theme.mint),
        ]
    }

    var body: some View {
        ZStack {
            Color.black.opacity(appear ? 0.6 : 0)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        confettiHeader

                        congratsSection

                        if personalMessageVisible {
                            personalMessageCard
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }

                        statsRow

                        if isBadgeMilestone, let badge = earnedBadge {
                            badgeRevealCard(badge)
                                .transition(.opacity.combined(with: .scale(scale: 0.85)))
                        } else if isMilestone {
                            milestoneBanner
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }

                        if showLifeChange {
                            lifeChangeSection
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        if showUnlockBanner {
                            unlockBanner
                                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }

                        buttonsSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 28)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Theme.bg)
                    .shadow(color: .black.opacity(0.25), radius: 30, y: 10)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 60)
            .scaleEffect(appear ? 1 : 0.85)
            .opacity(appear ? 1 : 0)
        }
        .onAppear { runEntryAnimations() }
    }

    private var confettiHeader: some View {
        ZStack {
            Circle()
                .fill(Theme.limeGreen.opacity(glowPulse ? 0.15 : 0.06))
                .frame(width: 160, height: 160)

            if starBurst {
                ForEach(0..<8, id: \.self) { i in
                    Image(systemName: "sparkle")
                        .font(.system(size: 10))
                        .foregroundStyle(
                            [Theme.dawnGold, Theme.limeGreen, Theme.skyBlue, Theme.lavender][i % 4]
                        )
                        .offset(
                            x: cos(Double(i) * .pi / 4) * 90,
                            y: sin(Double(i) * .pi / 4) * 90
                        )
                        .opacity(starBurst ? 0 : 0.9)
                        .scaleEffect(starBurst ? 1.5 : 0.5)
                }
            }

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    LinearGradient(colors: [Theme.limeGreen, Theme.mint], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(-90))

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(Theme.limeGreen)
                .scaleEffect(emojiScale)
                .symbolEffect(.bounce, value: emojiScale)

            if confettiVisible {
                ForEach(0..<16, id: \.self) { i in
                    ConfettiParticle(index: i)
                }
            }
        }
    }

    private var congratsSection: some View {
        VStack(spacing: 10) {
            Text(headline)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text(streakMessage)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.dawnAmber)
        }
        .opacity(appear ? 1 : 0)
    }

    private var personalMessageCard: some View {
        VStack(spacing: 12) {
            Text(personalMessage)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(Theme.textPrimary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Theme.dawnGold.opacity(0.08), Theme.dawnAmber.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Theme.dawnGold.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func badgeRevealCard(_ badge: BadgeMilestone) -> some View {
        VStack(spacing: 16) {
            Text("SHIELD UNLOCKED")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(badge.accentColor)
                .tracking(2)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [badge.accentColor.opacity(badgeGlow ? 0.4 : 0.1), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(badgeGlow ? 1.15 : 0.9)

                if badgeConfettiWave2 {
                    ForEach(0..<12, id: \.self) { i in
                        let angle = Double(i) * 30.0
                        let rad = angle * .pi / 180
                        let colors: [Color] = [badge.accentColor, Theme.dawnGold, Theme.limeGreen, Theme.skyBlue, Theme.lavender, badge.glowColor]
                        Circle()
                            .fill(colors[i % colors.count])
                            .frame(width: CGFloat([5, 4, 6, 3, 5, 4, 6, 3, 5, 4, 6, 3][i]))
                            .offset(
                                x: badgeConfettiWave2 ? cos(rad) * 110 : 0,
                                y: badgeConfettiWave2 ? sin(rad) * 110 : 0
                            )
                            .opacity(badgeConfettiWave2 ? 0 : 1)
                    }
                }

                AsyncImage(url: URL(string: badge.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    default:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(badge.accentColor.opacity(0.2))
                            .overlay {
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 44))
                                    .foregroundStyle(badge.accentColor)
                            }
                    }
                }
                .frame(width: 120, height: 120)
                .scaleEffect(badgeScale)
                .shadow(color: badge.accentColor.opacity(0.6), radius: 20)
            }

            VStack(spacing: 6) {
                Text(badge.title)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Text("\(badge.daysRequired)-Day Cross Shield")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(badge.accentColor)

                Text(badge.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [badge.accentColor.opacity(0.08), badge.glowColor.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            LinearGradient(
                                colors: [badge.accentColor.opacity(0.4), badge.glowColor.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
        .opacity(showBadgeReveal ? 1 : 0)
    }

    private var milestoneBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: milestoneIcon)
                .font(.system(size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [milestoneIconColor, milestoneIconColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: milestoneIconColor.opacity(0.5), radius: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text("Milestone Reached!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Text("\(viewModel.currentStreak)-day streak \u{2014} You\u{2019}re making history.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Theme.dawnGold.opacity(0.1), Theme.dawnAmber.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.dawnGold.opacity(0.35), lineWidth: 1.5)
                )
        )
        .opacity(appear ? 1 : 0)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(icon: "flame.fill", iconColor: .orange, value: "\(viewModel.currentStreak)", label: "day streak", color: Theme.dawnAmber)
            statCard(icon: "cross.fill", iconColor: Theme.dawnGold, value: "\(viewModel.totalDaysCompleted)", label: "total days", color: Theme.dawnGold)
            statCard(icon: "clock.fill", iconColor: Theme.lavender, value: "\(projectedHours)h", label: "yearly prayer", color: Theme.lavender)
        }
        .scaleEffect(streakBounce ? 1.0 : 0.8)
        .opacity(appear ? 1 : 0)
    }

    private var lifeChangeSection: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("Keep going. Your life is changing.")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Text("People who seek God daily experience:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }

            VStack(spacing: 8) {
                ForEach(Array(lifeChangeItems.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 12) {
                        Image(systemName: item.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(item.color)
                            .frame(width: 28, height: 28)
                            .background(item.color.opacity(0.12))
                            .clipShape(Circle())

                        Text(item.text)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)

                        Spacer()

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.limeGreen)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.cardBg)
                    )
                    .opacity(showLifeChange ? 1 : 0)
                    .offset(y: showLifeChange ? 0 : 10)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.08), value: showLifeChange)
                }
            }
        }
    }

    private var unlockBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.limeGreen.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "lock.open.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.limeGreen)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Apps Unlocked")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Text("Your other apps are now available. Walk in peace today.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.limeGreen.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.limeGreen.opacity(0.3), lineWidth: 1.5)
                )
        )
    }

    private var buttonsSection: some View {
        VStack(spacing: 10) {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                onDismiss()
            } label: {
                Text("Continue My Day")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.25, green: 0.12, blue: 0.02))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Theme.amberGradient))
                    .shadow(color: Theme.amber.opacity(0.35), radius: 10, y: 4)
            }

            if showReviewPrompt {
                Button {
                    viewModel.requestReview()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                        Text("Enjoying God First? Rate us")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Theme.dawnAmber)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .strokeBorder(Theme.dawnAmber.opacity(0.4), lineWidth: 1.5)
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .opacity(appear ? 1 : 0)
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [iconColor, iconColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: iconColor.opacity(0.4), radius: 4)
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.08))
        )
    }

    private func runEntryAnimations() {
        let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        let notif = UINotificationFeedbackGenerator()
        let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        heavyImpact.prepare()
        notif.prepare()
        mediumImpact.prepare()

        withAnimation(.easeOut(duration: 0.5)) {
            appear = true
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            ringProgress = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.5)) {
            emojiScale = 1.0
            confettiVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            notif.notificationOccurred(.success)
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.7)) {
            streakBounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            heavyImpact.impactOccurred()
        }
        withAnimation(.easeOut(duration: 1.2).delay(0.6)) {
            starBurst = true
        }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.8)) {
            glowPulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                personalMessageVisible = true
            }
            mediumImpact.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            if isBadgeMilestone {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    showBadgeReveal = true
                    badgeScale = 1.0
                }
                withAnimation(.easeOut(duration: 1.5).delay(0.2)) {
                    badgeConfettiWave2 = true
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
                    badgeGlow = true
                }
                let heavyGen = UIImpactFeedbackGenerator(style: .heavy)
                heavyGen.impactOccurred()
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showLifeChange = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                showUnlockBanner = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring(response: 0.4)) {
                showReviewPrompt = true
            }
        }
    }
}

struct ConfettiParticle: View {
    let index: Int
    @State private var animate: Bool = false

    private var angle: Double { Double(index) * (360.0 / 16.0) }
    private var color: Color {
        [Theme.dawnGold, Theme.limeGreen, Theme.skyBlue, Theme.lavender, Theme.mint, Theme.dawnAmber, Theme.coral, Theme.hotPink][index % 8]
    }
    private var size: CGFloat {
        [6, 5, 7, 4, 6, 5, 7, 4][index % 8]
    }
    private var distance: CGFloat {
        CGFloat([75, 90, 80, 95, 70, 85, 92, 78][index % 8])
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: animate ? size : 3, height: animate ? size : 3)
            .offset(
                x: animate ? cos(angle * .pi / 180) * distance : 0,
                y: animate ? sin(angle * .pi / 180) * distance : 0
            )
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0).delay(Double(index) * 0.025)) {
                    animate = true
                }
            }
    }
}
