import Foundation

final class DevotionalService {
    static let shared = DevotionalService()

    private let cacheKey = "cachedDailyContent"
    private let cacheDateKey = "cachedDailyContentDate"

    func fetchTodayContent() async -> DailyContent {
        if let cached = loadCachedContent(), isCacheValidForToday(cached.date) {
            return cached
        }

        let verse = VerseLibrary.verseForToday()

        if let aiDevotional = await generateDevotional(for: verse) {
            let content = DailyContent(date: .now, verse: verse, devotional: aiDevotional)
            cacheContent(content)
            return content
        }

        let fallback = ContentLibrary.contentForToday()
        return fallback
    }

    private func generateDevotional(for verse: DailyVerse) async -> Devotional? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        let todayString = dateFormatter.string(from: .now)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let sessionId = UUID().uuidString.prefix(8)

        let themes = [
            "Explore how this verse speaks to the beauty of stillness and God's presence in quiet moments.",
            "Connect this passage to the journey of trusting God through uncertainty.",
            "Reflect on what this verse reveals about God's tenderness toward His children.",
            "Explore how this Scripture challenges our desire for control and invites surrender.",
            "Focus on a vivid image from nature that mirrors the truth in this verse.",
            "Consider how this verse redefines strength through God's perspective.",
            "Reflect on how this passage speaks to someone carrying hidden burdens today.",
            "Explore the contrast between worldly wisdom and the wisdom found in this verse.",
            "Connect this Scripture to the rhythm of gratitude and how it reshapes our mornings.",
            "Reflect on how this verse invites us into deeper community and love for others.",
            "Explore what this passage says about God's timing and patience.",
            "Focus on a single powerful word in this verse and unpack its layers of meaning.",
        ]
        let themeIndex = (dayOfYear + verse.reference.count) % themes.count
        let todayTheme = themes[themeIndex]

        let prompt = """
        You are a gifted, biblically sound Christian devotional writer. Write a completely original morning devotional reflection (about 200 words) for \(todayString), based on this Bible verse:

        "\(verse.text)" — \(verse.reference)
        Day of Year: \(dayOfYear)
        Session: \(sessionId)
        Creative Direction: \(todayTheme)

        Requirements:
        - This devotional MUST be completely original and unique — never repeat themes, metaphors, or opening lines
        - Follow the creative direction above to ensure a fresh angle
        - Write in second person ("you")
        - Be warm, reflective, and encouraging
        - Reference specific words or phrases FROM the actual verse text
        - Connect the verse to everyday life with a concrete, specific example
        - End with a practical, actionable challenge for the day (not vague)
        - Do not use hashtags, emojis, or bullet points
        - Write in flowing paragraphs
        - Use "God" with an uppercase G always
        - Tone: peaceful, intimate, like a wise friend speaking gently over morning coffee
        - Explicitly reference \(verse.reference) in the body
        - Create a creative, evocative title that captures THIS devotional's unique angle
        - Do NOT use generic titles like "Morning Reflection" or "A Word for Today"

        Respond with ONLY a JSON object in this exact format (no markdown, no code fences):
        {"title": "Short Devotional Title", "body": "The full devotional text here", "readingTimeMinutes": 3}
        """

        let toolkitURL = Config.EXPO_PUBLIC_TOOLKIT_URL.isEmpty ? "https://toolkit.rork.com" : Config.EXPO_PUBLIC_TOOLKIT_URL
        guard let url = URL(string: "\(toolkitURL)/agent/chat") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let now = formatter.string(from: .now)
        let msgId = UUID().uuidString
        let payload: [String: Any] = [
            "messages": [
                ["id": msgId, "role": "user", "content": prompt, "parts": [["type": "text", "text": prompt]], "createdAt": now]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }

            let text = String(data: data, encoding: .utf8) ?? ""
            let extracted = extractSSEText(from: text)
            return parseDevotional(from: extracted.isEmpty ? text : extracted)
        } catch {
            return nil
        }
    }

    private func parseDevotional(from text: String) -> Devotional? {
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
              let body = json["body"] as? String else { return nil }

        let readingTime = json["readingTimeMinutes"] as? Int ?? 3
        return Devotional(title: title, body: body, readingTimeMinutes: readingTime)
    }

    private func extractSSEText(from text: String) -> String {
        var result = ""
        let lines = text.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.hasPrefix("data: ") else { continue }
            let jsonString = String(trimmed.dropFirst(6))
            guard jsonString != "[DONE]" else { continue }
            guard let jsonData = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                  let type = json["type"] as? String else { continue }
            if type == "text-delta", let delta = json["delta"] as? String {
                result += delta
            }
        }
        return result
    }

    private func loadCachedContent() -> DailyContent? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try? JSONDecoder().decode(DailyContent.self, from: data)
    }

    private func isCacheValidForToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func cacheContent(_ content: DailyContent) {
        if let data = try? JSONEncoder().encode(content) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
}
