import Foundation

nonisolated enum JourneyStyle: String, CaseIterable, Codable, Sendable {
    case simple = "Simple"
    case guided = "Guided"

    var description: String {
        switch self {
        case .simple: return "Verse + Devotional + Timer"
        case .guided: return "Adds structured prayers"
        }
    }

    var icon: String {
        switch self {
        case .simple: return "sparkle"
        case .guided: return "book.and.wreath"
        }
    }
}

nonisolated enum PrayerMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case pickPrayer = "Pick a Prayer"
    case aiPrayer = "Tailor-Made Prayer"
    case ownPrayer = "Pray on My Own"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pickPrayer: return "book"
        case .aiPrayer: return "sparkles"
        case .ownPrayer: return "person.and.background.dotted"
        }
    }

    var subtitle: String {
        switch self {
        case .pickPrayer: return "Choose from our prayer library"
        case .aiPrayer: return "A prayer crafted just for you"
        case .ownPrayer: return "Free prayer with guided prompts"
        }
    }
}

nonisolated enum SessionState: Codable, Sendable {
    case locked
    case inProgress
    case completed
}
