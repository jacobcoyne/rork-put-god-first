import SwiftUI

enum Theme {
    static let iceBlue = Color(red: 0.35, green: 0.62, blue: 1.0)
    static let iceBlueBright = Color(red: 0.52, green: 0.74, blue: 1.0)
    static let icePurple = Color(red: 0.52, green: 0.35, blue: 0.95)
    static let icePurpleBright = Color(red: 0.68, green: 0.55, blue: 1.0)
    static let iceLavender = Color(red: 0.62, green: 0.52, blue: 1.0)

    static let primary = icePurple
    static let primaryBright = icePurpleBright
    static let electricBlue = iceBlue
    static let blueAccent = iceBlue
    static let blueAccentBright = iceBlueBright

    static let hotPink = Color(red: 1.0, green: 0.33, blue: 0.58)
    static let cyan = Color(red: 0.32, green: 0.48, blue: 0.88)
    static let mint = Color(red: 0.4, green: 0.9, blue: 0.75)
    static let skyBlue = Color(red: 0.45, green: 0.72, blue: 1.0)
    static let lavender = iceLavender
    static let limeGreen = Color(red: 0.45, green: 0.95, blue: 0.5)
    static let coral = Color(red: 1.0, green: 0.42, blue: 0.38)

    static let logoBlue = Color(red: 0.18, green: 0.45, blue: 0.95)
    static let logoIndigo = Color(red: 0.28, green: 0.32, blue: 0.92)
    static let logoPurple = Color(red: 0.42, green: 0.22, blue: 0.88)
    static let logoDeepPurple = Color(red: 0.35, green: 0.12, blue: 0.78)
    static let logoViolet = Color(red: 0.52, green: 0.18, blue: 0.95)

    static var textPrimary: Color { Color(.label) }
    static var textSecondary: Color { Color(.secondaryLabel) }
    static var cardBg: Color { Color(.secondarySystemGroupedBackground) }
    static var bg: Color { Color(.systemGroupedBackground) }

    static var deepBlack: Color { Color(.systemBackground) }
    static var darkSurface: Color { Color(.secondarySystemBackground) }
    static var darkCard: Color { Color(.secondarySystemGroupedBackground) }
    static var darkCardBorder: Color { Color(.separator).opacity(0.4) }

    static let morningCream = Color(red: 1.0, green: 0.97, blue: 0.92)
    static let morningPeach = Color(red: 1.0, green: 0.92, blue: 0.85)
    static let morningLavender = Color(red: 0.94, green: 0.92, blue: 0.98)
    static let morningBlush = Color(red: 0.98, green: 0.93, blue: 0.90)

    static let morningGradient = LinearGradient(
        colors: [morningCream, morningPeach.opacity(0.5), morningLavender.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let glowTeal = iceBlue
    static let glowGold = iceLavender
    static let glowPurple = icePurple

    static let softWhite = Color.white.opacity(0.92)
    static let dimWhite = Color.white.opacity(0.55)

    static let dawnGold = Color(red: 1.0, green: 0.82, blue: 0.42)
    static let dawnAmber = Color(red: 1.0, green: 0.68, blue: 0.28)
    static let dawnRose = Color(red: 0.92, green: 0.48, blue: 0.45)
    static let dawnPeach = Color(red: 1.0, green: 0.62, blue: 0.38)
    static let dawnCream = Color(red: 1.0, green: 0.92, blue: 0.78)

    static let amber = Color(red: 0.96, green: 0.72, blue: 0.0)
    static let amberLight = Color(red: 0.98, green: 0.82, blue: 0.2)
    static let warmYellow = Color(red: 0.95, green: 0.78, blue: 0.05)
    static let softTeal = Color(red: 0.38, green: 0.52, blue: 0.85)
    static let dustyRose = Color(red: 0.85, green: 0.52, blue: 0.55)
    static let warmBrown = Color(red: 0.45, green: 0.3, blue: 0.18)

    static let readableGold = Color(red: 0.72, green: 0.52, blue: 0.08)
    static let readableAmber = Color(red: 0.68, green: 0.45, blue: 0.0)

    static let primaryGradient = LinearGradient(
        colors: [iceBlue, icePurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let blueGradient = LinearGradient(
        colors: [iceBlue, iceBlueBright],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [dawnGold, dawnAmber],
        startPoint: .top,
        endPoint: .bottom
    )

    static let warmActionGradient = LinearGradient(
        colors: [Color(red: 0.96, green: 0.72, blue: 0.0), Color(red: 0.98, green: 0.82, blue: 0.2)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let streakGradient = LinearGradient(
        colors: [logoBlue, logoIndigo, logoPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let logoGradient = LinearGradient(
        colors: [logoBlue, logoIndigo, logoPurple, logoDeepPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let monasticGradient = LinearGradient(
        colors: [
            Color(red: 0.12, green: 0.08, blue: 0.28),
            Color(red: 0.18, green: 0.12, blue: 0.42),
            Color(red: 0.28, green: 0.18, blue: 0.58)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let amberGradient = LinearGradient(
        colors: [Color(red: 0.96, green: 0.72, blue: 0.0), Color(red: 0.98, green: 0.82, blue: 0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let iceActionGradient = LinearGradient(
        colors: [iceBlue, icePurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let verseGold = Color(red: 0.88, green: 0.72, blue: 0.32)
    static let verseGoldLight = Color(red: 0.95, green: 0.82, blue: 0.45)
    static let verseGoldDark = Color(red: 0.72, green: 0.55, blue: 0.18)

    static let prayerTeal = Color(red: 0.28, green: 0.42, blue: 0.82)
    static let prayerTealLight = Color(red: 0.42, green: 0.55, blue: 0.90)
    static let prayerTealDark = Color(red: 0.20, green: 0.32, blue: 0.68)

    static let devotionalRose = Color(red: 0.78, green: 0.38, blue: 0.52)
    static let devotionalRoseLight = Color(red: 0.88, green: 0.52, blue: 0.62)
    static let devotionalRoseDark = Color(red: 0.62, green: 0.25, blue: 0.38)

    static let successEmerald = Color(red: 0.22, green: 0.78, blue: 0.55)
    static let successEmeraldLight = Color(red: 0.35, green: 0.88, blue: 0.65)

    static let verseGradient = LinearGradient(
        colors: [verseGold, verseGoldLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let prayerGradient = LinearGradient(
        colors: [prayerTeal, prayerTealLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let devotionalGradient = LinearGradient(
        colors: [devotionalRose, devotionalRoseLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let emeraldGradient = LinearGradient(
        colors: [successEmerald, successEmeraldLight],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Color {
    func interpolated(to other: Color, amount: Double) -> Color {
        let c1 = UIColor(self)
        let c2 = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = CGFloat(min(max(amount, 0), 1))
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t)
        )
    }
}
