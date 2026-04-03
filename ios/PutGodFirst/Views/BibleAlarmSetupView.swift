import SwiftUI

struct BibleAlarmSetupView: View {
    @Bindable var alarmVM: BibleAlarmViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSoundPicker: Bool = false
    @State private var showVibrationPicker: Bool = false
    @State private var showDismissPreview: Bool = false
    @State private var previewMethod: AlarmDismissMethod = .scanBible
    @State private var appearAnimation: Bool = false
    @State private var audioService = AlarmAudioService.shared

    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    private let dayValues = [1, 2, 3, 4, 5, 6, 7]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    timePickerCard
                    enableToggleCard
                    dismissMethodCard
                    repeatDaysCard
                    soundCard
                    vibrationCard
                    volumeCard
                    howItWorksCard
                    testAlarmButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Bible Alarm")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.icePurple)
                }
            }
            .sheet(isPresented: $showSoundPicker) {
                SoundPickerSheet(alarmVM: alarmVM)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showVibrationPicker) {
                VibrationPickerSheet(alarmVM: alarmVM)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showDismissPreview) {
                DismissMethodPreviewSheet(
                    method: previewMethod,
                    sampleVerse: AlarmVerseLibrary.randomVerse()
                )
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appearAnimation = true
                }
                alarmVM.checkPermissionStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                alarmVM.checkPermissionStatus()
            }
        }
    }

    private var timePickerCard: some View {
        VStack(spacing: 0) {
            DatePicker("Alarm Time", selection: Binding(
                get: { alarmVM.alarmTimeBinding },
                set: { newValue in
                    alarmVM.alarmTimeBinding = newValue
                    alarmVM.saveTime()
                }
            ), displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .background(Theme.cardBg)
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }

    private var enableToggleCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [Theme.dawnGold.opacity(0.2), Theme.dawnAmber.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Image(systemName: "alarm.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.dawnGold, Theme.dawnAmber],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Alarm Enabled")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Photo your OPEN Bible to turn off")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarmVM.alarm.isEnabled },
                set: { alarmVM.toggleAlarm($0) }
            ))
            .labelsHidden()
            .tint(Theme.dawnAmber)
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
        .overlay(
            Group {
                if alarmVM.permissionDenied {
                    VStack(spacing: 8) {
                        Text("Notification permission required")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.coral)
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.iceBlue)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Theme.coral.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal, 12)
                    .offset(y: 56)
                }
            },
            alignment: .bottom
        )
    }

    private var dismissMethodCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.dawnAmber)
                Text("DISMISS METHOD")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)
            }

            HStack(spacing: 10) {
                ForEach(AlarmDismissMethod.allCases) { method in
                    let isSelected = alarmVM.alarm.dismissMethod == method
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
                    let accentColor = Color(red: c1.r, green: c1.g, blue: c1.b)

                    VStack(spacing: 0) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                alarmVM.setDismissMethod(method)
                            }
                        } label: {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? AnyShapeStyle(gradient) : AnyShapeStyle(Color(.tertiarySystemFill)))
                                        .frame(width: 48, height: 48)

                                    Image(systemName: method.icon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(isSelected ? .white : Theme.textSecondary)
                                }

                                Text(method.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textSecondary)

                                Text(method.subtitle)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 8)
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.selection, trigger: isSelected)

                        Button {
                            previewMethod = method
                            showDismissPreview = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 10))
                                Text("Preview")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(isSelected ? accentColor : Theme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(isSelected ? accentColor.opacity(0.12) : Color(.tertiarySystemFill))
                            .clipShape(.rect(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 10)
                    }
                    .background(
                        isSelected
                        ? AnyShapeStyle(accentColor.opacity(0.08))
                        : AnyShapeStyle(Color.clear)
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isSelected
                                ? accentColor.opacity(0.3)
                                : Color(.separator).opacity(0.2),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
                }
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }

    private var repeatDaysCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.icePurple)
                Text("REPEAT")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)
            }

            HStack(spacing: 6) {
                ForEach(Array(zip(dayValues, dayLabels)), id: \.0) { day, label in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            alarmVM.toggleDay(day)
                        }
                    } label: {
                        Text(label)
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                alarmVM.alarm.repeatDays.contains(day)
                                ? AnyShapeStyle(Theme.primaryGradient)
                                : AnyShapeStyle(Color(.tertiarySystemFill))
                            )
                            .foregroundStyle(alarmVM.alarm.repeatDays.contains(day) ? .white : Theme.textSecondary)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: alarmVM.alarm.repeatDays.contains(day))
                }
            }

            Text(alarmVM.alarm.repeatDescription)
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }

    private var soundCard: some View {
        Button {
            showSoundPicker = true
        } label: {
            HStack(spacing: 14) {
                let ac = alarmVM.alarm.sound.accentColor
                let accentColor = Color(red: ac.r, green: ac.g, blue: ac.b)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.2), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)

                    Image(systemName: alarmVM.alarm.sound.icon)
                        .font(.system(size: 17))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Alarm Sound")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(alarmVM.alarm.sound.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .background(Theme.cardBg)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }

    private var vibrationCard: some View {
        Button {
            showVibrationPicker = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Theme.icePurple.opacity(0.2), Theme.icePurple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)

                    Image(systemName: alarmVM.alarm.vibration.icon)
                        .font(.system(size: 17))
                        .foregroundStyle(Theme.icePurple)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Vibration")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(alarmVM.alarm.vibration.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .background(Theme.cardBg)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }

    private var volumeCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.iceBlue)
                Text("VOLUME")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)
                Spacer()
                Text("\(Int(alarmVM.alarm.volume * 100))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.iceBlue)
            }

            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)

                Slider(value: Binding(
                    get: { alarmVM.alarm.volume },
                    set: { alarmVM.setVolume($0) }
                ), in: 0.1...1.0, step: 0.1)
                .tint(Theme.iceBlue)

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }


    private var howItWorksCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.icePurple)
                Text("HOW IT WORKS")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.5)
            }

            VStack(alignment: .leading, spacing: 12) {
                howItWorksStep(number: 1, icon: "alarm.fill", text: "Your alarm goes off at the set time")
                howItWorksStep(number: 2, icon: "camera.fill", text: "Take a photo of your OPEN Bible to turn it off")
                howItWorksStep(number: 3, icon: "checkmark.circle.fill", text: "Bible detected \u{2014} alarm turns off, you\u{2019}re up!")
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }

    private func howItWorksStep(number: Int, icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.icePurple.opacity(0.12))
                    .frame(width: 32, height: 32)
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.icePurple)
            }

            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var testAlarmButton: some View {
        Button {
            if audioService.isPlaying {
                AlarmAudioService.shared.stopPlayback()
            } else {
                AlarmAudioService.shared.playTestAlarm(
                    sound: alarmVM.alarm.sound,
                    vibration: alarmVM.alarm.vibration,
                    volume: Float(alarmVM.alarm.volume)
                )
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: audioService.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 20))
                    .contentTransition(.symbolEffect(.replace))
                Text(audioService.isPlaying ? "Stop Test" : "Test Alarm")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(audioService.isPlaying ? AnyShapeStyle(Theme.coral) : AnyShapeStyle(Theme.primaryGradient))
            .clipShape(.rect(cornerRadius: 16))
            .animation(.easeInOut(duration: 0.2), value: audioService.isPlaying)
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }
}

