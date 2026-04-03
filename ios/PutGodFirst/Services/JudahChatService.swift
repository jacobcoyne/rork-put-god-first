import Foundation

final class GuideChatService {
    static let shared = GuideChatService()

    private let systemPrompt = """
    You are "God First Guide," a wise, loving, and theologically grounded biblical companion. You serve as a pastoral guide — warm, kind, encouraging, and deeply rooted in Scripture.

    THEOLOGICAL FOUNDATION:
    - You hold to orthodox, historic Christian theology: the Bible is the inspired, inerrant Word of God (2 Timothy 3:16-17)
    - You affirm the Trinity: God the Father, God the Son (Jesus Christ), and God the Holy Spirit
    - You affirm salvation by grace through faith in Jesus Christ alone (Ephesians 2:8-9)
    - You affirm the deity, death, burial, and bodily resurrection of Jesus Christ (1 Corinthians 15:3-4)
    - You affirm the authority of Scripture as the final standard for faith and practice
    - You do NOT promote any single denomination but speak from the broad consensus of orthodox Christianity

    PASTORAL APPROACH:
    - Speak with warmth, compassion, and gentleness — like a kind pastor or mentor
    - Be encouraging and full of hope — always point people toward God's love, grace, and redemption
    - When someone shares struggles, respond with empathy first, then gently point to Scripture
    - Never be judgmental, condemning, or harsh — remember "a bruised reed He will not break" (Isaiah 42:3)
    - Use simple, relatable language — avoid overly academic theology
    - Quote Bible verses when relevant using the format "Book Chapter:Verse" (e.g., "John 3:16")
    - Keep responses concise but meaningful — aim for 2-4 short paragraphs max

    CONTENT BOUNDARIES:
    - If asked sexually explicit questions, respond graciously: "I appreciate you reaching out, but that's not something I can help with in detail. What I can share is that God designed intimacy as a beautiful gift within marriage (Hebrews 13:4). If you're struggling in this area, I'd encourage you to speak with a trusted pastor or counselor."
    - If asked to generate violent, hateful, or harmful content, gently decline and redirect to God's love
    - If asked about self-harm or suicide, respond with compassion, affirm their value to God, and encourage them to call 988 (Suicide & Crisis Lifeline) or speak to a pastor immediately
    - If asked about other religions, be respectful but clear about the Christian faith — do not syncretize or compromise biblical truth
    - If asked political questions, stay neutral and redirect to biblical principles rather than partisan positions
    - If asked about topics you're unsure of, say so honestly and point to Scripture for guidance
    - If asked anything sexually inappropriate, pornographic, or graphically explicit, firmly but lovingly decline: "I'm not able to engage with that kind of content. But I'm here if you'd like to talk about anything related to faith, life, or God's Word."
    - If asked to role-play inappropriate scenarios, generate profanity, or produce any content that dishonors God, decline graciously and redirect

    PERSONALITY:
    - You are joyful and hopeful — your tone reflects the joy of knowing Christ
    - You are conversational and approachable, not stiff or robotic
    - Speak like a warm friend and mentor — use everyday language, not formal or preachy
    - If asked about non-biblical topics, gently redirect to how faith applies

    FORMATTING RULES (VERY IMPORTANT):
    - NEVER use markdown formatting of any kind
    - Do NOT use ## headings, ** bold **, * italics *, ``` code blocks ```, or bullet points with - or *
    - Do NOT use numbered lists like "1." or "2."
    - Write in natural flowing paragraphs, like you're texting a friend
    - Use line breaks between paragraphs for readability
    - For Bible verses, just mention them naturally in the text like "John 3:16 says..."
    - Keep it warm, personal, and conversational — not structured or formatted like a document

    WHAT YOU DO NOT DO:
    - Never contradict Scripture or promote unbiblical ideas
    - Never provide medical, legal, or financial advice — recommend professional help
    - Never claim to replace a real pastor, church community, or professional counselor
    - Never generate explicit, violent, or harmful content of any kind
    - Never use profanity or crude language
    """

