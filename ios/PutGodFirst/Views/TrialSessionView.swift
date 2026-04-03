import SwiftUI
import StoreKit

struct TrialSessionView: View {
    let userName: String
    let selectedMinutes: Int
    let prayerConfidence: Double
    let phoneHabit: String
    let onComplete: () -> Void

    @Environment(\.requestReview) private var requestReview
    @State private var phase: SessionPhase = .greeting
    @State private var appear: Bool = false
    @State private var breatheIn: Bool = false
    @State private var greetingLine2: Bool = false
    @State private var showButton: Bool = false
    @State private var textLines: [Bool] = Array(repeating: false, count: 10)
    @State private var pulseRing: Bool = false
    @State private var selectedTrialPrayerMode: TrialPrayerChoice = .curated
    @State private var pickedPrayer: Prayer?
    @State private var showPrayerPicker: Bool = false
    @State private var confettiPieces: [TrialConfettiPiece] = []
    @State private var confettiActive: Bool = false

    private let trialVerse = DailyVerse(
        reference: "Psalm 5:3",
        text: "In the morning, Lord, you hear my voice; in the morning I lay my requests before you and wait expectantly."
    )

    private let trialDevotionalTitle = "The First Voice"

    private let trialDevotionalBody = "Before the noise of the day rushes in \u{2014} before notifications, headlines, and to-do lists \u{2014} there is a sacred quiet. God invites you into it. Not because He needs your attention, but because He knows you need His.\n\nWhen David wrote these words, he was a king with a kingdom to run. Yet he chose to begin each day not with strategy, but with surrender. He laid his requests before God and then did something radical: he waited.\n\nWaiting is not passive. It is an act of trust. It says, \u{201C}I believe You are working even when I cannot see it.\u{201D}\n\nToday, before you pick up your phone, before you check your messages \u{2014} pause. Lay your day before Him. And wait expectantly, because He is faithful."

    enum SessionPhase: Int, CaseIterable {
        case greeting
        case verse
        case devotional
        case prayerChoice
        case prayer
        case completion
    }

