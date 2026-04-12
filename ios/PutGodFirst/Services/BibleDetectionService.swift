import Foundation
import Vision
import UIKit

nonisolated final class BibleDetectionService: Sendable {
    static let shared = BibleDetectionService()

    private static let bibleBooks: Set<String> = [
        "genesis", "exodus", "leviticus", "numbers", "deuteronomy",
        "joshua", "judges", "ruth", "samuel", "kings", "chronicles",
        "ezra", "nehemiah", "esther", "job", "psalm", "psalms",
        "proverbs", "ecclesiastes", "song of solomon", "isaiah",
        "jeremiah", "lamentations", "ezekiel", "daniel", "hosea",
        "joel", "amos", "obadiah", "jonah", "micah", "nahum",
        "habakkuk", "zephaniah", "haggai", "zechariah", "malachi",
        "matthew", "mark", "luke", "john", "acts", "romans",
        "corinthians", "galatians", "ephesians", "philippians",
        "colossians", "thessalonians", "timothy", "titus", "philemon",
        "hebrews", "james", "peter", "jude", "revelation", "revelations"
    ]

    private static let bibleKeywords: Set<String> = [
        "lord", "god", "jesus", "christ", "holy", "spirit", "scripture",
        "gospel", "apostle", "prophet", "commandment", "covenant",
        "salvation", "righteousness", "grace", "mercy", "faith",
        "prayer", "amen", "hallelujah", "blessed", "thou", "thy",
        "thee", "hath", "unto", "saith", "verily", "behold",
        "chapter", "verse", "testament", "selah", "parable",
        "heaven", "sin", "forgive", "praise", "worship", "lamb",
        "shepherd", "david", "moses", "abraham", "israel",
        "jerusalem", "disciples", "angel", "eternal", "kingdom",
        "glory", "redeemer", "crucified", "resurrection", "baptize",
        "pharisee", "sabbath", "tabernacle", "altar", "offering"
    ]

    private static let versePattern = try! NSRegularExpression(
        pattern: "\\d+\\s*:\\s*\\d+",
        options: []
    )

    func detectBible(in image: UIImage) async -> (isBible: Bool, confidence: Double, detectedText: String) {
        guard let cgImage = image.cgImage else {
            return (false, 0, "")
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage)

        do {
            try handler.perform([request])
        } catch {
            return (false, 0, "")
        }

        guard let observations = request.results else {
            return (false, 0, "")
        }

        let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
        let fullText = recognizedStrings.joined(separator: " ")
        let lowerText = fullText.lowercased()

        var score: Double = 0
        var matchedItems: [String] = []

        var bookMatches = 0
        for book in Self.bibleBooks {
            if lowerText.contains(book) {
                bookMatches += 1
                matchedItems.append(book.capitalized)
            }
        }
        score += min(Double(bookMatches) * 20, 35)

        var keywordMatches = 0
        for keyword in Self.bibleKeywords {
            if lowerText.contains(keyword) {
                keywordMatches += 1
            }
        }
        score += min(Double(keywordMatches) * 6, 45)

        let verseRange = NSRange(lowerText.startIndex..., in: lowerText)
        let verseMatches = Self.versePattern.numberOfMatches(in: lowerText, range: verseRange)
        if verseMatches > 0 {
            score += min(Double(verseMatches) * 12, 30)
        }

        if recognizedStrings.count > 3 {
            score += 10
        }

        if recognizedStrings.count > 8 {
            score += 5
        }

        let confidence = min(score / 100.0, 1.0)
        let isBible = confidence >= 0.18

        return (isBible, confidence, fullText)
    }
}
