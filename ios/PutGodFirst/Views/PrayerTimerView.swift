import SwiftUI

struct PrayerTimerView: View {
    let durationMinutes: Int
    let journeyStyle: JourneyStyle
    let prayerMode: PrayerMode
    let onComplete: () -> Void

    @State private var selectedPrayer: Prayer?
    @State private var timeRemaining: Int
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    @State private var appear: Bool = false
    @State private var pulseAnimation: Bool = false
    @State private var currentGuidedIndex: Int = 0
    @State private var showShareSheet: Bool = false
    @State private var prayerTextLines: [Bool] = Array(repeating: false, count: 20)
    @State private var breathePhase: Bool = false
    @State private var glowIntensity: Double = 0.0
    @State private var hapticTrigger: Int = 0
    @State private var guidedHapticTrigger: Int = 0
    @State private var showPrayerSwitcher: Bool = false

    private let guidedPrompts: [String] = [
        "Begin with gratitude.\nThank God for three specific things.",
        "Confess what weighs on your heart.\nHe already knows — let it go.",
        "Pray for someone you love.\nLift them by name.",
        "Ask God for what you need today.\nHe delights in your honesty.",
        "Listen. Sit in silence for a moment.\nLet Him speak.",
    ]

    private let aiPrayerText: String = "Dear God,\n\nI come before you with a heart full of gratitude for your abundant blessings.\n\nStrengthen my resolve to walk in your light and to fully commit to your divine purpose.\n\nHelp me to dedicate myself to your teachings, and let my actions reflect your love and grace.\n\nGuide me as I strive to honor you in all that I do, holding fast to the promises you have made.\n\nIn Jesus\u{2019} name, Amen."