    enum TrialPrayerChoice {
        case curated
        case pick
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.03, blue: 0.09),
                    Color(red: 0.06, green: 0.04, blue: 0.14),
                    Color(red: 0.04, green: 0.03, blue: 0.09)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            switch phase {
            case .greeting: greetingPhase
            case .verse: versePhase
            case .devotional: devotionalPhase
            case .prayerChoice: prayerChoicePhase
            case .prayer: prayerPhase
            case .completion: completionPhase
            }
        }
        .sheet(isPresented: $showPrayerPicker) {
            TrialPrayerPickerSheet(selectedPrayer: $pickedPrayer) {
                showPrayerPicker = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    transitionTo(.prayer)
                }
            }
        }
    }

    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }

    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "sun.horizon.fill"
        } else if hour < 17 {
            return "sun.max.fill"
        } else {
            return "moon.stars.fill"
        }
    }

    // MARK: - Greeting

    private var greetingPhase: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(appear ? 0.04 : 0))
                        .frame(width: 120, height: 120)
                        .scaleEffect(appear ? 1 : 0.5)

                    Image(systemName: greetingIcon)
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.75, blue: 0.3), Color(red: 0.9, green: 0.5, blue: 0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.5)
                }

                VStack(spacing: 16) {
                    Text("\(timeBasedGreeting), \(userName).")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 12)

                    Text("Let\u{2019}s meet with God.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .opacity(greetingLine2 ? 1 : 0)
                        .offset(y: greetingLine2 ? 0 : 10)
                }
            }

            Spacer()

            sessionButton("Begin") {
                transitionTo(.verse)
            }
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 16)
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) { appear = true }
            withAnimation(.easeOut(duration: 0.7).delay(1.0)) { greetingLine2 = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.5)) { showButton = true }
        }
    }

    // MARK: - Verse of the Day

    private var versePhase: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                HStack(spacing: 6) {
                    Image(systemName: "book")
                        .font(.system(size: 13))
                    Text("VERSE OF THE DAY")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1)
                }
                .foregroundStyle(.white.opacity(0.35))
                .opacity(textLines[0] ? 1 : 0)

                VStack(spacing: 20) {
                    Text("\u{201C}\(trialVerse.text)\u{201D}")
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(textLines[1] ? 1 : 0)
                        .offset(y: textLines[1] ? 0 : 14)

                    Text("\u{2014} \(trialVerse.reference)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                        .opacity(textLines[2] ? 1 : 0)
                }
            }

            Spacer()

            sessionButton("Continue to Devotional") {
                transitionTo(.devotional)
            }
            .opacity(textLines[3] ? 1 : 0)
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            resetTextLines()
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) { textLines[0] = true }
            withAnimation(.easeOut(duration: 0.8).delay(0.8)) { textLines[1] = true }
            withAnimation(.easeOut(duration: 0.6).delay(1.5)) { textLines[2] = true }
            withAnimation(.easeOut(duration: 0.5).delay(2.2)) { textLines[3] = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { breatheIn = true }
        }
    }

    // MARK: - Devotional

    private var devotionalPhase: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 40)

                    HStack(spacing: 6) {
                        Image(systemName: "text.book.closed")
                            .font(.system(size: 13))
                        Text("TODAY\u{2019}S DEVOTIONAL")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .tracking(1)
                    }
                    .foregroundStyle(.white.opacity(0.35))
                    .opacity(textLines[0] ? 1 : 0)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text("3 min read")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.3))
                    .opacity(textLines[0] ? 1 : 0)

                    Text(trialDevotionalTitle)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .opacity(textLines[1] ? 1 : 0)
                        .offset(y: textLines[1] ? 0 : 12)

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
                        .opacity(textLines[1] ? 1 : 0)

                    Text(trialDevotionalBody)
                        .font(.system(size: 19, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineSpacing(10)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(textLines[2] ? 1 : 0)
                        .offset(y: textLines[2] ? 0 : 14)

                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 28)
            }

            VStack(spacing: 0) {
                sessionButton("Continue to Prayer") {
                    transitionTo(.prayerChoice)
                }
                .opacity(textLines[3] ? 1 : 0)
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.03, blue: 0.09).opacity(0), Color(red: 0.04, green: 0.03, blue: 0.09)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
                .allowsHitTesting(false)
            )
        }
        .onAppear {
            resetTextLines()
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { textLines[0] = true }
            withAnimation(.easeOut(duration: 0.7).delay(0.6)) { textLines[1] = true }
            withAnimation(.easeOut(duration: 0.8).delay(1.0)) { textLines[2] = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.8)) { textLines[3] = true }
        }
    }

    // MARK: - Prayer Choice

    private var prayerChoicePhase: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                VStack(spacing: 14) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.primary.opacity(0.8), Theme.skyBlue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(textLines[0] ? 1 : 0)
                        .scaleEffect(textLines[0] ? 1 : 0.5)

                    Text("How would you like\nto pray, \(userName)?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(textLines[1] ? 1 : 0)
                        .offset(y: textLines[1] ? 0 : 14)
                }

                VStack(spacing: 12) {
                    prayerChoiceCard(
                        icon: "sparkles",
                        title: "Pray a Curated Prayer",
                        subtitle: "A first-person prayer crafted for your needs",
                        isSelected: selectedTrialPrayerMode == .curated,
                        index: 2
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTrialPrayerMode = .curated
                        }
                    }

                    prayerChoiceCard(
                        icon: "book",
                        title: "Pick a Prayer",
                        subtitle: "Choose from our library of prayers",
                        isSelected: selectedTrialPrayerMode == .pick,
                        index: 3
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTrialPrayerMode = .pick
                        }
                    }
                }
            }

            Spacer()

            sessionButton(selectedTrialPrayerMode == .pick ? "Choose a Prayer" : "Begin Prayer") {
                if selectedTrialPrayerMode == .pick {
                    showPrayerPicker = true
                } else {
                    transitionTo(.prayer)
                }
            }
            .opacity(textLines[4] ? 1 : 0)
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            resetTextLines()
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { textLines[0] = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) { textLines[1] = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.9)) { textLines[2] = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.1)) { textLines[3] = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.5)) { textLines[4] = true }
        }
    }

    private func prayerChoiceCard(icon: String, title: String, subtitle: String, isSelected: Bool, index: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Theme.primary.opacity(0.2) : .white.opacity(0.06))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? Theme.primary : .white.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? Theme.primary : .white.opacity(0.2))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? Theme.primary.opacity(0.08) : .white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(isSelected ? Theme.primary.opacity(0.4) : .white.opacity(0.08), lineWidth: 1.5)
                    )
            )
        }
        .opacity(textLines[index] ? 1 : 0)
        .offset(y: textLines[index] ? 0 : 12)
    }

    // MARK: - Prayer

    private var prayerPhase: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                if selectedTrialPrayerMode == .pick, let prayer = pickedPrayer {
                    pickedPrayerContent(prayer)
                } else {
                    curatedPrayerContent
                }

                Spacer().frame(height: 60)

                sessionButton("I\u{2019}ve Put God First \u{2728}") {
                    transitionTo(.completion)
                }
                .opacity(textLines[7] ? 1 : 0)
                .padding(.horizontal, 28)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            resetTextLines()
            for i in 0..<8 {
                let delay = 0.3 + Double(i) * 0.6
                withAnimation(.easeOut(duration: 0.7).delay(delay)) { textLines[i] = true }
            }
        }
    }

    private var curatedPrayerContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13))
                Text("YOUR PRAYER")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1)
            }
            .foregroundStyle(.white.opacity(0.35))
            .opacity(textLines[0] ? 1 : 0)

            Text("Pray this aloud or in your heart\u{2026}")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.35))
                .opacity(textLines[0] ? 1 : 0)

            VStack(spacing: 22) {
                prayerLine("Heavenly Father,", index: 1)
                prayerLine("Thank You for waking me up this morning. Thank You for another day to walk in Your presence and Your purpose. I choose to come to You first, before the noise, before the distractions.", index: 2)
                prayerLine(curatedFirstPersonPrayer, index: 3)
                prayerLine("Give me the strength to choose You first \u{2014} not just today, but every morning. Let this become a rhythm of faithfulness that transforms my life from the inside out.", index: 4)
                prayerLine("Guard my heart from distraction. Fill my mind with Your peace. Let every notification, every demand, every pressure bow to the peace of Your presence. I surrender this day to You.", index: 5)
                prayerLine("In Jesus\u{2019} name, Amen.", index: 6)
            }
        }
    }

    private func pickedPrayerContent(_ prayer: Prayer) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 6) {
                Image(systemName: "book")
                    .font(.system(size: 13))
                Text("PRAYER")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1)
            }
            .foregroundStyle(.white.opacity(0.35))
            .frame(maxWidth: .infinity)
            .opacity(textLines[0] ? 1 : 0)

            VStack(alignment: .leading, spacing: 16) {
                Text(prayer.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(textLines[1] ? 1 : 0)
                    .offset(y: textLines[1] ? 0 : 10)

                Text("by \(prayer.author)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .opacity(textLines[2] ? 1 : 0)

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
                    .opacity(textLines[2] ? 1 : 0)
            }

            Text(prayer.text)
                .font(.system(size: 21, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
                .lineSpacing(10)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(textLines[3] ? 1 : 0)
                .offset(y: textLines[3] ? 0 : 12)
        }
    }

    // MARK: - Completion

    private var completionPhase: some View {
        ZStack {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(Theme.limeGreen.opacity(pulseRing ? 0.12 : 0.04))
                        .frame(width: 160, height: 160)

                    Circle()
                        .fill(Theme.limeGreen.opacity(0.08))
                        .frame(width: 120, height: 120)
                        .scaleEffect(textLines[0] ? 1 : 0.3)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.limeGreen)
                        .opacity(textLines[0] ? 1 : 0)
                        .scaleEffect(textLines[0] ? 1 : 0.3)
                }

                VStack(spacing: 12) {
                    Text("\(userName), you put God first!")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(textLines[1] ? 1 : 0)
                        .offset(y: textLines[1] ? 0 : 12)

                    Text("You just experienced what thousands of believers are doing every morning. This is what transformation looks like \u{2014} one day at a time.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(textLines[2] ? 1 : 0)
                        .offset(y: textLines[2] ? 0 : 10)
                }

                VStack(spacing: 8) {
                    completionStat(icon: "book.fill", text: "Read today\u{2019}s verse", color: Theme.skyBlue)
                    completionStat(icon: "text.book.closed.fill", text: "Studied the devotional", color: Theme.lavender)
                    completionStat(icon: "hands.sparkles.fill", text: prayerCompletionLabel, color: Theme.primary)
                }
                .opacity(textLines[3] ? 1 : 0)
                .offset(y: textLines[3] ? 0 : 10)

                Text("Imagine doing this every single day.\nYour life will never be the same.")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(.white.opacity(0.5))
                    .italic()
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(textLines[4] ? 1 : 0)
            }

            Spacer()

            VStack(spacing: 14) {
                sessionButton("See My Full Journey") {
                    onComplete()
                }
                .opacity(textLines[5] ? 1 : 0)

                Button {
                    requestAppReview()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                        Text("Love it? Rate God First")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
                .opacity(textLines[5] ? 1 : 0)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            resetTextLines()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) { textLines[0] = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) { textLines[1] = true }
            withAnimation(.easeOut(duration: 0.6).delay(1.3)) { textLines[2] = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.8)) { textLines[3] = true }
            withAnimation(.easeOut(duration: 0.5).delay(2.3)) { textLines[4] = true }
            withAnimation(.easeOut(duration: 0.5).delay(2.8)) { textLines[5] = true }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5)) {
                pulseRing = true
            }
            launchConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                requestAppReview()
            }
        }

            if confettiActive {
                TrialConfettiOverlay(pieces: confettiPieces)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }

    private func launchConfetti() {
        let colors: [Color] = [Theme.limeGreen, Theme.skyBlue, Theme.lavender, Theme.primary, Theme.dawnGold, Theme.coral, Theme.mint, .white]
        var pieces: [TrialConfettiPiece] = []
        for i in 0..<80 {
            pieces.append(TrialConfettiPiece(
                id: i,
                color: colors[i % colors.count],
                x: CGFloat.random(in: 0...1),
                speed: Double.random(in: 2.5...5.0),
                delay: Double.random(in: 0...0.8),
                spin: Double.random(in: 360...1080),
                wobble: CGFloat.random(in: 20...60),
                size: CGFloat.random(in: 5...10),
                shape: Int.random(in: 0...2)
            ))
        }
        confettiPieces = pieces
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { confettiActive = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation(.easeOut(duration: 0.6)) { confettiActive = false }
        }
    }

    // MARK: - Helpers

    private var prayerCompletionLabel: String {
        if selectedTrialPrayerMode == .pick, pickedPrayer != nil {
            return "Prayed from the library"
        }
        return "Prayed a curated prayer"
    }

    private var curatedFirstPersonPrayer: String {
        if prayerConfidence < 0.3 {
            return "Lord, I\u{2019}m honest about where I am. I want to grow in prayer but I sometimes struggle to focus. Meet me right here. You don\u{2019}t require perfection \u{2014} just a willing heart. Teach me to pray. Make it natural. Make it real. I\u{2019}m here because I want more of You."
        } else if prayerConfidence < 0.6 {
            return "Lord, I\u{2019}m building a rhythm with You. Strengthen what has already begun in me. Deepen my prayer life. Turn these moments of seeking into a lifestyle of intimacy with You. I don\u{2019}t want to just know about You \u{2014} I want to know You."
        } else {
            return "Lord, I know what it means to seek You, but I want to go deeper. Fan the flame even brighter. Take my prayer life to new depths. Use me to inspire others to put You first. Let my consistency become a testimony of Your faithfulness."
        }
    }

    private func completionStat(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Theme.limeGreen)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.06))
        )
    }

    private func prayerLine(_ text: String, index: Int) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .regular, design: .serif))
            .foregroundStyle(.white.opacity(0.9))
            .lineSpacing(10)
            .fixedSize(horizontal: false, vertical: true)
            .opacity(textLines[index] ? 1 : 0)
            .offset(y: textLines[index] ? 0 : 10)
    }

    private func resetTextLines() {
        textLines = Array(repeating: false, count: 10)
    }

    private func transitionTo(_ newPhase: SessionPhase) {
        resetTextLines()
        appear = false
        greetingLine2 = false
        showButton = false
        breatheIn = false
        pulseRing = false
        withAnimation(.easeInOut(duration: 0.4)) {
            phase = newPhase
        }
    }

    private func requestAppReview() {
        requestReview()
    }

    private func sessionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.primary.opacity(0.7), Theme.skyBlue.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Theme.primary.opacity(0.25), radius: 16, y: 6)
        }
    }
}

