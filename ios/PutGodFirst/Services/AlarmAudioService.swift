import AVFoundation
import UIKit
import CoreHaptics
import MediaPlayer

nonisolated final class AudioRenderState: @unchecked Sendable {
    var renderTime: Double = 0
    var soundType: AlarmSound = .radar
    var volume: Float = 1.0

    func generateSample(time t: Double, sampleRate: Double) -> Double {
        switch soundType {
        case .radar: return radarSound(t)
        case .apex: return apexSound(t)
        case .beacon: return beaconSound(t)
        case .chimes: return chimesSound(t)
        case .constellation: return constellationSound(t)
        case .uplift: return upliftSound(t)
        case .pulse: return pulseSound(t)
        case .daybreak: return daybreakSound(t)
        case .serenity: return serenitySound(t)
        case .triumph: return triumphSound(t)
        case .siren: return sirenSound(t)
        case .blaring: return blaringSound(t)
        }
    }

    private func radarSound(_ t: Double) -> Double {
        let beepDuration = 0.1
        let beepGap = 0.06
        let groupGap = 0.5
        let beepsPerGroup = 4
        let groupDuration = Double(beepsPerGroup) * (beepDuration + beepGap) + groupGap
        let pos = t.truncatingRemainder(dividingBy: groupDuration)
        var sample = 0.0
        for i in 0..<beepsPerGroup {
            let beepStart = Double(i) * (beepDuration + beepGap)
            let local = pos - beepStart
            if local >= 0 && local < beepDuration {
                let env = sin(.pi * local / beepDuration)
                let freq = 1050.0
                sample += sin(2.0 * .pi * freq * local) * env * 0.9
                sample += sin(2.0 * .pi * freq * 2.0 * local) * env * 0.35
                sample += sin(2.0 * .pi * freq * 3.0 * local) * env * 0.15
            }
        }
        return sample
    }

    private func apexSound(_ t: Double) -> Double {
        let notes: [(freq: Double, start: Double, dur: Double)] = [
            (880.0, 0.0, 0.18), (988.0, 0.22, 0.18), (1109.0, 0.44, 0.18),
            (1175.0, 0.66, 0.32),
            (880.0, 1.3, 0.18), (988.0, 1.52, 0.18), (1109.0, 1.74, 0.18),
            (1319.0, 1.96, 0.32),
        ]
        let totalCycle = 3.0
        let pos = t.truncatingRemainder(dividingBy: totalCycle)
        var sample = 0.0
        for note in notes {
            let local = pos - note.start
            if local >= 0 && local < note.dur {
                let attack = min(local / 0.005, 1.0)
                let release = min((note.dur - local) / 0.02, 1.0)
                let env = attack * release * 0.75
                let f = note.freq
                sample += sin(2.0 * .pi * f * local) * env
                sample += sin(2.0 * .pi * f * 2.0 * local) * env * 0.4
                sample += sin(2.0 * .pi * f * 0.5 * local) * env * 0.2
            }
        }
        return sample
    }

    private func beaconSound(_ t: Double) -> Double {
        let cycleDuration = 1.8
        let pos = t.truncatingRemainder(dividingBy: cycleDuration)
        var sample = 0.0
        let toneStart = 0.0
        let toneDur = 0.6
        let local = pos - toneStart
        if local >= 0 && local < toneDur {
            let sweepFreq = 600.0 + (local / toneDur) * 400.0
            let attack = min(local / 0.01, 1.0)
            let decay = exp(-local * 2.5)
            let env = attack * decay * 0.65
            sample += sin(2.0 * .pi * sweepFreq * local) * env
            sample += sin(2.0 * .pi * sweepFreq * 1.5 * local) * env * 0.2
        }
        let tone2Start = 0.7
        let tone2Local = pos - tone2Start
        if tone2Local >= 0 && tone2Local < toneDur {
            let sweepFreq = 800.0 + (tone2Local / toneDur) * 300.0
            let attack = min(tone2Local / 0.01, 1.0)
            let decay = exp(-tone2Local * 2.5)
            let env = attack * decay * 0.55
            sample += sin(2.0 * .pi * sweepFreq * tone2Local) * env
        }
        return sample
    }

    private func chimesSound(_ t: Double) -> Double {
        let notes: [(freq: Double, start: Double)] = [
            (1046.5, 0.0), (1318.5, 0.35), (1568.0, 0.7),
            (1760.0, 1.05), (2093.0, 1.4),
            (1760.0, 2.2), (1568.0, 2.55), (1318.5, 2.9)
        ]
        let totalCycle = 4.5
        let pos = t.truncatingRemainder(dividingBy: totalCycle)
        var sample = 0.0
        for note in notes {
            let local = pos - note.start
            if local >= 0 && local < 1.5 {
                let attack = min(local / 0.002, 1.0)
                let decay = exp(-local * 3.0)
                let f = note.freq
                let fundamental = sin(2.0 * .pi * f * local)
                let h2 = sin(2.0 * .pi * f * 2.003 * local) * 0.4
                let h3 = sin(2.0 * .pi * f * 3.01 * local) * 0.15
                sample += (fundamental + h2 + h3) * decay * attack * 0.35
            }
        }
        return sample
    }

    private func constellationSound(_ t: Double) -> Double {
        let chords: [(freqs: [Double], start: Double, dur: Double)] = [
            ([523.25, 659.25, 783.99], 0.0, 1.8),
            ([587.33, 739.99, 880.0], 2.0, 1.8),
            ([659.25, 783.99, 987.77], 4.0, 1.8),
            ([523.25, 783.99, 1046.5], 6.0, 2.0),
        ]
        let totalCycle = 9.0
        let pos = t.truncatingRemainder(dividingBy: totalCycle)
        var sample = 0.0
        for chord in chords {
            let local = pos - chord.start
            if local >= 0 && local < chord.dur {
                let fadeIn = min(local / 0.3, 1.0)
                let fadeOut = min((chord.dur - local) / 0.4, 1.0)
                let env = fadeIn * fadeOut * 0.22
                for f in chord.freqs {
                    sample += sin(2.0 * .pi * f * local) * env
                    sample += sin(2.0 * .pi * f * 1.002 * local) * env * 0.3
                }
            }
        }
        return sample
    }

    private func upliftSound(_ t: Double) -> Double {
        let melody: [(freq: Double, start: Double, dur: Double)] = [
            (659.25, 0.0, 0.2), (783.99, 0.25, 0.2), (880.0, 0.5, 0.2),
            (1046.5, 0.75, 0.35),
            (880.0, 1.4, 0.2), (1046.5, 1.65, 0.2),
            (1174.66, 1.9, 0.2), (1318.51, 2.15, 0.4),
        ]
        let totalCycle = 3.5
        let pos = t.truncatingRemainder(dividingBy: totalCycle)
        var sample = 0.0
        for note in melody {
            let local = pos - note.start
            if local >= 0 && local < note.dur {
                let attack = min(local / 0.005, 1.0)
                let release = min((note.dur - local) / 0.03, 1.0)
                let env = attack * release * 0.5
                let f = note.freq
                sample += sin(2.0 * .pi * f * local) * env
                sample += sin(2.0 * .pi * f * 2.0 * local) * env * 0.35
                sample += sin(2.0 * .pi * f * 4.0 * local) * exp(-local * 25.0) * 0.25
            }
        }
        return sample
    }

    private func pulseSound(_ t: Double) -> Double {
        let cycleDuration = 2.0
        let pos = t.truncatingRemainder(dividingBy: cycleDuration)
        var sample = 0.0
        let beats: [(start: Double, freq: Double)] = [
            (0.0, 523.25), (0.12, 523.25), (0.24, 523.25),
            (0.48, 659.25), (0.60, 659.25),
            (0.84, 783.99),
        ]
        for beat in beats {
            let local = pos - beat.start
            if local >= 0 && local < 0.1 {
                let env = sin(.pi * local / 0.1) * 0.85
                let f = beat.freq
                sample += sin(2.0 * .pi * f * local) * env
                sample += sin(2.0 * .pi * f * 2.0 * local) * env * 0.4
            }
        }
        return sample
    }

    private func daybreakSound(_ t: Double) -> Double {
        let notes: [(freq: Double, start: Double)] = [
            (392.0, 0.0), (440.0, 0.15), (523.25, 0.3),
            (587.33, 0.45), (659.25, 0.6), (783.99, 0.75),
            (880.0, 0.9), (1046.5, 1.05),
            (880.0, 1.6), (783.99, 1.75), (659.25, 1.9),
            (523.25, 2.05)
        ]
        let totalCycle = 3.5
        let pos = t.truncatingRemainder(dividingBy: totalCycle)
        var sample = 0.0
        for note in notes {
            let local = pos - note.start
            if local >= 0 && local < 0.8 {
                let attack = min(local / 0.003, 1.0)
                let decay = exp(-local * 4.0)
                let env = attack * decay * 0.4
                let f = note.freq
                sample += sin(2.0 * .pi * f * local) * env
                sample += sin(2.0 * .pi * f * 2.0 * local) * env * 0.35
                sample += sin(2.0 * .pi * f * 1.005 * local) * env * 0.2
            }
        }
        return sample
    }

    private func serenitySound(_ t: Double) -> Double {
        let padFreqs: [Double] = [261.63, 329.63, 392.0, 523.25]
        let totalCycle = 6.0
        let pos = t.truncatingRemainder(dividingBy: totalCycle)
        var sample = 0.0
        let waveLFO = 0.5 + 0.5 * sin(2.0 * .pi * 0.15 * t)
        for f in padFreqs {
            sample += sin(2.0 * .pi * f * t) * 0.15 * waveLFO
            sample += sin(2.0 * .pi * f * 1.002 * t) * 0.08 * waveLFO
        }
        let melodyNotes: [(freq: Double, start: Double, dur: Double)] = [
            (783.99, 0.0, 1.5), (880.0, 1.8, 1.2),
            (1046.5, 3.3, 1.5), (880.0, 5.0, 1.0)
        ]
        for note in melodyNotes {
            let local = pos - note.start
            if local >= 0 && local < note.dur {
                let fadeIn = min(local / 0.2, 1.0)
                let fadeOut = min((note.dur - local) / 0.3, 1.0)
                let env = fadeIn * fadeOut * 0.3
                sample += sin(2.0 * .pi * note.freq * local) * env
            }
        }
        return sample
    }

    private func sirenSound(_ t: Double) -> Double {
        let cycleDuration = 2.0
        let pos = t.truncatingRemainder(dividingBy: cycleDuration)
        var sample = 0.0

        let sweepPhase = pos / cycleDuration
        let sweepFreq: Double
        if sweepPhase < 0.5 {
            sweepFreq = 600.0 + (sweepPhase / 0.5) * 800.0
        } else {
            sweepFreq = 1400.0 - ((sweepPhase - 0.5) / 0.5) * 800.0
        }

        sample += sin(2.0 * .pi * sweepFreq * t) * 0.7
        sample += sin(2.0 * .pi * sweepFreq * 2.0 * t) * 0.35
        sample += sin(2.0 * .pi * sweepFreq * 3.0 * t) * 0.15
        sample += sin(2.0 * .pi * sweepFreq * 0.5 * t) * 0.25

        let pulse = (sin(2.0 * .pi * 8.0 * t) > 0) ? 1.0 : 0.7
        sample *= pulse

        let volume = 0.85 + 0.15 * sin(2.0 * .pi * 0.5 * t)
        sample *= volume

        return sample
    }

    private func blaringSound(_ t: Double) -> Double {
        let cycleDuration = 0.5
        let pos = t.truncatingRemainder(dividingBy: cycleDuration)
        var sample = 0.0

        let onDuration = 0.35
        let isOn = pos < onDuration

        if isOn {
            let attack = min(pos / 0.01, 1.0)
            let sustain = min((onDuration - pos) / 0.02, 1.0)
            let env = attack * sustain

            let baseFreq = 440.0
            let wobble = 1.0 + 0.02 * sin(2.0 * .pi * 12.0 * t)
            let f = baseFreq * wobble

            sample += sin(2.0 * .pi * f * t) * 0.6
            sample += sin(2.0 * .pi * f * 2.0 * t) * 0.5
            sample += sin(2.0 * .pi * f * 3.0 * t) * 0.4
            sample += sin(2.0 * .pi * f * 4.0 * t) * 0.3
            sample += sin(2.0 * .pi * f * 5.0 * t) * 0.2
            sample += sin(2.0 * .pi * f * 6.0 * t) * 0.1

            let secondTone = 554.37 * wobble
            sample += sin(2.0 * .pi * secondTone * t) * 0.45
            sample += sin(2.0 * .pi * secondTone * 2.0 * t) * 0.35
            sample += sin(2.0 * .pi * secondTone * 3.0 * t) * 0.25

            sample *= env * 0.65
        }

        let slowPulse = 0.8 + 0.2 * sin(2.0 * .pi * 1.5 * t)
        sample *= slowPulse

        return sample
    }

    private func triumphSound(_ t: Double) -> Double {
        let calls: [(freq: Double, start: Double, dur: Double)] = [
            (523.25, 0.0, 0.12), (523.25, 0.18, 0.12),
            (659.25, 0.36, 0.12), (783.99, 0.54, 0.3),
            (659.25, 1.0, 0.12), (783.99, 1.18, 0.12),
            (1046.5, 1.36, 0.45),
        ]
        let totalCycle = 2.8
        let pos = t.truncatingRemainder(dividingBy: totalCycle)
        var sample = 0.0
        for call in calls {
            let local = pos - call.start
            if local >= 0 && local < call.dur {
                let attack = min(local / 0.005, 1.0)
                let release = min((call.dur - local) / 0.02, 1.0)
                let env = attack * release * 0.65
                let f = call.freq
                sample += sin(2.0 * .pi * f * local) * env
                sample += sin(2.0 * .pi * f * 2.0 * local) * env * 0.55
                sample += sin(2.0 * .pi * f * 3.0 * local) * env * 0.45
                sample += sin(2.0 * .pi * f * 4.0 * local) * env * 0.25
                let vibrato = 1.0 + 0.003 * sin(2.0 * .pi * 5.0 * local)
                sample *= vibrato
            }
        }
        return sample
    }
}

