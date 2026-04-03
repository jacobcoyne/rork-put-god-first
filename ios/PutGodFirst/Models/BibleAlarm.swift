import Foundation

nonisolated enum AlarmDismissMethod: String, Codable, Sendable, CaseIterable, Identifiable {
    case scanBible = "Scan Bible"
    case reciteVerse = "Recite Verse"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .scanBible: return "camera.viewfinder"
        case .reciteVerse: return "mic.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .scanBible: return "Take a photo of your OPEN Bible"
        case .reciteVerse: return "Read a Bible verse out loud"
        }
    }

    var gradientColors: (Color1: (r: Double, g: Double, b: Double), Color2: (r: Double, g: Double, b: Double)) {
        switch self {
        case .scanBible: return ((0.35, 0.62, 1.0), (0.52, 0.35, 0.95))
        case .reciteVerse: return ((1.0, 0.68, 0.28), (1.0, 0.42, 0.38))
        }
    }
}

nonisolated enum AlarmSoundCategory: String, Sendable, CaseIterable {
    case popular = "POPULAR"
    case gentle = "GENTLE"
    case bold = "BOLD"
    case extreme = "EXTREME"

    var emoji: String {
        switch self {
        case .popular: return "star.fill"
        case .gentle: return "leaf.fill"
        case .bold: return "bolt.fill"
        case .extreme: return "exclamationmark.triangle.fill"
        }
    }
}

nonisolated enum AlarmSound: String, Codable, Sendable, CaseIterable, Identifiable {
    case radar = "Radar"
    case apex = "Apex"
    case beacon = "Beacon"
    case chimes = "Chimes"
    case constellation = "Constellation"
    case uplift = "Uplift"
    case pulse = "Pulse"
    case daybreak = "Daybreak"
    case serenity = "Serenity"
    case triumph = "Triumph"
    case siren = "Siren"
    case blaring = "Blaring"

    var id: String { rawValue }

    var category: AlarmSoundCategory {
        switch self {
        case .radar, .apex, .uplift, .pulse: return .popular
        case .chimes, .constellation, .daybreak, .serenity: return .gentle
        case .beacon, .triumph: return .bold
        case .siren, .blaring: return .extreme
        }
    }

    var icon: String {
        switch self {
        case .radar: return "dot.radiowaves.left.and.right"
        case .apex: return "music.note"
        case .beacon: return "antenna.radiowaves.left.and.right"
        case .chimes: return "wind"
        case .constellation: return "sparkles"
        case .uplift: return "arrow.up.right"
        case .pulse: return "waveform"
        case .daybreak: return "sunrise.fill"
        case .serenity: return "water.waves"
        case .triumph: return "megaphone.fill"
        case .siren: return "light.beacon.max.fill"
        case .blaring: return "speaker.wave.3.fill"
        }
    }

    var accentColor: (r: Double, g: Double, b: Double) {
        switch self {
        case .radar: return (0.95, 0.42, 0.28)
        case .apex: return (0.95, 0.72, 0.28)
        case .beacon: return (0.22, 0.72, 0.88)
        case .chimes: return (0.45, 0.78, 0.58)
        case .constellation: return (0.62, 0.45, 0.88)
        case .uplift: return (0.95, 0.58, 0.18)
        case .pulse: return (0.35, 0.62, 1.0)
        case .daybreak: return (1.0, 0.68, 0.28)
        case .serenity: return (0.32, 0.62, 0.85)
        case .triumph: return (0.92, 0.35, 0.25)
        case .siren: return (1.0, 0.15, 0.15)
        case .blaring: return (0.85, 0.0, 0.35)
        }
    }
}

nonisolated enum AlarmVibration: String, Codable, Sendable, CaseIterable, Identifiable {
    case standard = "Standard"
    case persistent = "Persistent"
    case gentle = "Gentle"
    case none = "None"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .standard: return "iphone.radiowaves.left.and.right"
        case .persistent: return "waveform.path"
        case .gentle: return "water.waves"
        case .none: return "iphone.slash"
        }
    }

    var subtitle: String {
        switch self {
        case .standard: return "Strong rhythmic pulses"
        case .persistent: return "Rapid continuous buzzing"
        case .gentle: return "Soft subtle taps"
        case .none: return "No vibration"
        }
    }
}

nonisolated struct BibleAlarm: Codable, Sendable {
    var isEnabled: Bool = false
    var hour: Int = 6
    var minute: Int = 0
    var repeatDays: Set<Int> = [1, 2, 3, 4, 5, 6, 7]
    var label: String = "Open Your Bible"
    var sound: AlarmSound = .radar
    var vibration: AlarmVibration = .standard
    var volume: Double = 1.0
    var dismissMethod: AlarmDismissMethod = .scanBible

    var alarmTime: Date {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? .now
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        if let date = Calendar.current.date(from: comps) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }

    var repeatDescription: String {
        if repeatDays.count == 7 { return "Every day" }
        if repeatDays == Set([2, 3, 4, 5, 6]) { return "Weekdays" }
        if repeatDays == Set([1, 7]) { return "Weekends" }
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sorted = repeatDays.sorted()
        return sorted.map { dayNames[$0] }.joined(separator: ", ")
    }
}
