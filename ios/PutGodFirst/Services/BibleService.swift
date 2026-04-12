import Foundation

final class BibleService {
    static let shared = BibleService()

    private let baseURL = "https://api.scripture.api.bible/v1"
    private var apiKey: String {
        let key = Config.EXPO_PUBLIC_API_BIBLE_KEY
        if !key.isEmpty { return key }
        return Bundle.main.object(forInfoDictionaryKey: "APIBibleKey") as? String ?? ""
    }

    private var chapterCache: [String: [BibleVerse]] = [:]
    private var biblesCache: [BibleTranslation]?

    private let popularTranslationIds: Set<String> = [
        "de4e12af7f28f599-02",
        "06125adad2d5898a-01",
        "9879dbb7cfe39e4d-04",
        "01b29f4b342acc35-01",
        "7142879509583d59-04",
        "55212e3cf4d04c49-01",
        "65eec8e0b60e656b-01",
        "b32b9d1b64b4ef29-01",
        "f72b840c855f362c-04",
        "2dd568eeff29fb3c-01",
        "685d1470fe4d5c3b-01",
    ]

    private static let fallbackTranslations: [BibleTranslation] = [
        BibleTranslation(id: "de4e12af7f28f599-02", name: "King James (Authorised) Version", abbreviation: "KJV"),
        BibleTranslation(id: "06125adad2d5898a-01", name: "American Standard Version", abbreviation: "ASV"),
        BibleTranslation(id: "9879dbb7cfe39e4d-04", name: "World English Bible", abbreviation: "WEB"),
        BibleTranslation(id: "01b29f4b342acc35-01", name: "Bible in Basic English", abbreviation: "BBE"),
        BibleTranslation(id: "7142879509583d59-04", name: "Darby Translation", abbreviation: "DARBY"),
        BibleTranslation(id: "55212e3cf4d04c49-01", name: "Douay-Rheims American Edition", abbreviation: "DRA"),
        BibleTranslation(id: "65eec8e0b60e656b-01", name: "Free Bible Version", abbreviation: "FBV"),
    ]