    private var toolkitBaseURL: String {
        Config.EXPO_PUBLIC_TOOLKIT_URL.isEmpty ? "https://toolkit.rork.com" : Config.EXPO_PUBLIC_TOOLKIT_URL
    }

    func sendMessage(messages: [ChatMessage]) async throws -> String {
        guard let url = URL(string: "\(toolkitBaseURL)/agent/chat") else {
            throw GuideError.invalidURL
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var apiMessages: [[String: Any]] = []

        let sysId = UUID().uuidString
        let sysDate = formatter.string(from: Date(timeIntervalSince1970: 0))
        let sysContent = "System instructions — follow these for ALL responses:\n\n\(systemPrompt)\n\nAcknowledge briefly and await the user's question."
        apiMessages.append([
            "id": sysId,
            "role": "user",
            "content": sysContent,
            "parts": [["type": "text", "text": sysContent]],
            "createdAt": sysDate
        ])

        let ackId = UUID().uuidString
        let ackContent = "Understood. I'm here as your biblical guide — ask me anything about faith, Scripture, or prayer."
        apiMessages.append([
            "id": ackId,
            "role": "assistant",
            "content": ackContent,
            "parts": [["type": "text", "text": ackContent]],
            "createdAt": sysDate
        ])

        var conversationMessages = messages
        while conversationMessages.first?.role == .assistant {
            conversationMessages.removeFirst()
        }

        if conversationMessages.isEmpty {
            throw GuideError.emptyResponse
        }

        var lastRole: String?
        for msg in conversationMessages {
            let role = msg.role.rawValue
            if role == lastRole { continue }
            let msgId = UUID().uuidString
            let msgDate = formatter.string(from: msg.timestamp)
            apiMessages.append([
                "id": msgId,
                "role": role,
                "content": msg.content,
                "parts": [["type": "text", "text": msg.content]],
                "createdAt": msgDate
            ])
            lastRole = role
        }

        guard apiMessages.last?["role"] as? String == "user" else {
            throw GuideError.emptyResponse
        }

        let payload: [String: Any] = ["messages": apiMessages]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        request.timeoutInterval = 60

        let (data, resp) = try await URLSession.shared.data(for: request)

        guard let httpResponse = resp as? HTTPURLResponse else {
            throw GuideError.serverError(0)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw GuideError.serverError(httpResponse.statusCode)
        }

        let responseText = String(data: data, encoding: .utf8) ?? ""
        let extracted = extractSSEText(from: responseText)
        let rawText = (extracted.isEmpty ? responseText : extracted)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let finalText = stripMarkdown(rawText)

        guard !finalText.isEmpty else {
            throw GuideError.emptyResponse
        }

        return finalText
    }

    func sendMessageWithRetry(messages: [ChatMessage], maxRetries: Int = 2) async throws -> String {
        var lastError: Error = GuideError.emptyResponse
        for attempt in 0...maxRetries {
            do {
                return try await sendMessage(messages: messages)
            } catch {
                lastError = error
                if attempt < maxRetries {
                    try? await Task.sleep(for: .seconds(Double(attempt + 1)))
                }
            }
        }
        throw lastError
    }

    private func stripMarkdown(_ text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: "###\\s*", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "##\\s*", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "#\\s*", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "\\*(.+?)\\*", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "```[\\s\\S]*?```", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "`(.+?)`", with: "$1", options: .regularExpression)
        result = result.replacingOccurrences(of: "(?m)^\\s*[-*]\\s+", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "(?m)^\\s*\\d+\\.\\s+", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
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
}

nonisolated enum GuideError: Error, LocalizedError, Sendable {
    case serverError(Int)
    case emptyResponse
    case invalidURL
    case missingAPIKey
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .serverError(let code):
            return "Server error (\(code)). Please try again."
        case .emptyResponse:
            return "No response received. Please try again."
        case .invalidURL:
            return "Unable to connect. Please try again."
        case .missingAPIKey:
            return "Unable to connect to server. Please try again later."
        case .apiError(let message):
            return message
        }
    }
}
