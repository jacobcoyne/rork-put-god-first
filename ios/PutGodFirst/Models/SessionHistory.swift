import Foundation

nonisolated struct SessionRecord: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let prayerMinutes: Int
    let streakAtTime: Int

    init(id: UUID = UUID(), date: Date = .now, prayerMinutes: Int, streakAtTime: Int) {
        self.id = id
        self.date = date
        self.prayerMinutes = prayerMinutes
        self.streakAtTime = streakAtTime
    }

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

nonisolated struct SessionHistory: Codable, Sendable {
    var records: [SessionRecord] = []

    var totalMinutes: Int {
        records.reduce(0) { $0 + $1.prayerMinutes }
    }

    var totalSessions: Int {
        records.count
    }

    var longestStreak: Int {
        records.map(\.streakAtTime).max() ?? 0
    }

    var averageMinutes: Double {
        guard !records.isEmpty else { return 0 }
        return Double(totalMinutes) / Double(records.count)
    }

    func records(for month: Date) -> [SessionRecord] {
        let cal = Calendar.current
        return records.filter { cal.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    func hasSession(on date: Date) -> Bool {
        let cal = Calendar.current
        return records.contains { cal.isDate($0.date, inSameDayAs: date) }
    }

    func record(on date: Date) -> SessionRecord? {
        let cal = Calendar.current
        return records.first { cal.isDate($0.date, inSameDayAs: date) }
    }

    var thisWeekSessions: Int {
        let cal = Calendar.current
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return records.filter { $0.date >= startOfWeek }.count
    }

    var thisMonthSessions: Int {
        let cal = Calendar.current
        return records.filter { cal.isDate($0.date, equalTo: .now, toGranularity: .month) }.count
    }

    var thisMonthMinutes: Int {
        let cal = Calendar.current
        return records.filter { cal.isDate($0.date, equalTo: .now, toGranularity: .month) }.reduce(0) { $0 + $1.prayerMinutes }
    }

    mutating func addRecord(_ record: SessionRecord) {
        records.append(record)
    }
}
