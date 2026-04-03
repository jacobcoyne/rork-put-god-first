import Foundation
import SwiftUI

nonisolated enum BadgeMilestone: Int, CaseIterable, Codable, Sendable, Identifiable {
    var id: Int { rawValue }
    case sevenDays = 7
    case thirtyDays = 30
    case ninetyDays = 90
    case yearStrong = 365

    var title: String {
        switch self {
        case .sevenDays: return "First Week"
        case .thirtyDays: return "One Month"
        case .ninetyDays: return "90 Day Warrior"
        case .yearStrong: return "Year Strong"
        }
    }

    var subtitle: String {
        switch self {
        case .sevenDays: return "You showed up for 7 days straight"
        case .thirtyDays: return "A full month of putting God first"
        case .ninetyDays: return "90 days of spiritual discipline"
        case .yearStrong: return "An entire year walking with God"
        }
    }

    var shareMessage: String {
        switch self {
        case .sevenDays: return "I just earned my 7-Day Cross Shield on Put God First! ✨\n\nDownload the app and start your journey 🙏\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"
        case .thirtyDays: return "30 days of putting God first! Earned my Purple Shield 💜\n\nDownload the app and start your journey 🙏\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"
        case .ninetyDays: return "90 days strong! Earned my Gold Cross Shield 🏆\n\nDownload the app and start your journey 🙏\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"
        case .yearStrong: return "ONE YEAR of putting God first! Diamond Shield unlocked 💎\n\nDownload the app and start your journey 🙏\nhttps://apps.apple.com/us/app/put-god-first/id6759613793"
        }
    }

    var imageURL: String {
        switch self {
        case .sevenDays: return "https://r2-pub.rork.com/generated-images/c618a67c-4f1d-4620-9e70-96fff8d2e5b1.png"
        case .thirtyDays: return "https://r2-pub.rork.com/generated-images/d9ceb1e2-b983-40f0-bb3a-7f03650f5e98.png"
        case .ninetyDays: return "https://r2-pub.rork.com/generated-images/123d2dd0-fe9d-4a21-b7a9-03f8717841f5.png"
        case .yearStrong: return "https://r2-pub.rork.com/generated-images/64fe3d27-eb44-4185-9423-ea3845e284ec.png"
        }
    }

    var daysRequired: Int { rawValue }

    @MainActor var accentColor: Color {
        switch self {
        case .sevenDays: return Color(red: 0.30, green: 0.60, blue: 1.0)
        case .thirtyDays: return Color(red: 0.58, green: 0.28, blue: 0.92)
        case .ninetyDays: return Color(red: 1.0, green: 0.78, blue: 0.20)
        case .yearStrong: return Color(red: 0.72, green: 0.88, blue: 1.0)
        }
    }

    @MainActor var glowColor: Color {
        switch self {
        case .sevenDays: return Color(red: 0.20, green: 0.50, blue: 1.0)
        case .thirtyDays: return Color(red: 0.50, green: 0.18, blue: 0.85)
        case .ninetyDays: return Color(red: 0.95, green: 0.72, blue: 0.0)
        case .yearStrong: return Color(red: 0.60, green: 0.82, blue: 1.0)
        }
    }

    @MainActor var lockedHintGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor.opacity(0.25), accentColor.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var badgeName: String {
        switch self {
        case .sevenDays: return "Blue Shield"
        case .thirtyDays: return "Purple Shield"
        case .ninetyDays: return "Gold Shield"
        case .yearStrong: return "Diamond Shield"
        }
    }
}