struct SoundPickerSheet: View {
    @Bindable var alarmVM: BibleAlarmViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var audioService = AlarmAudioService.shared

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Pick the sound that gets you up.")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal, 16)

                    ForEach(AlarmSoundCategory.allCases, id: \.rawValue) { category in
                        soundCategorySection(category)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Alarm Sound")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        AlarmAudioService.shared.stopPlayback()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.icePurple)
                }
            }
            .onDisappear {
                AlarmAudioService.shared.stopPlayback()
            }
        }
    }

    private func soundCategorySection(_ category: AlarmSoundCategory) -> some View {
        let sounds = AlarmSound.allCases.filter { $0.category == category }

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: category.emoji)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.8)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(Array(sounds.enumerated()), id: \.element.id) { index, sound in
                    let isSelected = alarmVM.alarm.sound == sound
                    let ac = sound.accentColor
                    let accentColor = Color(red: ac.r, green: ac.g, blue: ac.b)
                    let isCurrentlyPlaying = audioService.isPlaying && audioService.currentlyPlayingSound == sound

                    HStack(spacing: 12) {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: sound.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            )

                        Text(sound.rawValue)
                            .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Spacer(minLength: 4)

                        Button {
                            if isCurrentlyPlaying {
                                AlarmAudioService.shared.stopPlayback()
                            } else {
                                AlarmAudioService.shared.previewSound(sound, volume: Float(alarmVM.alarm.volume))
                            }
                        } label: {
                            Image(systemName: isCurrentlyPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(isCurrentlyPlaying ? accentColor : Theme.textSecondary)
                                .frame(width: 34, height: 34)
                                .background(isCurrentlyPlaying ? accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                                .clipShape(Circle())
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                alarmVM.setSound(sound)
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .strokeBorder(isSelected ? accentColor : Color(.separator).opacity(0.3), lineWidth: isSelected ? 0 : 1.5)
                                    .frame(width: 26, height: 26)

                                if isSelected {
                                    Circle()
                                        .fill(accentColor)
                                        .frame(width: 26, height: 26)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if index < sounds.count - 1 {
                        Divider()
                            .padding(.leading, 66)
                    }
                }
            }
            .background(Theme.cardBg)
            .clipShape(.rect(cornerRadius: 14))
            .padding(.horizontal, 16)
        }
    }
}

