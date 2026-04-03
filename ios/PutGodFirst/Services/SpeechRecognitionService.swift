import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechRecognitionService {
    var recognizedText: String = ""
    var isListening: Bool = false
    var matchPercentage: Double = 0
    var isAuthorized: Bool = false
    var errorMessage: String?
    var hasReachedThreshold: Bool = false

    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var targetText: String = ""
    private var silenceTimer: Timer?
    private var lastTranscriptUpdate: Date = .now

    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    func requestAuthorization() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        let authorized = status == .authorized
        await MainActor.run {
            isAuthorized = authorized
        }
        return authorized
    }

    func startListening(for targetVerse: String) {
        targetText = targetVerse.lowercased()
        recognizedText = ""
        matchPercentage = 0
        hasReachedThreshold = false
        errorMessage = nil
        lastTranscriptUpdate = .now

        audioEngine = AVAudioEngine()

        guard let audioEngine, let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition not available"
            return
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest else { return }

            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.addsPunctuation = true

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
            startSilenceTimer()

            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                Task { @MainActor in
                    guard let self else { return }

                    if let result {
                        self.recognizedText = result.bestTranscription.formattedString
                        self.lastTranscriptUpdate = .now
                        self.matchPercentage = self.calculateMatch(
                            spoken: result.bestTranscription.formattedString,
                            target: targetVerse
                        )
                        if self.matchPercentage >= 0.55 {
                            self.hasReachedThreshold = true
                        }
                        self.resetSilenceTimer()
                    }

                    if let error = error as? NSError {
                        if error.domain == "kAFAssistantErrorDomain" && error.code == 1110 {
                            if self.matchPercentage < 0.3 {
                                self.errorMessage = "No speech detected. Try again."
                            }
                        } else if !self.hasReachedThreshold && self.matchPercentage < 0.3 {
                            self.errorMessage = "Could not recognize speech clearly"
                        }
                    }
                }
            }
        } catch {
            errorMessage = "Could not start recording"
            isListening = false
        }
    }

    private func startSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 45.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isListening else { return }
                if !self.hasReachedThreshold {
                    self.errorMessage = "Time's up. Try reading the verse again."
                }
            }
        }
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isListening else { return }
                if self.hasReachedThreshold {
                    return
                }
            }
        }
    }

    func stopListening() {
        silenceTimer?.invalidate()
        silenceTimer = nil
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine = nil
        isListening = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func calculateMatch(spoken: String, target: String) -> Double {
        let spokenWords = Set(spoken.lowercased()
            .components(separatedBy: .punctuationCharacters).joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty })
        let targetWords = Set(target.lowercased()
            .components(separatedBy: .punctuationCharacters).joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty })

        guard !targetWords.isEmpty else { return 0 }

        let matched = spokenWords.intersection(targetWords).count
        return Double(matched) / Double(targetWords.count)
    }
}