    init(durationMinutes: Int, journeyStyle: JourneyStyle, selectedPrayer: Prayer?, prayerMode: PrayerMode, onComplete: @escaping () -> Void) {
        self.durationMinutes = durationMinutes
        self.journeyStyle = journeyStyle
        self._selectedPrayer = State(initialValue: selectedPrayer)
        self.prayerMode = prayerMode
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: durationMinutes * 60)
    }

    private var progress: Double {
        let total = Double(durationMinutes * 60)
        guard total > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / total)
    }

    private var timeFormatted: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var currentPrayerParagraphs: [String] {
        let text: String
        switch prayerMode {
        case .pickPrayer:
            text = selectedPrayer?.text ?? ""
        case .aiPrayer:
            text = aiPrayerText
        case .ownPrayer:
            return []
        }
        return text.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        stopTimer()
                        onComplete()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: prayerMode.icon)
                            .font(.system(size: 13))
                        Text(prayerMode.rawValue)
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(Theme.icePurple)

                    Spacer()

                    HStack(spacing: 10) {
                        if prayerMode == .pickPrayer {
                            Button {
                                showPrayerSwitcher = true
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                            }
                        }
                        if prayerMode == .pickPrayer, selectedPrayer != nil {
                            Button {
                                showShareSheet = true
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(Color(.secondarySystemGroupedBackground)))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        Spacer().frame(height: 10)

                        timerCircle
                            .opacity(appear ? 1 : 0)
                            .scaleEffect(appear ? 1 : 0.9)

                        prayerContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }

                VStack(spacing: 12) {
                    if timeRemaining > 0 {
                        Button {
                            if isRunning { pauseTimer() } else { startTimer() }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                    .font(.system(size: 14))
                                    .contentTransition(.symbolEffect(.replace))
                                Text(isRunning ? "Pause" : "Begin Prayer")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Capsule().fill(Theme.primaryGradient))
                            .shadow(color: Theme.primary.opacity(0.4), radius: 12, y: 6)
                        }
                        .sensoryFeedback(.impact(weight: .medium), trigger: isRunning)
                    } else {
                        Button {
                            stopTimer()
                            onComplete()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("I\u{2019}ve Prayed Today")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Capsule().fill(Theme.primaryGradient))
                            .shadow(color: Theme.primary.opacity(0.4), radius: 12, y: 6)
                        }
                        .sensoryFeedback(.success, trigger: timeRemaining == 0)
                    }

                    if timeRemaining > 0 && isRunning {
                        Button {
                            stopTimer()
                            onComplete()
                        } label: {
                            Text("Finish early")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .background(Color(.systemBackground).shadow(color: .black.opacity(0.1), radius: 10, y: -5))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appear = true }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { pulseAnimation = true }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) { breathePhase = true }
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showShareSheet) {
            if let prayer = selectedPrayer {
                ShareSheet(text: "\(prayer.title) by \(prayer.author)\n\n\(String(prayer.text.prefix(300)))...\n\nPrayed with God First \u{1F64F}\nhttps://apps.apple.com/us/app/put-god-first/id6759613793")
            }
        }
        .sheet(isPresented: $showPrayerSwitcher) {
            PrayerSwitcherSheet(selectedPrayer: $selectedPrayer) {
                showPrayerSwitcher = false
                prayerTextLines = Array(repeating: false, count: 20)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    revealPrayer()
                }
            }
        }
    }

    private var flameGradientColors: [Color] {
        let p = progress
        if p < 0.3 {
            return [Color(red: 1.0, green: 0.82, blue: 0.12).opacity(0.3), Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.15)]
        } else if p < 0.7 {
            return [Color(red: 1.0, green: 0.55, blue: 0.0).opacity(0.5), Color(red: 0.92, green: 0.22, blue: 0.05).opacity(0.25)]
        } else {
            return [Color(red: 0.92, green: 0.22, blue: 0.05).opacity(0.6), Color(red: 1.0, green: 0.82, blue: 0.12).opacity(0.35)]
        }
    }

    private var timerCircle: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: flameGradientColors + [Color.clear],
                        center: .center,
                        startRadius: 5,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 25)
                .opacity(isRunning ? 1 : 0.3)
                .animation(.easeInOut(duration: 1.5), value: progress)

            Circle()
                .strokeBorder(Color(.tertiarySystemGroupedBackground), lineWidth: 8)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(red: 1.0, green: 0.82, blue: 0.12),
                            Color(red: 1.0, green: 0.55, blue: 0.0),
                            Color(red: 0.92, green: 0.22, blue: 0.05),
                            Color(red: 1.0, green: 0.82, blue: 0.12)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(red: 1.0, green: 0.55, blue: 0.0).opacity(progress * 0.6), radius: 8)
                .animation(.linear(duration: 1), value: progress)

            VStack(spacing: 6) {
                Text(timeFormatted)
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .contentTransition(.numericText())

                HStack(spacing: 5) {
                    if isRunning {
                        Circle()
                            .fill(Theme.icePurple)
                            .frame(width: 8, height: 8)
                            .opacity(breathePhase ? 1.0 : 0.4)
                    }
                    Text(isRunning ? "In prayer" : "Ready")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var prayerContent: some View {
        switch prayerMode {
        case .pickPrayer:
            if let prayer = selectedPrayer {
                prayerTextCard(title: prayer.title, subtitle: "by \(prayer.author)", paragraphs: currentPrayerParagraphs)
            }

        case .aiPrayer:
            VStack(spacing: 28) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.skyBlue)
                        .symbolEffect(.pulse, isActive: isRunning)
                    Text("TAILOR-MADE PRAYER")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1)
                        .foregroundStyle(Theme.skyBlue)
                }
                .opacity(prayerTextLines[0] ? 1 : 0)

                Text("Pray this aloud or in your heart\u{2026}")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .opacity(prayerTextLines[0] ? 1 : 0)

                VStack(alignment: .leading, spacing: 24) {
                    ForEach(Array(currentPrayerParagraphs.enumerated()), id: \.offset) { index, paragraph in
                        Text(paragraph)
                            .font(.system(size: 21, weight: .regular, design: .serif))
                            .foregroundStyle(.primary.opacity(0.9))
                            .lineSpacing(10)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(prayerTextLines[min(index + 1, prayerTextLines.count - 1)] ? 1 : 0)
                            .offset(y: prayerTextLines[min(index + 1, prayerTextLines.count - 1)] ? 0 : 16)
                    }
                }
            }
            .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: hapticTrigger)

        case .ownPrayer:
            guidedPrayerContent
        }
    }

    private func prayerTextCard(title: String, subtitle: String, paragraphs: [String]) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 6) {
                Image(systemName: "book")
                    .font(.system(size: 13))
                Text("PRAYER")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1)
            }
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .opacity(prayerTextLines[0] ? 1 : 0)

            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                    .opacity(prayerTextLines[1] ? 1 : 0)
                    .offset(y: prayerTextLines[1] ? 0 : 12)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .opacity(prayerTextLines[2] ? 1 : 0)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.primary.opacity(0.7), Theme.skyBlue.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 40, height: 3)
                    .clipShape(Capsule())
                    .opacity(prayerTextLines[2] ? 1 : 0)
            }

            VStack(alignment: .leading, spacing: 24) {
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                    Text(paragraph)
                        .font(.system(size: 21, weight: .regular, design: .serif))
                        .foregroundStyle(.primary.opacity(0.9))
                        .lineSpacing(10)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(prayerTextLines[min(index + 3, prayerTextLines.count - 1)] ? 1 : 0)
                        .offset(y: prayerTextLines[min(index + 3, prayerTextLines.count - 1)] ? 0 : 16)
                }
            }
        }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: hapticTrigger)
    }

    private var guidedPrayerContent: some View {
        VStack(spacing: 20) {
            Image(systemName: guidedPromptIcon)
                .font(.system(size: 36))
                .foregroundStyle(Theme.prayerTeal)
                .contentTransition(.symbolEffect(.replace))
                .padding(.bottom, 4)

            Text(guidedPrompts[currentGuidedIndex])
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 80)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.4), value: currentGuidedIndex)

            HStack(spacing: 10) {
                ForEach(0..<guidedPrompts.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentGuidedIndex ? Theme.prayerTeal : Theme.prayerTeal.opacity(0.2))
                        .frame(width: i == currentGuidedIndex ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentGuidedIndex)
                }
            }

            ZStack {
                if currentGuidedIndex < guidedPrompts.count - 1 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            currentGuidedIndex += 1
                            guidedHapticTrigger += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next Prompt")
                                .font(.system(size: 15, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(Theme.prayerTeal)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Theme.prayerTeal.opacity(0.12)))
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: guidedHapticTrigger)
                    .transition(.opacity)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "ear")
                            .font(.system(size: 13))
                        Text("Be still and listen")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Theme.prayerTeal.opacity(0.7))
                    .padding(.top, 4)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: currentGuidedIndex)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            Theme.primary.opacity(isRunning ? 0.15 : 0),
                            lineWidth: 1
                        )
                )
        )
    }

    private var guidedPromptIcon: String {
        switch currentGuidedIndex {
        case 0: return "heart.fill"
        case 1: return "drop.fill"
        case 2: return "person.2.fill"
        case 3: return "hand.raised.fill"
        case 4: return "ear"
        default: return "hands.sparkles"
        }
    }

    private func startTimer() {
        isRunning = true
        revealPrayer()
        let t = Timer(timeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func revealPrayer() {
        for i in 0..<prayerTextLines.count {
            let delay = 0.4 + Double(i) * 0.8
            withAnimation(.easeOut(duration: 1.0).delay(delay)) { prayerTextLines[i] = true }
        }
        hapticTrigger += 1
    }
}

struct PrayerSwitcherSheet: View {
    @Binding var selectedPrayer: Prayer?
    let onSelect: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(PrayerCategory.allCases) { category in
                        let prayers = PrayerLibrary.prayers(for: category)
                        if !prayers.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Theme.prayerTeal)
                                    Text(category.rawValue)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Theme.textPrimary)
                                }
                                .padding(.top, 8)

                                ForEach(prayers) { prayer in
                                    Button {
                                        selectedPrayer = prayer
                                        onSelect()
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(prayer.title)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundStyle(Theme.textPrimary)
                                                Text(prayer.author)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundStyle(Theme.textSecondary)
                                            }
                                            Spacer()
                                            if prayer.id == selectedPrayer?.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(Theme.prayerTeal)
                                            }
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(Theme.textSecondary.opacity(0.5))
                                        }
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(prayer.id == selectedPrayer?.id ? Theme.prayerTeal.opacity(0.08) : Theme.cardBg)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("Switch Prayer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.prayerTeal)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}