@Observable
final class AlarmAudioService {
    static let shared = AlarmAudioService()

    private var audioEngine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private var reverbNode: AVAudioUnitReverb?
    private var stopTimer: Timer?
    private var hapticEngine: CHHapticEngine?
    private var hapticPlayer: CHHapticPatternPlayer?
    private let renderState = AudioRenderState()

    var isPlaying: Bool = false
    var currentlyPlayingSound: AlarmSound?
    var isLooping: Bool = false

    private init() {
        prepareHaptics()
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.resetHandler = { [weak self] in
                Task { @MainActor in
                    try? self?.hapticEngine?.start()
                }
            }
            try hapticEngine?.start()
        } catch {}
    }

    func previewSound(_ sound: AlarmSound, volume: Float = 1.0) {
        stopPlayback()
        currentlyPlayingSound = sound
        renderState.soundType = sound
        renderState.volume = volume
        renderState.renderTime = 0
        isPlaying = true
        startEngine(duration: 4.0)
    }

    func playTestAlarm(sound: AlarmSound, vibration: AlarmVibration, volume: Float) {
        stopPlayback()
        currentlyPlayingSound = sound
        renderState.soundType = sound
        renderState.volume = volume
        renderState.renderTime = 0
        isPlaying = true
        startEngine(duration: 5.0)
        playHapticPattern(vibration, duration: 5.0)
    }

    func playLoopingAlarm(sound: AlarmSound, vibration: AlarmVibration, volume: Float) {
        stopPlayback()
        currentlyPlayingSound = sound
        renderState.soundType = sound
        renderState.volume = volume
        renderState.renderTime = 0
        isPlaying = true
        isLooping = true
        startEngine(duration: nil)
        playHapticPattern(vibration, duration: 60.0)
    }



    func previewVibration(_ vibration: AlarmVibration) {
        playHapticPattern(vibration, duration: 2.0)
    }

    func stopPlayback() {
        audioEngine?.stop()
        if let sourceNode {
            audioEngine?.detach(sourceNode)
        }
        if let reverbNode {
            audioEngine?.detach(reverbNode)
        }
        audioEngine = nil
        sourceNode = nil
        reverbNode = nil
        stopTimer?.invalidate()
        stopTimer = nil
        isPlaying = false
        isLooping = false
        currentlyPlayingSound = nil
        renderState.renderTime = 0
        try? hapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        hapticPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func maximizeSystemVolume() {
        let volumeView = MPVolumeView(frame: .zero)
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            slider.value = 1.0
        }
    }

    private func startEngine(duration: Double?) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            maximizeSystemVolume()
        } catch { return }

        let engine = AVAudioEngine()
        let outputFormat = engine.outputNode.outputFormat(forBus: 0)
        let sampleRate = outputFormat.sampleRate
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }

        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(reverbPreset(for: renderState.soundType))
        reverb.wetDryMix = reverbMix(for: renderState.soundType)

        let state = renderState
        let src = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let buf = ablPointer[0]
            let ptr = buf.mData!.assumingMemoryBound(to: Float.self)
            let vol = state.volume
            for frame in 0..<Int(frameCount) {
                let t = state.renderTime
                let raw = state.generateSample(time: t, sampleRate: sampleRate)
                let clamped = max(-1.0, min(1.0, raw))
                ptr[frame] = Float(clamped) * vol
                state.renderTime += 1.0 / sampleRate
            }
            return noErr
        }

        engine.attach(src)
        engine.attach(reverb)
        engine.connect(src, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 1.0

        do {
            try engine.start()
            self.audioEngine = engine
            self.sourceNode = src
            self.reverbNode = reverb

            if let duration {
                stopTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                    Task { @MainActor in
                        self?.stopPlayback()
                    }
                }
            }
        } catch {}
    }

    private func reverbPreset(for sound: AlarmSound) -> AVAudioUnitReverbPreset {
        switch sound {
        case .chimes, .constellation, .serenity:
            return .mediumHall
        case .daybreak:
            return .mediumChamber
        case .radar, .pulse, .triumph:
            return .smallRoom
        case .apex, .uplift:
            return .smallRoom
        case .beacon:
            return .plate
        case .siren:
            return .largeHall
        case .blaring:
            return .smallRoom
        }
    }

    private func reverbMix(for sound: AlarmSound) -> Float {
        switch sound {
        case .chimes: return 28
        case .constellation, .serenity: return 32
        case .daybreak: return 22
        case .apex, .uplift: return 15
        case .radar: return 8
        case .triumph: return 18
        case .pulse: return 10
        case .beacon: return 20
        case .siren: return 12
        case .blaring: return 5
        }
    }

    private func playHapticPattern(_ vibration: AlarmVibration, duration: Double) {
        guard vibration != .none else { return }
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            playFallbackVibration(vibration)
            return
        }

        if hapticEngine == nil { prepareHaptics() }
        guard let hapticEngine else {
            playFallbackVibration(vibration)
            return
        }

        do {
            let pattern: CHHapticPattern
            switch vibration {
            case .standard:
                pattern = try standardHapticPattern(duration: min(duration, 8.0))
            case .persistent:
                pattern = try persistentHapticPattern(duration: min(duration, 8.0))
            case .gentle:
                pattern = try gentleHapticPattern(duration: min(duration, 8.0))
            case .none:
                return
            }

            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticPlayer = player
        } catch {
            playFallbackVibration(vibration)
        }
    }

    private func standardHapticPattern(duration: Double) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        let count = max(Int(duration / 0.6), 3)
        for i in 0..<count {
            let time = Double(i) * 0.6
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: time
            ))
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: time + 0.05,
                duration: 0.3
            ))
        }
        return try CHHapticPattern(events: events, parameters: [])
    }

    private func persistentHapticPattern(duration: Double) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        let transientCount = max(Int(duration / 0.15), 20)
        for i in 0..<transientCount {
            let time = Double(i) * 0.15
            let intensity: Float = (i % 4 == 0) ? 1.0 : 0.9
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: time
            ))
        }
        let contCount = max(Int(duration / 0.6), 1)
        for i in 0..<contCount {
            let time = Double(i) * 0.6
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: time,
                duration: 0.5
            ))
        }
        return try CHHapticPattern(events: events, parameters: [])
    }

    private func gentleHapticPattern(duration: Double) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        let count = max(Int(duration / 0.8), 3)
        for i in 0..<count {
            let time = Double(i) * 0.8
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ],
                relativeTime: time
            ))
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: time + 0.1,
                duration: 0.35
            ))
        }
        return try CHHapticPattern(events: events, parameters: [])
    }

    private func playFallbackVibration(_ vibration: AlarmVibration) {
        switch vibration {
        case .standard:
            let gen = UIImpactFeedbackGenerator(style: .heavy)
            gen.prepare()
            gen.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gen.impactOccurred(intensity: 1.0)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                gen.impactOccurred(intensity: 1.0)
            }
        case .persistent:
            var count = 0
            Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
                let g = UIImpactFeedbackGenerator(style: .heavy)
                g.prepare()
                g.impactOccurred(intensity: 1.0)
                count += 1
                if count >= 20 { timer.invalidate() }
            }
        case .gentle:
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.prepare()
            gen.impactOccurred(intensity: 0.7)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                gen.impactOccurred(intensity: 0.5)
            }
        case .none:
            break
        }
    }
}
