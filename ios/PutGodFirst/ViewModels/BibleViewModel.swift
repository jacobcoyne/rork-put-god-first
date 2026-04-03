import SwiftUI
import Observation

@Observable
final class BibleViewModel {
    var selectedTestament: Testament = .old
    var verses: [BibleVerse] = []
    var isLoadingChapter: Bool = false
    var selectedVerses: Set<String> = []
    var isGeneratingDevotional: Bool = false
    var generatedTitle: String = ""
    var generatedBody: String = ""
    var generatedPrayer: String = ""
    var showDevotionalSheet: Bool = false
    var searchText: String = ""

    var availableTranslations: [BibleTranslation] = []
    var selectedTranslation: BibleTranslation?
    var isLoadingTranslations: Bool = false

    var lastReadBook: String {
        didSet { UserDefaults.standard.set(lastReadBook, forKey: "bible_lastReadBook") }
    }
    var lastReadChapter: Int {
        didSet { UserDefaults.standard.set(lastReadChapter, forKey: "bible_lastReadChapter") }
    }

    var translationAbbreviation: String {
        selectedTranslation?.abbreviation ?? "Bible"
    }

    var filteredBooks: [BibleBook] {
        let books = BibleBook.allBooks.filter { $0.testament == selectedTestament }
        if searchText.isEmpty { return books }
        return books.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    init() {
        self.lastReadBook = UserDefaults.standard.string(forKey: "bible_lastReadBook") ?? ""
        self.lastReadChapter = UserDefaults.standard.integer(forKey: "bible_lastReadChapter")
    }

    @MainActor
    func loadTranslations() async {
        guard availableTranslations.isEmpty else { return }
        isLoadingTranslations = true

        let bibles = await BibleService.shared.fetchBibles()
        availableTranslations = bibles

        let savedId = UserDefaults.standard.string(forKey: "bible_translationId") ?? ""

        if let saved = bibles.first(where: { $0.id == savedId }) {
            selectedTranslation = saved
        } else if let kjv = bibles.first(where: {
            $0.abbreviation.uppercased().contains("KJV") || $0.name.uppercased().contains("KING JAMES")
        }) {
            selectedTranslation = kjv
        } else {
            selectedTranslation = bibles.first
        }

        isLoadingTranslations = false
    }

    @MainActor
    func retryLoadTranslations() async {
        availableTranslations = []
        selectedTranslation = nil
        await loadTranslations()
    }

    @MainActor
    func selectTranslation(_ translation: BibleTranslation) {
        selectedTranslation = translation
        UserDefaults.standard.set(translation.id, forKey: "bible_translationId")
    }

    @MainActor
    func loadChapter(book: BibleBook, chapter: Int) async {
        isLoadingChapter = true
        verses = []
        selectedVerses = []

        if selectedTranslation == nil {
            await loadTranslations()
        }

        guard let translation = selectedTranslation else {
            isLoadingChapter = false
            return
        }

        let result = await BibleService.shared.fetchChapter(bibleId: translation.id, book: book, chapter: chapter)
        verses = result ?? []
        isLoadingChapter = false

        if !verses.isEmpty {
            lastReadBook = book.id
            lastReadChapter = chapter
        }
    }

    func toggleVerseSelection(_ verse: BibleVerse) {
        if selectedVerses.contains(verse.id) {
            selectedVerses.remove(verse.id)
        } else {
            selectedVerses.insert(verse.id)
        }
    }

    var selectedVerseText: String {
        verses
            .filter { selectedVerses.contains($0.id) }
            .sorted { $0.verse < $1.verse }
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: " ")
    }

    var selectedVerseReference: String {
        let selected = verses
            .filter { selectedVerses.contains($0.id) }
            .sorted { $0.verse < $1.verse }

        guard let first = selected.first else { return "" }

        if selected.count == 1 {
            return "\(first.bookName) \(first.chapter):\(first.verse)"
        }

        let verseNums = selected.map { $0.verse }
        return "\(first.bookName) \(first.chapter):\(verseNums.map(String.init).joined(separator: ","))"
    }

