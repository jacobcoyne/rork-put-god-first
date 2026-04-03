import SwiftUI

struct VerseRecitationView: View {
    @Bindable var alarmVM: BibleAlarmViewModel
    @State private var pulseListening: Bool = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var glowPulse: Bool = false

    private var matchColor: Color {
        let pct = alarmVM.speechService.matchPercentage
        if pct >= 0.55 { return Theme.successEmerald }
        if pct >= 0.3 { return Theme.dawnAmber }
        return Color.white.opacity(0.3)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    alarmVM.speechService.stopListening()
                    withAnimation {
                        alarmVM.dismissPhase = .scanBible
                    }
                    if !alarmVM.showSuccessCelebration {
                        AlarmAudioService.shared.playLoopingAlarm(
                            sound: alarmVM.alarm.sound,
                            vibration: alarmVM.alarm.vibration,
                            volume: Float(alarmVM.alarm.volume)
                        )
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.top, 8)

            Spacer().frame(height: 16)

            Text("Read the Bible verse aloud")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("to turn off your alarm")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)

            Spacer().frame(height: 32)

            verseCard

            Spacer().frame(height: 24)

            if alarmVM.speechService.isListening {
                matchProgressView
                Spacer().frame(height: 16)
            }

            Spacer()

            if !alarmVM.speechService.recognizedText.isEmpty && alarmVM.speechService.isListening {
                recognizedTextView
                Spacer().frame(height: 16)
            }

            if alarmVM.speechService.hasReachedThreshold && alarmVM.speechService.isListening {
                doneReadingButton
                Spacer().frame(height: 12)
            }

            recordButton

            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.04, green: 0.03, blue: 0.12).ignoresSafeArea())
        .onAppear {
            AlarmAudioService.shared.stopPlayback()
        }
    }

    private var verseCard: some View {
        VStack(spacing: 16) {
            Text(alarmVM.currentVerse.reference)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.dawnGold)
                .tracking(1)

            Text(alarmVM.currentVerse.text)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.07))
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    alarmVM.speechService.hasReachedThreshold
                        ? Theme.successEmerald.opacity(0.4)
                        : Color.white.opacity(0.1),
                    lineWidth: alarmVM.speechService.hasReachedThreshold ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.4), value: alarmVM.speechService.hasReachedThreshold)
    }

    private var matchProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                if alarmVM.speechService.hasReachedThreshold {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.successEmerald)
                            .scaleEffect(checkmarkScale)
                        Text("Verse recognized!")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.successEmerald)
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            checkmarkScale = 1.0
                        }
                    }
                } else {
                    Text("Keep reading...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Text("\(Int(alarmVM.speechService.matchPercentage * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(matchColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(matchColor)
                        .frame(width: geo.size.width * min(alarmVM.speechService.matchPercentage, 1.0), height: 6)
                        .animation(.spring(response: 0.4), value: alarmVM.speechService.matchPercentage)
                }
            }
            .frame(height: 6)

            if !alarmVM.speechService.hasReachedThreshold {
                Text("Read the verse aloud — take your time")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }

    private var recognizedTextView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Text(alarmVM.speechService.recognizedText)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 60)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var doneReadingButton: some View {
        Button {
            alarmVM.stopVerseRecitation()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                Text("I'm Done — Dismiss Alarm")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Theme.successEmerald, Theme.successEmerald.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 28))
            .shadow(color: Theme.successEmerald.opacity(glowPulse ? 0.5 : 0.2), radius: glowPulse ? 16 : 8)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: alarmVM.speechService.hasReachedThreshold)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }

    private var recordButton: some View {
        VStack(spacing: 12) {
            if alarmVM.speechService.isListening {
                Button {
                    alarmVM.speechService.stopListening()
                    if !alarmVM.speechService.hasReachedThreshold {
                        AlarmAudioService.shared.playLoopingAlarm(
                            sound: alarmVM.alarm.sound,
                            vibration: alarmVM.alarm.vibration,
                            volume: Float(alarmVM.alarm.volume)
                        )
                    }
                } label: {
                    HStack(spacing: 12) {
                        listeningWaveform
                        Text("Listening...")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.15))
                    .clipShape(.rect(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
            } else {
                Button {
                    alarmVM.startVerseRecitation()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 18))
                        Text("Begin Reading")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 28))
                }
            }

            if let error = alarmVM.speechService.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.coral.opacity(0.8))
            }
        }
    }

    private var listeningWaveform: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white)
                    .frame(width: 3, height: pulseListening ? CGFloat.random(in: 8...20) : 6)
                    .animation(
                        .easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.08),
                        value: pulseListening
                    )
            }
        }
        .onAppear {
            pulseListening = true
        }
        .onDisappear {
            pulseListening = false
        }
    }
}