// MARK: - Trial Prayer Picker Sheet

nonisolated struct TrialConfettiPiece: Identifiable, Sendable {
    let id: Int
    let color: Color
    let x: CGFloat
    let speed: Double
    let delay: Double
    let spin: Double
    let wobble: CGFloat
    let size: CGFloat
    let shape: Int
}

struct TrialConfettiOverlay: View {
    let pieces: [TrialConfettiPiece]
    @State private var animate: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    TrialConfettiBit(piece: piece, animate: animate, bounds: geo.size)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.01)) {
                    animate = true
                }
            }
        }
    }
}

struct TrialConfettiBit: View {
    let piece: TrialConfettiPiece
    let animate: Bool
    let bounds: CGSize

    var body: some View {
        let startX = bounds.width * piece.x
        let endY = bounds.height + 40

        Group {
            switch piece.shape {
            case 0:
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size * 0.55)
            case 1:
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size * 0.7, height: piece.size * 0.7)
            default:
                RoundedRectangle(cornerRadius: 1)
                    .fill(piece.color)
                    .frame(width: piece.size * 0.4, height: piece.size * 1.2)
            }
        }
        .opacity(animate ? 0 : 1)
        .offset(
            x: startX + (animate ? piece.wobble * (piece.id.isMultiple(of: 2) ? 1 : -1) : 0),
            y: animate ? endY : -20
        )
        .rotationEffect(.degrees(animate ? piece.spin : 0))
        .animation(
            .easeIn(duration: piece.speed)
            .delay(piece.delay),
            value: animate
        )
    }
}

struct TrialPrayerPickerSheet: View {
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
                                        .foregroundStyle(Theme.primary)
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
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(Theme.textSecondary.opacity(0.5))
                                        }
                                        .padding(14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Theme.cardBg)
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
            .navigationTitle("Pick a Prayer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
}
