import Foundation

nonisolated enum Testament: String, CaseIterable, Identifiable, Sendable {
    case old = "Old Testament"
    case new = "New Testament"

    var id: String { rawValue }
}

nonisolated struct BibleTranslation: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let abbreviation: String
}

nonisolated struct BibleBook: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let abbreviation: String
    let chapters: Int
    let testament: Testament
    let apiId: String

    static let allBooks: [BibleBook] = [
        BibleBook(id: "genesis", name: "Genesis", abbreviation: "Gen", chapters: 50, testament: .old, apiId: "GEN"),
        BibleBook(id: "exodus", name: "Exodus", abbreviation: "Exo", chapters: 40, testament: .old, apiId: "EXO"),
        BibleBook(id: "leviticus", name: "Leviticus", abbreviation: "Lev", chapters: 27, testament: .old, apiId: "LEV"),
        BibleBook(id: "numbers", name: "Numbers", abbreviation: "Num", chapters: 36, testament: .old, apiId: "NUM"),
        BibleBook(id: "deuteronomy", name: "Deuteronomy", abbreviation: "Deu", chapters: 34, testament: .old, apiId: "DEU"),
        BibleBook(id: "joshua", name: "Joshua", abbreviation: "Jos", chapters: 24, testament: .old, apiId: "JOS"),
        BibleBook(id: "judges", name: "Judges", abbreviation: "Jdg", chapters: 21, testament: .old, apiId: "JDG"),
        BibleBook(id: "ruth", name: "Ruth", abbreviation: "Rut", chapters: 4, testament: .old, apiId: "RUT"),
        BibleBook(id: "1samuel", name: "1 Samuel", abbreviation: "1Sa", chapters: 31, testament: .old, apiId: "1SA"),
        BibleBook(id: "2samuel", name: "2 Samuel", abbreviation: "2Sa", chapters: 24, testament: .old, apiId: "2SA"),
        BibleBook(id: "1kings", name: "1 Kings", abbreviation: "1Ki", chapters: 22, testament: .old, apiId: "1KI"),
        BibleBook(id: "2kings", name: "2 Kings", abbreviation: "2Ki", chapters: 25, testament: .old, apiId: "2KI"),
        BibleBook(id: "1chronicles", name: "1 Chronicles", abbreviation: "1Ch", chapters: 29, testament: .old, apiId: "1CH"),
        BibleBook(id: "2chronicles", name: "2 Chronicles", abbreviation: "2Ch", chapters: 36, testament: .old, apiId: "2CH"),
        BibleBook(id: "ezra", name: "Ezra", abbreviation: "Ezr", chapters: 10, testament: .old, apiId: "EZR"),
        BibleBook(id: "nehemiah", name: "Nehemiah", abbreviation: "Neh", chapters: 13, testament: .old, apiId: "NEH"),
        BibleBook(id: "esther", name: "Esther", abbreviation: "Est", chapters: 10, testament: .old, apiId: "EST"),
        BibleBook(id: "job", name: "Job", abbreviation: "Job", chapters: 42, testament: .old, apiId: "JOB"),
        BibleBook(id: "psalms", name: "Psalms", abbreviation: "Psa", chapters: 150, testament: .old, apiId: "PSA"),
        BibleBook(id: "proverbs", name: "Proverbs", abbreviation: "Pro", chapters: 31, testament: .old, apiId: "PRO"),
        BibleBook(id: "ecclesiastes", name: "Ecclesiastes", abbreviation: "Ecc", chapters: 12, testament: .old, apiId: "ECC"),
        BibleBook(id: "songofsolomon", name: "Song of Solomon", abbreviation: "Sng", chapters: 8, testament: .old, apiId: "SNG"),
        BibleBook(id: "isaiah", name: "Isaiah", abbreviation: "Isa", chapters: 66, testament: .old, apiId: "ISA"),
        BibleBook(id: "jeremiah", name: "Jeremiah", abbreviation: "Jer", chapters: 52, testament: .old, apiId: "JER"),
        BibleBook(id: "lamentations", name: "Lamentations", abbreviation: "Lam", chapters: 5, testament: .old, apiId: "LAM"),
        BibleBook(id: "ezekiel", name: "Ezekiel", abbreviation: "Eze", chapters: 48, testament: .old, apiId: "EZK"),
        BibleBook(id: "daniel", name: "Daniel", abbreviation: "Dan", chapters: 12, testament: .old, apiId: "DAN"),
        BibleBook(id: "hosea", name: "Hosea", abbreviation: "Hos", chapters: 14, testament: .old, apiId: "HOS"),
        BibleBook(id: "joel", name: "Joel", abbreviation: "Joe", chapters: 3, testament: .old, apiId: "JOL"),
        BibleBook(id: "amos", name: "Amos", abbreviation: "Amo", chapters: 9, testament: .old, apiId: "AMO"),
        BibleBook(id: "obadiah", name: "Obadiah", abbreviation: "Oba", chapters: 1, testament: .old, apiId: "OBA"),
        BibleBook(id: "jonah", name: "Jonah", abbreviation: "Jon", chapters: 4, testament: .old, apiId: "JON"),
        BibleBook(id: "micah", name: "Micah", abbreviation: "Mic", chapters: 7, testament: .old, apiId: "MIC"),
        BibleBook(id: "nahum", name: "Nahum", abbreviation: "Nah", chapters: 3, testament: .old, apiId: "NAM"),
        BibleBook(id: "habakkuk", name: "Habakkuk", abbreviation: "Hab", chapters: 3, testament: .old, apiId: "HAB"),
        BibleBook(id: "zephaniah", name: "Zephaniah", abbreviation: "Zep", chapters: 3, testament: .old, apiId: "ZEP"),
        BibleBook(id: "haggai", name: "Haggai", abbreviation: "Hag", chapters: 2, testament: .old, apiId: "HAG"),
        BibleBook(id: "zechariah", name: "Zechariah", abbreviation: "Zec", chapters: 14, testament: .old, apiId: "ZEC"),
        BibleBook(id: "malachi", name: "Malachi", abbreviation: "Mal", chapters: 4, testament: .old, apiId: "MAL"),
        BibleBook(id: "matthew", name: "Matthew", abbreviation: "Mat", chapters: 28, testament: .new, apiId: "MAT"),
        BibleBook(id: "mark", name: "Mark", abbreviation: "Mrk", chapters: 16, testament: .new, apiId: "MRK"),
        BibleBook(id: "luke", name: "Luke", abbreviation: "Luk", chapters: 24, testament: .new, apiId: "LUK"),
        BibleBook(id: "john", name: "John", abbreviation: "Jhn", chapters: 21, testament: .new, apiId: "JHN"),
        BibleBook(id: "acts", name: "Acts", abbreviation: "Act", chapters: 28, testament: .new, apiId: "ACT"),
        BibleBook(id: "romans", name: "Romans", abbreviation: "Rom", chapters: 16, testament: .new, apiId: "ROM"),
        BibleBook(id: "1corinthians", name: "1 Corinthians", abbreviation: "1Co", chapters: 16, testament: .new, apiId: "1CO"),
        BibleBook(id: "2corinthians", name: "2 Corinthians", abbreviation: "2Co", chapters: 13, testament: .new, apiId: "2CO"),
        BibleBook(id: "galatians", name: "Galatians", abbreviation: "Gal", chapters: 6, testament: .new, apiId: "GAL"),
        BibleBook(id: "ephesians", name: "Ephesians", abbreviation: "Eph", chapters: 6, testament: .new, apiId: "EPH"),
        BibleBook(id: "philippians", name: "Philippians", abbreviation: "Php", chapters: 4, testament: .new, apiId: "PHP"),
        BibleBook(id: "colossians", name: "Colossians", abbreviation: "Col", chapters: 4, testament: .new, apiId: "COL"),
        BibleBook(id: "1thessalonians", name: "1 Thessalonians", abbreviation: "1Th", chapters: 5, testament: .new, apiId: "1TH"),
        BibleBook(id: "2thessalonians", name: "2 Thessalonians", abbreviation: "2Th", chapters: 3, testament: .new, apiId: "2TH"),
        BibleBook(id: "1timothy", name: "1 Timothy", abbreviation: "1Ti", chapters: 6, testament: .new, apiId: "1TI"),
        BibleBook(id: "2timothy", name: "2 Timothy", abbreviation: "2Ti", chapters: 4, testament: .new, apiId: "2TI"),
        BibleBook(id: "titus", name: "Titus", abbreviation: "Tit", chapters: 3, testament: .new, apiId: "TIT"),
        BibleBook(id: "philemon", name: "Philemon", abbreviation: "Phm", chapters: 1, testament: .new, apiId: "PHM"),
        BibleBook(id: "hebrews", name: "Hebrews", abbreviation: "Heb", chapters: 13, testament: .new, apiId: "HEB"),
        BibleBook(id: "james", name: "James", abbreviation: "Jas", chapters: 5, testament: .new, apiId: "JAS"),
        BibleBook(id: "1peter", name: "1 Peter", abbreviation: "1Pe", chapters: 5, testament: .new, apiId: "1PE"),
        BibleBook(id: "2peter", name: "2 Peter", abbreviation: "2Pe", chapters: 3, testament: .new, apiId: "2PE"),
        BibleBook(id: "1john", name: "1 John", abbreviation: "1Jn", chapters: 5, testament: .new, apiId: "1JN"),
        BibleBook(id: "2john", name: "2 John", abbreviation: "2Jn", chapters: 1, testament: .new, apiId: "2JN"),
        BibleBook(id: "3john", name: "3 John", abbreviation: "3Jn", chapters: 1, testament: .new, apiId: "3JN"),
        BibleBook(id: "jude", name: "Jude", abbreviation: "Jud", chapters: 1, testament: .new, apiId: "JUD"),
        BibleBook(id: "revelation", name: "Revelation", abbreviation: "Rev", chapters: 22, testament: .new, apiId: "REV"),
    ]

    static var oldTestament: [BibleBook] {
        allBooks.filter { $0.testament == .old }
    }

    static var newTestament: [BibleBook] {
        allBooks.filter { $0.testament == .new }
    }
}

nonisolated struct BibleVerse: Identifiable, Sendable {
    var id: String { "\(bookName) \(chapter):\(verse)" }
    let bookName: String
    let chapter: Int
    let verse: Int
    let text: String
}

nonisolated struct ApiBibleBiblesResponse: Codable, Sendable {
    let data: [ApiBibleEntry]
}

nonisolated struct ApiBibleEntry: Codable, Sendable {
    let id: String
    let name: String
    let abbreviation: String?
    let abbreviationLocal: String?
    let language: ApiBibleLanguage?
}

nonisolated struct ApiBibleLanguage: Codable, Sendable {
    let id: String?
    let name: String?
}

nonisolated struct ApiBibleChapterResponse: Codable, Sendable {
    let data: ApiBibleChapterData
}

nonisolated struct ApiBibleChapterData: Codable, Sendable {
    let id: String
    let content: String
    let reference: String?
    let verseCount: Int?
}
