import SwiftUI

struct ScriptureUnlockView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var speechService = SpeechRecognitionService()
    @State private var currentVerse: AlarmVerse = AlarmVerseLibrary.randomVerse()
    @State private var pulseListening: Bool = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var glowPulse: Bool = false
    @State private var showSuccess: Bool = false
    @State private var successScale: CGFloat = 0.5
    @State private var successOpacity: Double = 0
    @State private var showVersePicker: Bool = false
    @State private var searchText: String = ""
    @State private var showEmergencyConfirm: Bool = false
    @State private var emergencyCountdown: Int = 0
    @State private var emergencyTimer: Timer?
    @Environment(\.colorScheme) private var colorScheme

    var onUnlocked: (() -> Void)?

    private var matchColor: Color {
        let pct = speechService.matchPercentage
        if pct >= 0.55 { return Theme.successEmerald }
        if pct >= 0.3 { return Theme.dawnAmber }
        return Theme.textSecondary.opacity(0.4)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.03, blue: 0.12),
                        Color(red: 0.06, green: 0.04, blue: 0.18),
                        Color(red: 0.04, green: 0.03, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: 16)

                    VStack(spacing: 6) {
                        Text("Recite Scripture")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        Text("to unlock your apps")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .multilineTextAlignment(.center)

                    Spacer().frame(height: 28)

                    verseCard

                    Spacer().frame(height: 20)

                    if speechService.isListening {
                        matchProgressView
                        Spacer().frame(height: 14)
                    }

                    Spacer()

                    if !speechService.recognizedText.isEmpty && speechService.isListening {
                        recognizedTextView
                        Spacer().frame(height: 14)
                    }

                    if speechService.hasReachedThreshold && speechService.isListening {
                        doneReadingButton
                        Spacer().frame(height: 12)
                    }

                    recordButton

                    Spacer().frame(height: 16)

                    HStack(spacing: 20) {
                        Button {
                            currentVerse = AlarmVerseLibrary.randomVerse()
                            speechService.stopListening()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 13))
                                Text("Shuffle")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.white.opacity(0.5))
                        }

                        Button {
                            showVersePicker = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 13))
                                Text("Choose Verse")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.white.opacity(0.5))
                        }
                    }

                    Spacer().frame(height: 20)

                    emergencyUnlockButton

                    Spacer().frame(height: 24)
                }
                .padding(.horizontal, 24)

                if showSuccess {
                    successOverlay
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        speechService.stopListening()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showVersePicker) {
                versePickerSheet
            }
        }
    }

    private var verseCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .font(.system(size: 12))
                Text(currentVerse.reference)
                    .font(.system(size: 14, weight: .bold))
                    .tracking(0.8)
            }
            .foregroundStyle(Theme.dawnGold)

            Text(currentVerse.text)
                .font(.system(size: 19, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.06))
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    speechService.hasReachedThreshold
                        ? Theme.successEmerald.opacity(0.4)
                        : Color.white.opacity(0.08),
                    lineWidth: speechService.hasReachedThreshold ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.4), value: speechService.hasReachedThreshold)
    }

    private var matchProgressView: some View {
        VStack(spacing: 8) {
            HStack {
                if speechService.hasReachedThreshold {
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
                Text("\(Int(speechService.matchPercentage * 100))%")
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
                        .frame(width: geo.size.width * min(speechService.matchPercentage, 1.0), height: 6)
                        .animation(.spring(response: 0.4), value: speechService.matchPercentage)
                }
            }
            .frame(height: 6)

            if !speechService.hasReachedThreshold {
                Text("Read the verse aloud \u{2014} take your time")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }

    private var recognizedTextView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Text(speechService.recognizedText)
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
            speechService.stopListening()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSuccess = true
                successScale = 1.0
                successOpacity = 1.0
            }
            ScreenTimeService.shared.clearManualFocusLock()
            ScriptureUnlockService.shared.unlockAppsWithScripture()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onUnlocked?()
                dismiss()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 18))
                Text("Unlock My Apps")
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
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: speechService.hasReachedThreshold)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }

    private var recordButton: some View {
        VStack(spacing: 12) {
            if speechService.isListening {
                Button {
                    speechService.stopListening()
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
                    Task {
                        let authorized = await speechService.requestAuthorization()
                        if authorized {
                            speechService.startListening(for: currentVerse.text)
                        }
                    }
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

            if let error = speechService.errorMessage {
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
        .onAppear { pulseListening = true }
        .onDisappear { pulseListening = false }
    }

    private var filteredVerses: [AlarmVerse] {
        if searchText.isEmpty { return AlarmVerseLibrary.verses }
        return AlarmVerseLibrary.verses.filter {
            $0.reference.localizedStandardContains(searchText) ||
            $0.text.localizedStandardContains(searchText)
        }
    }

    private var versePickerSheet: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.04, green: 0.03, blue: 0.12)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredVerses) { verse in
                            Button {
                                currentVerse = verse
                                speechService.stopListening()
                                showVersePicker = false
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(verse.reference)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Theme.dawnGold)
                                        Spacer()
                                        if verse.id == currentVerse.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Theme.successEmerald)
                                        }
                                    }
                                    Text(verse.text)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(3)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(verse.id == currentVerse.id ? 0.1 : 0.05))
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(
                                            verse.id == currentVerse.id
                                                ? Theme.dawnGold.opacity(0.4)
                                                : Color.white.opacity(0.06),
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .searchable(text: $searchText, prompt: "Search verses...")
            .navigationTitle("Choose a Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showVersePicker = false }
                        .foregroundStyle(Theme.dawnGold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationBackground(Color(red: 0.04, green: 0.03, blue: 0.12))
    }

    private var emergencyUnlockButton: some View {
        VStack(spacing: 8) {
            if showEmergencyConfirm {
                VStack(spacing: 12) {
                    Text("Are you sure?")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("Scripture builds your spiritual armor.\nUse this only when truly needed.")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.35))
                        .multilineTextAlignment(.center)

                    Button {
                        if emergencyCountdown <= 0 {
                            performEmergencyUnlock()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .font(.system(size: 14))
                            if emergencyCountdown > 0 {
                                Text("Wait \(emergencyCountdown)s...")
                                    .font(.system(size: 14, weight: .semibold))
                            } else {
                                Text("Emergency Unlock")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundStyle(emergencyCountdown > 0 ? .white.opacity(0.3) : Theme.coral)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Theme.coral.opacity(emergencyCountdown > 0 ? 0.05 : 0.12))
                        .clipShape(.rect(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .strokeBorder(Theme.coral.opacity(emergencyCountdown > 0 ? 0.08 : 0.25), lineWidth: 1)
                        )
                    }
                    .disabled(emergencyCountdown > 0)

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showEmergencyConfirm = false
                        }
                        emergencyTimer?.invalidate()
                        emergencyTimer = nil
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.04))
                .clipShape(.rect(cornerRadius: 16))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showEmergencyConfirm = true
                        emergencyCountdown = 5
                    }
                    startEmergencyCountdown()
                } label: {
                    Text("Can't recite right now?")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showEmergencyConfirm)
    }

    private func startEmergencyCountdown() {
        emergencyTimer?.invalidate()
        emergencyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if emergencyCountdown > 0 {
                    emergencyCountdown -= 1
                } else {
                    emergencyTimer?.invalidate()
                    emergencyTimer = nil
                }
            }
        }
    }

    private func performEmergencyUnlock() {
        speechService.stopListening()
        ScreenTimeService.shared.clearManualFocusLock()
        ScriptureUnlockService.shared.unlockAppsWithScripture()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showSuccess = true
            successScale = 1.0
            successOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onUnlocked?()
            dismiss()
        }
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.successEmerald.opacity(0.3), Theme.successEmerald.opacity(0.05), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)

                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.successEmerald)
                        .shadow(color: Theme.successEmerald.opacity(0.6), radius: 20)
                }

                Text("Apps Unlocked!")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("Great job memorizing scripture.\nWalk in the Word today.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .scaleEffect(successScale)
            .opacity(successOpacity)
        }
    }
}
