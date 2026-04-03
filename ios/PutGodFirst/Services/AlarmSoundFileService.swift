import Foundation
import AVFoundation

nonisolated enum AlarmSoundFileService {
    private static let sampleRate: Double = 44100
    private static let duration: Double = 30.0
    private static let generatedKey = "alarmSoundsGenerated_v6"

    static func soundFileName(for sound: AlarmSound) -> String {
        sound.rawValue.replacingOccurrences(of: " ", with: "_") + ".wav"
    }

    static var soundsDirectory: URL {
        let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        return library.appendingPathComponent("Sounds", isDirectory: true)
    }

    static func ensureSoundsExist() {
        let generated = UserDefaults.standard.bool(forKey: generatedKey)
        if generated {
            let firstFile = soundsDirectory.appendingPathComponent(soundFileName(for: .radar))
            if FileManager.default.fileExists(atPath: firstFile.path) {
                return
            }
        }
        generateAllSounds()
    }

    static func generateAllSounds() {
        let fm = FileManager.default
        if !fm.fileExists(atPath: soundsDirectory.path) {
            try? fm.createDirectory(at: soundsDirectory, withIntermediateDirectories: true)
        }

        let renderer = AudioRenderState()
        for sound in AlarmSound.allCases {
            renderer.soundType = sound
            renderer.renderTime = 0
            renderWavFile(renderer: renderer, sound: sound)
        }

        UserDefaults.standard.set(true, forKey: generatedKey)
    }

    static func regenerateSound(_ sound: AlarmSound) {
        let fm = FileManager.default
        if !fm.fileExists(atPath: soundsDirectory.path) {
            try? fm.createDirectory(at: soundsDirectory, withIntermediateDirectories: true)
        }
        let renderer = AudioRenderState()
        renderer.soundType = sound
        renderer.renderTime = 0
        renderWavFile(renderer: renderer, sound: sound)
    }

    private static func renderWavFile(renderer: AudioRenderState, sound: AlarmSound) {
        let totalSamples = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: totalSamples)

        let fadeInSamples = Int(sampleRate * 0.05)

        for i in 0..<totalSamples {
            let t = renderer.renderTime
            let raw = renderer.generateSample(time: t, sampleRate: sampleRate)
            var sample = Float(max(-1.0, min(1.0, raw)))

            if i < fadeInSamples {
                sample *= Float(i) / Float(fadeInSamples)
            }

            samples[i] = sample
            renderer.renderTime += 1.0 / sampleRate
        }

        let fileURL = soundsDirectory.appendingPathComponent(soundFileName(for: sound))

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalSamples)) else {
            return
        }

        buffer.frameLength = AVAudioFrameCount(totalSamples)
        guard let channelData = buffer.floatChannelData?[0] else { return }
        for i in 0..<totalSamples {
            channelData[i] = samples[i]
        }

        try? FileManager.default.removeItem(at: fileURL)

        guard let audioFile = try? AVAudioFile(
            forWriting: fileURL,
            settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false
            ]
        ) else { return }

        try? audioFile.write(from: buffer)
    }
}