    func fetchBibles() async -> [BibleTranslation] {
        if let cached = biblesCache, !cached.isEmpty { return cached }

        guard !apiKey.isEmpty,
              let url = URL(string: "\(baseURL)/bibles") else {
            biblesCache = Self.fallbackTranslations
            return Self.fallbackTranslations
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                biblesCache = Self.fallbackTranslations
                return Self.fallbackTranslations
            }

            let decoded = try JSONDecoder().decode(ApiBibleBiblesResponse.self, from: data)
            let bibles = decoded.data
                .filter { entry in
                    let langId = entry.language?.id?.lowercased() ?? ""
                    let langName = entry.language?.name?.lowercased() ?? ""
                    return langId == "eng" || langName.contains("english")
                }
                .sorted { a, b in
                    let aPopular = popularTranslationIds.contains(a.id)
                    let bPopular = popularTranslationIds.contains(b.id)
                    if aPopular != bPopular { return aPopular }
                    return (a.abbreviationLocal ?? a.abbreviation ?? a.name) < (b.abbreviationLocal ?? b.abbreviation ?? b.name)
                }
                .map { entry in
                    BibleTranslation(
                        id: entry.id,
                        name: entry.name,
                        abbreviation: entry.abbreviationLocal ?? entry.abbreviation ?? ""
                    )
                }

            let result = bibles.isEmpty ? Self.fallbackTranslations : bibles
            biblesCache = result
            return result
        } catch {
            biblesCache = Self.fallbackTranslations
            return Self.fallbackTranslations
        }
    }

    func fetchChapter(bibleId: String, book: BibleBook, chapter: Int) async -> [BibleVerse]? {
        let cacheKey = "\(bibleId)_\(book.apiId)_\(chapter)"
        if let cached = chapterCache[cacheKey] { return cached }

        if !apiKey.isEmpty {
            let chapterId = "\(book.apiId).\(chapter)"

            if let jsonVerses = await fetchChapterJSON(bibleId: bibleId, chapterId: chapterId, bookName: book.name, chapter: chapter) {
                chapterCache[cacheKey] = jsonVerses
                return jsonVerses
            }

            if let textVerses = await fetchChapterText(bibleId: bibleId, chapterId: chapterId, bookName: book.name, chapter: chapter) {
                chapterCache[cacheKey] = textVerses
                return textVerses
            }

            if let htmlVerses = await fetchChapterHTML(bibleId: bibleId, chapterId: chapterId, bookName: book.name, chapter: chapter) {
                chapterCache[cacheKey] = htmlVerses
                return htmlVerses
            }
        }

        let fallbackKey = "fallback_\(book.name)_\(chapter)"
        if let cached = chapterCache[fallbackKey] { return cached }

        if let fallbackVerses = await fetchChapterFallback(book: book, chapter: chapter) {
            chapterCache[fallbackKey] = fallbackVerses
            return fallbackVerses
        }

        return nil
    }

    private func fetchChapterJSON(bibleId: String, chapterId: String, bookName: String, chapter: Int) async -> [BibleVerse]? {
        let urlString = "\(baseURL)/bibles/\(bibleId)/chapters/\(chapterId)?content-type=json&include-verse-numbers=true&include-titles=false&include-chapter-numbers=false"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.timeoutInterval = 20

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataObj = json["data"] as? [String: Any] else { return nil }

            if let contentArray = dataObj["content"] as? [[String: Any]] {
                let verses = extractVersesFromJSONArray(contentArray, bookName: bookName, chapter: chapter)
                return verses.isEmpty ? nil : verses
            }

            if let contentString = dataObj["content"] as? String {
                let verses = parseJSONContent(contentString, bookName: bookName, chapter: chapter)
                return verses.isEmpty ? nil : verses
            }

            return nil
        } catch {
            return nil
        }
    }

    private func fetchChapterText(bibleId: String, chapterId: String, bookName: String, chapter: Int) async -> [BibleVerse]? {
        let urlString = "\(baseURL)/bibles/\(bibleId)/chapters/\(chapterId)?content-type=text&include-verse-numbers=true&include-titles=false&include-chapter-numbers=false"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.timeoutInterval = 20

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }

            let decoded = try JSONDecoder().decode(ApiBibleChapterResponse.self, from: data)
            let verses = parseTextContent(decoded.data.content, bookName: bookName, chapter: chapter)
            return verses.isEmpty ? nil : verses
        } catch {
            return nil
        }
    }

    private func fetchChapterHTML(bibleId: String, chapterId: String, bookName: String, chapter: Int) async -> [BibleVerse]? {
        let urlString = "\(baseURL)/bibles/\(bibleId)/chapters/\(chapterId)?content-type=html&include-verse-numbers=true&include-titles=false&include-chapter-numbers=false"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.timeoutInterval = 20

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }

            let decoded = try JSONDecoder().decode(ApiBibleChapterResponse.self, from: data)
            let html = decoded.data.content

            let withBrackets = html.replacingOccurrences(
                of: "<span[^>]*?data-number=\"(\\d+)\"[^>]*>[^<]*</span>",
                with: "[$1] ",
                options: .regularExpression
            )
            let stripped = withBrackets
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .replacingOccurrences(of: "&nbsp;", with: " ")
                .replacingOccurrences(of: "&#\\d+;", with: "", options: .regularExpression)

            let verses = parseTextContent(stripped, bookName: bookName, chapter: chapter)
            return verses.isEmpty ? nil : verses
        } catch {
            return nil
        }
    }

    private func parseJSONContent(_ content: String, bookName: String, chapter: Int) -> [BibleVerse] {
        guard let data = content.data(using: .utf8) else { return [] }

        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return extractVersesFromJSONArray(jsonArray, bookName: bookName, chapter: chapter)
            }
        } catch {}

        return parseTextContent(content, bookName: bookName, chapter: chapter)
    }

    private func extractVersesFromJSONArray(_ array: [[String: Any]], bookName: String, chapter: Int) -> [BibleVerse] {
        var versesDict: [Int: String] = [:]

        for item in array {
            if let items = item["items"] as? [[String: Any]] {
                for subItem in items {
                    extractVerseText(from: subItem, into: &versesDict)
                }
            }
            extractVerseText(from: item, into: &versesDict)
        }

        return versesDict.keys.sorted().compactMap { num in
            guard let text = versesDict[num], !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return BibleVerse(bookName: bookName, chapter: chapter, verse: num, text: text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    private func extractVerseText(from item: [String: Any], into versesDict: inout [Int: String]) {
        if let attrs = item["attrs"] as? [String: Any],
           let verseId = attrs["verseId"] as? String {
            let parts = verseId.split(separator: ".")
            if let lastPart = parts.last, let num = Int(lastPart) {
                if let text = item["text"] as? String {
                    versesDict[num, default: ""] += text
                }
                if let items = item["items"] as? [[String: Any]] {
                    for sub in items {
                        if let text = sub["text"] as? String {
                            versesDict[num, default: ""] += text
                        }
                    }
                }
            }
        }

        if let text = item["text"] as? String,
           let name = item["name"] as? String,
           name == "verse",
           let attrs = item["attrs"] as? [String: Any],
           let sid = (attrs["sID"] ?? attrs["number"]) as? String {
            let parts = sid.split(separator: ".")
            if let lastPart = parts.last, let num = Int(lastPart) {
                versesDict[num, default: ""] += text
            }
        }

        if let items = item["items"] as? [[String: Any]] {
            for sub in items {
                extractVerseText(from: sub, into: &versesDict)
            }
        }
    }

    private func parseTextContent(_ content: String, bookName: String, chapter: Int) -> [BibleVerse] {
        let cleaned = content
            .replacingOccurrences(of: "\u{00B6}", with: "")
            .replacingOccurrences(of: "¶", with: "")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        let bracketPattern = "\\[(\\d+)\\]"
        if let regex = try? NSRegularExpression(pattern: bracketPattern) {
            let ns = cleaned as NSString
            let matches = regex.matches(in: cleaned, range: NSRange(location: 0, length: ns.length))

            if !matches.isEmpty {
                var verses: [BibleVerse] = []
                for i in 0..<matches.count {
                    let match = matches[i]
                    let numRange = match.range(at: 1)
                    guard let verseNum = Int(ns.substring(with: numRange)) else { continue }

                    let textStart = match.range.location + match.range.length
                    let textEnd = i + 1 < matches.count ? matches[i + 1].range.location : ns.length
                    guard textEnd > textStart else { continue }

                    let verseText = ns.substring(with: NSRange(location: textStart, length: textEnd - textStart))
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if !verseText.isEmpty {
                        verses.append(BibleVerse(bookName: bookName, chapter: chapter, verse: verseNum, text: verseText))
                    }
                }
                if !verses.isEmpty { return verses }
            }
        }

        let spacePattern = "(?:^|\\n)\\s*(\\d+)\\s+"
        if let regex = try? NSRegularExpression(pattern: spacePattern) {
            let ns = cleaned as NSString
            let matches = regex.matches(in: cleaned, range: NSRange(location: 0, length: ns.length))

            if !matches.isEmpty {
                var verses: [BibleVerse] = []
                for i in 0..<matches.count {
                    let match = matches[i]
                    let numRange = match.range(at: 1)
                    guard let verseNum = Int(ns.substring(with: numRange)) else { continue }

                    let textStart = match.range.location + match.range.length
                    let textEnd = i + 1 < matches.count ? matches[i + 1].range.location : ns.length
                    guard textEnd > textStart else { continue }

                    let verseText = ns.substring(with: NSRange(location: textStart, length: textEnd - textStart))
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if !verseText.isEmpty {
                        verses.append(BibleVerse(bookName: bookName, chapter: chapter, verse: verseNum, text: verseText))
                    }
                }
                if !verses.isEmpty { return verses }
            }
        }

        if !cleaned.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return [BibleVerse(bookName: bookName, chapter: chapter, verse: 1, text: cleaned.trimmingCharacters(in: .whitespacesAndNewlines))]
        }

        return []
    }

    func generateVerseDevotional(reference: String, verseText: String) async -> (title: String, body: String, prayer: String)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let todayString = dateFormatter.string(from: .now)
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: .now)
        let sessionId = UUID().uuidString.prefix(8)

        let angles = [
            "Focus on a vivid metaphor from nature that parallels the verse's meaning.",
            "Explore how this verse speaks to someone feeling overwhelmed or anxious today.",
            "Connect this passage to a moment of unexpected grace in everyday life.",
            "Reflect on what this verse reveals about God's character and faithfulness.",
            "Consider how a first-century listener would have heard these words, then bring it to today.",
            "Explore the emotional journey within this passage — from struggle to hope.",
            "Relate this verse to the rhythm of morning — waking, rising, stepping into a new day.",
            "Focus on one surprising or overlooked word in the passage and unpack its depth.",
            "Write as if speaking to someone at a crossroads, needing courage to take the next step.",
            "Explore how this verse challenges our culture's definition of success or strength.",
            "Connect this passage to the beauty of silence and listening for God's voice.",
            "Reflect on how this verse speaks to broken relationships and the power of forgiveness.",
        ]
        let randomAngle = angles[Int.random(in: 0..<angles.count)]

        let prompt = """
        You are a gifted, biblically sound Christian devotional writer with a unique voice. Write a completely original devotional reflection (about 150-180 words) and a heartfelt prayer (about 80-100 words) based on this specific Bible passage.

        Date: \(todayString) at \(timeString)
        Passage: "\(verseText)" — \(reference)
        Session: \(sessionId)
        Creative Direction: \(randomAngle)

        Requirements:
        - This MUST be completely original — never repeat themes, metaphors, or phrases from other devotionals
        - Follow the creative direction above to ensure a fresh, unique angle
        - Be doctrinally sound and biblically faithful
        - Write in second person ("you")
        - Be warm, reflective, and encouraging
        - Reference specific words or phrases FROM the actual verse text
        - Include a concrete, practical takeaway the reader can apply today
        - The prayer must directly reference this specific Scripture passage, not generic platitudes
        - The prayer should feel like a real conversation with God, not a formula
        - Do not use hashtags, emojis, or bullet points
        - Use "God" with an uppercase G always
        - Tone: peaceful, intimate, like a wise pastor speaking gently
        - Create a creative, evocative title that captures THIS specific reflection's unique angle
        - Do NOT use generic titles like "Reflection" or "A Word for Today"

        Respond with ONLY a JSON object in this exact format (no markdown, no code fences):
        {"title": "Short Title", "body": "The devotional text", "prayer": "The prayer text"}
        """

        let toolkitURL = Config.EXPO_PUBLIC_TOOLKIT_URL.isEmpty ? "https://toolkit.rork.com" : Config.EXPO_PUBLIC_TOOLKIT_URL
        guard let url = URL(string: "\(toolkitURL)/agent/chat") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let payload: [String: Any] = [
            "messages": [["role": "user", "content": prompt]]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }

            let text = String(data: data, encoding: .utf8) ?? ""
            return parseDevotionalResponse(from: text)
        } catch {
            return nil
        }
    }

    private func fetchChapterFallback(book: BibleBook, chapter: Int) async -> [BibleVerse]? {
        let bookQuery = book.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? book.name
        let urlString = "https://bible-api.com/\(bookQuery)+\(chapter)?translation=kjv"
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }

            let decoded = try JSONDecoder().decode(FallbackBibleResponse.self, from: data)
            let verses = decoded.verses.map { v in
                BibleVerse(
                    bookName: book.name,
                    chapter: chapter,
                    verse: v.verse,
                    text: v.text.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            return verses.isEmpty ? nil : verses
        } catch {
            return nil
        }
    }

    private func parseDevotionalResponse(from text: String) -> (title: String, body: String, prayer: String)? {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonStart = cleaned.firstIndex(of: "{"),
              let jsonEnd = cleaned.lastIndex(of: "}") else { return nil }

        let jsonString = String(cleaned[jsonStart...jsonEnd])

        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let title = json["title"] as? String,
              let body = json["body"] as? String,
              let prayer = json["prayer"] as? String else { return nil }

        return (title, body, prayer)
    }
}

nonisolated struct FallbackBibleResponse: Codable, Sendable {
    let reference: String
    let verses: [FallbackBibleVerse]
    let text: String
    let translation_id: String
    let translation_name: String
}

nonisolated struct FallbackBibleVerse: Codable, Sendable {
    let book_name: String
    let chapter: Int
    let verse: Int
    let text: String
}