    @MainActor
    func generateDevotional() async {
        guard !selectedVerses.isEmpty else { return }
        isGeneratingDevotional = true
        showDevotionalSheet = true

        let result = await BibleService.shared.generateVerseDevotional(
            reference: selectedVerseReference,
            verseText: selectedVerseText
        )

        if let result {
            generatedTitle = result.title
            generatedBody = result.body
            generatedPrayer = result.prayer
        } else {
            let ref = selectedVerseReference
            let fallbacks: [(title: String, body: String, prayer: String)] = [
                (
                    "Dwelling in the Word",
                    "There is something powerful about sitting with Scripture without rushing past it. This passage invites you to slow down and let the words wash over you. God speaks not only through grand revelations, but through the quiet repetition of truth sinking into your soul. Read it again slowly. What word or phrase catches your attention? That might be exactly where God wants to meet you today. Let this verse be a companion for the hours ahead \u{2014} something to return to when the noise of life grows loud.",
                    "Father, thank You for the gift of Your Word. Open my ears to hear what You are saying through \(ref). Let this passage take root in my heart and bear fruit in my life today. I trust that You are speaking, even in the stillness. In Jesus' name, Amen."
                ),
                (
                    "A Moment of Holy Ground",
                    "Every time you open Scripture, you step onto holy ground. These are not just ancient words \u{2014} they are living and active, as sharp today as the day they were first breathed by God. This passage from \(ref) carries a message uniquely timed for where you are right now. You did not stumble upon it by accident. God is intentional, and He has led you here. Sit with these words. Let them challenge you, comfort you, and call you deeper into His presence.",
                    "Lord, I come before You with an open heart. You led me to \(ref) for a reason. Reveal what I need to see. Soften what needs softening. Strengthen what needs strengthening. I choose to trust Your timing and Your Word today. Amen."
                ),
                (
                    "Seeds for the Soul",
                    "Scripture is like a seed planted in good soil. It does not always show its fruit immediately, but it is always at work beneath the surface. This passage you've chosen may not fully reveal its meaning today \u{2014} and that's okay. Sometimes God plants a verse in your heart and waters it over days, weeks, even years. Trust the process. Return to \(ref) throughout your day. Whisper it in prayer. Let it become part of the rhythm of your thoughts.",
                    "God, plant the truth of \(ref) deep within me. Even when I don't fully understand, I trust that Your Word never returns empty. Let these words grow into wisdom, courage, and love in my life. Water them with Your Spirit. In Jesus' name, Amen."
                ),
                (
                    "The God Who Speaks",
                    "In a world full of noise, God still speaks. He speaks through sunrise and silence, through friendship and struggle \u{2014} but most clearly through His Word. By choosing to read \(ref), you've done something countercultural: you've paused to listen. That matters more than you know. God honors the heart that seeks Him. He draws near to those who draw near. So take a deep breath. Read the passage one more time. And know that the God of the universe is present with you in this very moment.",
                    "Heavenly Father, thank You for being a God who speaks. I want to hear Your voice above every other voice today. Let the truth of \(ref) echo in my mind and shape my decisions. Draw me closer to You with every reading. Amen."
                ),
                (
                    "An Anchor for Today",
                    "Some days feel steady. Others feel like you're caught in a storm you didn't see coming. Either way, God's Word is your anchor. This passage from \(ref) is not a fragile sentiment \u{2014} it is bedrock truth that has held God's people for thousands of years. Whatever today holds, you can return to these words. Let them ground you when anxiety rises. Let them remind you whose you are when the world tries to define you by something less.",
                    "Lord, be my anchor today. When doubt creeps in and worry pulls at me, bring me back to the truth of \(ref). I choose to build my day on the foundation of Your Word, not on shifting circumstances. Hold me steady, Father. Amen."
                ),
            ]
            let pick = fallbacks[Int.random(in: 0..<fallbacks.count)]
            generatedTitle = pick.title
            generatedBody = pick.body
            generatedPrayer = pick.prayer
        }

        isGeneratingDevotional = false
    }
}
