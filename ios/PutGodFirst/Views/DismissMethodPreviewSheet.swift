import SwiftUI

struct DismissMethodPreviewSheet: View {
    let method: AlarmDismissMethod
    let sampleVerse: AlarmVerse
    @Environment(\.dismiss) private var dismiss
    @State private var pulsePhase: Bool = false
    @State private var waveAmplitudes: [CGFloat] = Array(repeating: 0.3, count: 7)
    @State private var simulatedMatch: Double = 0
    @State private var showMatchBar: Bool = false
    @State private var highlightedWords: Int = 0

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.top, 8)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        heroSection
                        previewContent
                        howItFeelsCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }

                selectButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            Color(red: 0.04, green: 0.03, blue: 0.12)

            let c1 = method.gradientColors.Color1
            let c2 = method.gradientColors.Color2
            RadialGradient(
                colors: [
                    Color(red: c1.r, green: c1.g, blue: c1.b).opacity(0.15),
                    Color(red: c2.r, green: c2.g, blue: c2.b).opacity(0.05),
                    Color.clear
                ],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
        }
    }

    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }

            Spacer()

            Text("PREVIEW")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1.5)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            let c1 = method.gradientColors.Color1
            let c2 = method.gradientColors.Color2
            let gradient = LinearGradient(
                colors: [
                    Color(red: c1.r, green: c1.g, blue: c1.b),
                    Color(red: c2.r, green: c2.g, blue: c2.b)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            ZStack {
                Circle()
                    .fill(gradient.opacity(0.15))
                    .frame(width: 130, height: 130)
                    .scaleEffect(pulsePhase ? 1.12 : 0.95)

                Circle()
                    .fill(gradient.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: method.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(gradient)
                    .shadow(color: Color(red: c1.r, green: c1.g, blue: c1.b).opacity(0.5), radius: 12)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulsePhase = true
                }
            }

            Text(method.rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text(method == .scanBible
                 ? "Take a photo of your OPEN Bible to turn off your alarm"
                 : "Read a Bible verse out loud to turn off your alarm")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var previewContent: some View {
        if method == .scanBible {
            scanBiblePreview
        } else {
            reciteVersePreview
        }
    }

    private var scanBiblePreview: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("What you'll see")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        Text("Take a photo of your ")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        Text("OPEN Bible")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .underline(true, color: .white)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.1, green: 0.08, blue: 0.18))
                            .frame(height: 180)

                        VStack {
                            HStack {
                                CornerBracket(rotation: 0)
                                Spacer()
                                CornerBracket(rotation: 90)
                            }
                            Spacer()
                            HStack {
                                CornerBracket(rotation: 270)
                                Spacer()
                                CornerBracket(rotation: 180)
                            }
                        }
                        .padding(16)
                        .frame(height: 180)

                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
                    }

                    ZStack {
                        Circle()
                            .strokeBorder(.white.opacity(0.4), lineWidth: 3)
                            .frame(width: 52, height: 52)
                        Circle()
                            .fill(Color(red: 0.06, green: 0.04, blue: 0.12))
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.06))
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
            }

            stepsView(steps: [
                (icon: "1.circle.fill", text: "Your alarm goes off"),
                (icon: "2.circle.fill", text: "Tap \"Open Camera\" to start"),
                (icon: "3.circle.fill", text: "Point at your OPEN Bible & snap a photo"),
                (icon: "4.circle.fill", text: "AI confirms it's a Bible — alarm turns off!")
            ])
        }
    }

    private var reciteVersePreview: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("What you'll see")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    Text(sampleVerse.reference)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.dawnGold)
                        .tracking(0.8)

                    verseWithHighlights

                    if showMatchBar {
                        matchBarPreview
                    }

                    micWaveformPreview
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.06))
                .clipShape(.rect(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
                .onAppear {
                    startSimulatedRecitation()
                }
            }

            stepsView(steps: [
                (icon: "1.circle.fill", text: "Your alarm goes off"),
                (icon: "2.circle.fill", text: "A random Bible verse appears on screen"),
                (icon: "3.circle.fill", text: "Tap \"Begin Reading\" and read it aloud"),
                (icon: "4.circle.fill", text: "Match 55% of the words — alarm stops!")
            ])
        }
    }

    private var verseWithHighlights: some View {
        let words = sampleVerse.text.components(separatedBy: " ")
        return Text(words.enumerated().map { index, word in
            if index < highlightedWords {
                return AttributedString(word + " ", attributes: AttributeContainer([
                    .foregroundColor: UIColor.white
                ]))
            } else {
                return AttributedString(word + " ", attributes: AttributeContainer([
                    .foregroundColor: UIColor.white.withAlphaComponent(0.35)
                ]))
            }
        }.reduce(AttributedString(), +))
        .font(.system(size: 17, weight: .medium, design: .serif))
        .multilineTextAlignment(.center)
        .lineSpacing(5)
    }

    private var matchBarPreview: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Match")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Text("\(Int(simulatedMatch * 100))%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(simulatedMatch >= 0.55 ? Theme.successEmerald : Theme.dawnAmber)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 5)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(simulatedMatch >= 0.55 ? Theme.successEmerald : Theme.dawnAmber)
                        .frame(width: geo.size.width * simulatedMatch, height: 5)
                }
            }
            .frame(height: 5)
        }
    }

    private var micWaveformPreview: some View {
        HStack(spacing: 3) {
            ForEach(0..<7, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Theme.dawnAmber, Theme.dawnGold],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3, height: waveAmplitudes[i] * 24)
                    .animation(
                        .easeInOut(duration: 0.25)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.06),
                        value: waveAmplitudes[i]
                    )
            }
        }
        .frame(height: 24)
        .onAppear {
            animateWaveform()
        }
    }

    private func stepsView(steps: [(icon: String, text: String)]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How it works")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)

            ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                HStack(spacing: 12) {
                    Image(systemName: step.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                colors: methodGradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28)

                    Text(step.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var howItFeelsCard: some View {
        HStack(spacing: 14) {
            Image(systemName: method == .scanBible ? "sparkles" : "waveform")
                .font(.system(size: 22))
                .foregroundStyle(
                    LinearGradient(
                        colors: methodGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(method == .scanBible ? "Start your day in the Word" : "Speak God's Word first thing")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(method == .scanBible
                     ? "Opening your Bible first thing in the morning sets the tone for a God-centered day."
                     : "Speaking Scripture out loud plants seeds of faith in your heart before anything else.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var selectButton: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                Text("Use \(method.rawValue)")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: methodGradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 28))
        }
    }

    private var methodGradientColors: [Color] {
        let c1 = method.gradientColors.Color1
        let c2 = method.gradientColors.Color2
        return [
            Color(red: c1.r, green: c1.g, blue: c1.b),
            Color(red: c2.r, green: c2.g, blue: c2.b)
        ]
    }

    private func startSimulatedRecitation() {
        let words = sampleVerse.text.components(separatedBy: " ")
        let totalWords = words.count

        for i in 0...totalWords {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.35) {
                withAnimation(.easeOut(duration: 0.3)) {
                    highlightedWords = i
                    simulatedMatch = min(Double(i) / Double(totalWords), 1.0)
                    if i > 0 { showMatchBar = true }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalWords) * 0.35 + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                highlightedWords = 0
                simulatedMatch = 0
                showMatchBar = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                startSimulatedRecitation()
            }
        }
    }

    private func animateWaveform() {
        for i in 0..<waveAmplitudes.count {
            waveAmplitudes[i] = CGFloat.random(in: 0.3...1.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animateWaveform()
        }
    }
}