struct VibrationPickerSheet: View {
    @Bindable var alarmVM: BibleAlarmViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tryingVibration: AlarmVibration? = nil

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(AlarmVibration.allCases) { vibration in
                        let isSelected = alarmVM.alarm.vibration == vibration

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                alarmVM.setVibration(vibration)
                            }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            isSelected
                                            ? AnyShapeStyle(LinearGradient(colors: [Theme.icePurple.opacity(0.25), Theme.icePurple.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            : AnyShapeStyle(Color(.tertiarySystemFill))
                                        )
                                        .frame(width: 42, height: 42)

                                    Image(systemName: vibration.icon)
                                        .font(.system(size: 17))
                                        .foregroundStyle(isSelected ? Theme.icePurple : Theme.textSecondary)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(vibration.rawValue)
                                        .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(vibration.subtitle)
                                        .font(.system(size: 12))
                                        .foregroundStyle(Theme.textSecondary)
                                }

                                Spacer()

                                if vibration != .none {
                                    Button {
                                        tryingVibration = vibration
                                        AlarmAudioService.shared.previewVibration(vibration)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                            if tryingVibration == vibration {
                                                tryingVibration = nil
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: tryingVibration == vibration ? "waveform" : "hand.tap.fill")
                                                .font(.system(size: 11))
                                            Text(tryingVibration == vibration ? "Feeling..." : "Try")
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .foregroundStyle(Theme.icePurple)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Theme.icePurple.opacity(tryingVibration == vibration ? 0.2 : 0.12))
                                        .clipShape(.rect(cornerRadius: 8))
                                        .contentTransition(.symbolEffect(.replace))
                                    }
                                    .buttonStyle(.plain)
                                }

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Theme.icePurple)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(14)
                        .background(
                            isSelected
                            ? AnyShapeStyle(Theme.icePurple.opacity(0.06))
                            : AnyShapeStyle(Theme.cardBg)
                        )
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(isSelected ? Theme.icePurple.opacity(0.3) : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Vibration")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.icePurple)
                }
            }
        }
    }
}
