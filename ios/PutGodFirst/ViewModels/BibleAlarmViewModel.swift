import SwiftUI
import Observation

@Observable
final class BibleAlarmViewModel {
    var alarm: BibleAlarm
    var isAlarmRinging: Bool = false
    var showCamera: Bool = false
    var capturedImage: UIImage? = nil
    var isVerifying: Bool = false
    var verificationResult: VerificationResult? = nil
    var showSetup: Bool = false

    var currentVerse: AlarmVerse = AlarmVerseLibrary.randomVerse()
    var dismissPhase: AlarmDismissPhase = .missionSelect
    var speechService = SpeechRecognitionService()
    var verseCompleted: Bool = false
    var showSuccessCelebration: Bool = false

    init() {
        self.alarm = BibleAlarmService.loadAlarm()
    }

    var alarmTimeBinding: Date {
        get {
            var comps = DateComponents()
            comps.hour = alarm.hour
            comps.minute = alarm.minute
            return Calendar.current.date(from: comps) ?? .now
        }
        set {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            alarm.hour = comps.hour ?? 6
            alarm.minute = comps.minute ?? 0
        }
    }

    var permissionDenied: Bool = false
    var notificationsEnabled: Bool = false

    func checkPermissionStatus() {
        Task {
            notificationsEnabled = await BibleAlarmService.checkNotificationStatus()
        }
    }

    func toggleAlarm(_ enabled: Bool) {
        if enabled {
            BibleAlarmService.requestNotificationPermission { granted in
                if granted {
                    self.alarm.isEnabled = true
                    self.permissionDenied = false
                    BibleAlarmService.scheduleAlarm(self.alarm)
                    self.checkPermissionStatus()
                } else {
                    self.alarm.isEnabled = false
                    self.permissionDenied = true
                    BibleAlarmService.saveAlarm(self.alarm)
                }
            }
        } else {
            alarm.isEnabled = false
            permissionDenied = false
            BibleAlarmService.cancelAlarm()
            BibleAlarmService.saveAlarm(alarm)
        }
    }

    func toggleDay(_ day: Int) {
        if alarm.repeatDays.contains(day) {
            if alarm.repeatDays.count > 1 {
                alarm.repeatDays.remove(day)
            }
        } else {
            alarm.repeatDays.insert(day)
        }
        if alarm.isEnabled {
            BibleAlarmService.scheduleAlarm(alarm)
        } else {
            BibleAlarmService.saveAlarm(alarm)
        }
    }

    func saveTime() {
        if alarm.isEnabled {
            BibleAlarmService.scheduleAlarm(alarm)
        } else {
            BibleAlarmService.saveAlarm(alarm)
        }
    }

    func triggerAlarm() {
        currentVerse = AlarmVerseLibrary.randomVerse()
        verseCompleted = false
        showSuccessCelebration = false
        AlarmAudioService.shared.playLoopingAlarm(
            sound: alarm.sound,
            vibration: alarm.vibration,
            volume: Float(alarm.volume)
        )
        isAlarmRinging = true
        verificationResult = nil
        capturedImage = nil
        switch alarm.dismissMethod {
        case .scanBible:
            dismissPhase = .scanBible
        case .reciteVerse:
            dismissPhase = .reciteVerse
        }
    }

    func selectMission(_ method: AlarmDismissMethod) {
        alarm.dismissMethod = method
        switch method {
        case .scanBible:
            dismissPhase = .scanBible
        case .reciteVerse:
            dismissPhase = .reciteVerse
        }
    }

    func startVerseRecitation() {
        AlarmAudioService.shared.stopPlayback()
        Task {
            let authorized = await speechService.requestAuthorization()
            if authorized {
                speechService.startListening(for: currentVerse.text)
            }
        }
    }

    func stopVerseRecitation() {
        speechService.stopListening()
        if speechService.hasReachedThreshold {
            verseCompleted = true
            showSuccessCelebration = true
        }
    }

    func dismissAlarm() {
        AlarmAudioService.shared.stopPlayback()
        speechService.stopListening()
        BibleAlarmService.cancelFollowUps()
        isAlarmRinging = false
        verificationResult = nil
        capturedImage = nil
        dismissPhase = .missionSelect
        verseCompleted = false
        showSuccessCelebration = false
    }

    func verifyPhoto(_ image: UIImage) {
        capturedImage = image
        isVerifying = true
        verificationResult = nil

        Task {
            let result = await BibleDetectionService.shared.detectBible(in: image)
            await MainActor.run {
                isVerifying = false
                if result.isBible {
                    verificationResult = .success
                    AlarmAudioService.shared.stopPlayback()
                    showSuccessCelebration = true
                } else {
                    verificationResult = .failure
                }
            }
        }
    }

    func retryCapture() {
        capturedImage = nil
        verificationResult = nil
        showCamera = true
    }

    func setSound(_ sound: AlarmSound) {
        alarm.sound = sound
        AlarmAudioService.shared.previewSound(sound, volume: Float(alarm.volume))
        if alarm.isEnabled {
            BibleAlarmService.scheduleAlarm(alarm)
        } else {
            BibleAlarmService.saveAlarm(alarm)
        }
    }

    func setVibration(_ vibration: AlarmVibration) {
        alarm.vibration = vibration
        AlarmAudioService.shared.previewVibration(vibration)
        if alarm.isEnabled {
            BibleAlarmService.scheduleAlarm(alarm)
        } else {
            BibleAlarmService.saveAlarm(alarm)
        }
    }

    func setVolume(_ volume: Double) {
        alarm.volume = volume
        BibleAlarmService.saveAlarm(alarm)
    }

    func setDismissMethod(_ method: AlarmDismissMethod) {
        alarm.dismissMethod = method
        BibleAlarmService.saveAlarm(alarm)
    }
}

enum VerificationResult {
    case success
    case failure
}

enum AlarmDismissPhase {
    case missionSelect
    case scanBible
    case reciteVerse
    case success
}
