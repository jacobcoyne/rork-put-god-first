import Foundation

nonisolated struct DailyVerse: Identifiable, Codable, Sendable {
    let id: UUID
    let reference: String
    let text: String
    let translation: String

    init(id: UUID = UUID(), reference: String, text: String, translation: String = "ESV") {
        self.id = id
        self.reference = reference
        self.text = text
        self.translation = translation
    }
}

nonisolated struct Devotional: Identifiable, Codable, Sendable {
    let id: UUID
    let title: String
    let body: String
    let readingTimeMinutes: Int

    init(id: UUID = UUID(), title: String, body: String, readingTimeMinutes: Int = 3) {
        self.id = id
        self.title = title
        self.body = body
        self.readingTimeMinutes = readingTimeMinutes
    }
}

nonisolated struct DailyContent: Identifiable, Codable, Sendable {
    let id: UUID
    let date: Date
    let verse: DailyVerse
    let devotional: Devotional

    init(id: UUID = UUID(), date: Date = .now, verse: DailyVerse, devotional: Devotional) {
        self.id = id
        self.date = date
        self.verse = verse
        self.devotional = devotional
    }
}

nonisolated enum ContentLibrary {
    static let dailyContent: [DailyContent] = [
        DailyContent(
            verse: DailyVerse(
                reference: "Psalm 5:3",
                text: "In the morning, Lord, you hear my voice; in the morning I lay my requests before you and wait expectantly."
            ),
            devotional: Devotional(
                title: "The First Voice",
                body: "Before the noise of the day rushes in — before notifications, headlines, and to-do lists — there is a sacred quiet. God invites you into it. Not because He needs your attention, but because He knows you need His.\n\nWhen David wrote these words, he was a king with a kingdom to run. Yet he chose to begin each day not with strategy, but with surrender. He laid his requests before God and then did something radical: he waited.\n\nWaiting is not passive. It is an act of trust. It says, \"I believe You are working even when I cannot see it.\" Today, before you pick up your phone, before you check your messages — pause. Lay your day before Him. And wait expectantly, because He is faithful.",
                readingTimeMinutes: 3
            )
        ),
        DailyContent(
            verse: DailyVerse(
                reference: "Lamentations 3:22-23",
                text: "The steadfast love of the Lord never ceases; his mercies never come to an end; they are new every morning; great is your faithfulness."
            ),
            devotional: Devotional(
                title: "New Every Morning",
                body: "Yesterday's failures do not define today. Yesterday's worries do not own this morning. God's mercy is not recycled — it is brand new, crafted fresh for this exact day, for this exact you.\n\nJeremiah wrote these words in the middle of devastation. Jerusalem was in ruins. Everything he loved had been torn apart. And yet, in the rubble, he found this: God's love had not stopped. His faithfulness had not failed.\n\nIf God can be faithful in ruins, He can be faithful in your Monday morning. He can be faithful in your anxiety. He can be faithful in your uncertainty. Take a breath. His mercies are already here, waiting for you.",
                readingTimeMinutes: 3
            )
        ),
        DailyContent(
            verse: DailyVerse(
                reference: "Matthew 6:33",
                text: "But seek first the kingdom of God and his righteousness, and all these things will be added to you."
            ),
            devotional: Devotional(
                title: "Seek First",
                body: "Jesus didn't say \"seek also\" or \"seek when convenient.\" He said seek first. There's an order to the abundant life, and it begins with priority.\n\nThis isn't about earning God's provision through religious performance. It's about alignment. When we orient our hearts toward God before anything else, everything else finds its proper place.\n\nThink of it like tuning an instrument before a concert. The music doesn't come from the tuning — but without it, everything that follows is slightly off. When you seek God first, the rest of your day plays in tune with His purposes.\n\nWhat are you tempted to seek first today? Comfort? Control? Approval? Lay it down. Seek Him. Watch what He adds.",
                readingTimeMinutes: 4
            )
        ),
        DailyContent(
            verse: DailyVerse(
                reference: "Isaiah 40:31",
                text: "But those who wait on the Lord shall renew their strength; they shall mount up with wings like eagles; they shall run and not be weary; they shall walk and not faint."
            ),
            devotional: Devotional(
                title: "Strength in Stillness",
                body: "The world tells you to hustle harder. To optimize. To grind. But God offers a different path to strength — waiting on Him.\n\nThis Hebrew word for \"wait\" — qavah — means to bind together, like twisting strands into a rope. When you wait on God, you're not idle. You're being woven together with His strength. Your weakness and His power become one cord that cannot be easily broken.\n\nEagles don't flap frantically to reach great heights. They find the thermal — the rising current of warm air — and they spread their wings and soar. God is your thermal this morning. Stop flapping. Spread your wings. Let Him lift you.\n\nToday's strength doesn't come from your effort. It comes from His presence.",
                readingTimeMinutes: 3
            )
        ),
        DailyContent(
            verse: DailyVerse(
                reference: "Proverbs 3:5-6",
                text: "Trust in the Lord with all your heart, and do not lean on your own understanding. In all your ways acknowledge him, and he will make straight your paths."
            ),
            devotional: Devotional(
                title: "All Your Heart",
                body: "Half-hearted trust isn't trust at all — it's hedging your bets. Solomon, the wisest man who ever lived, knew that real wisdom begins with full surrender.\n\n\"Do not lean on your own understanding\" is not a call to ignorance. It's a call to humility. It means holding your plans with open hands. It means admitting that the God who sees the end from the beginning might have a better route than your GPS.\n\nAcknowledge Him in all your ways — not just the spiritual ones. In your work. In your relationships. In your finances. In the small, mundane decisions that shape your life. When you do, He doesn't just bless the path — He straightens it.\n\nWhat path feels crooked right now? Bring it to Him this morning.",
                readingTimeMinutes: 4
            )
        ),
        DailyContent(
            verse: DailyVerse(
                reference: "Philippians 4:6-7",
                text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds."
            ),
            devotional: Devotional(
                title: "Guarded by Peace",
                body: "Anxiety is the thief of mornings. It wakes you with a racing mind, a tight chest, a list of \"what ifs\" before your feet hit the floor. Paul knew this. He wrote these words from a prison cell.\n\nHis antidote is beautifully specific: don't just pray — pray with thanksgiving. Gratitude rewires anxiety. It shifts your gaze from what might go wrong to what God has already done right.\n\nAnd the result? Peace that doesn't make sense. Peace that guards — like a soldier standing watch over your heart and mind. Not peace because your circumstances changed, but peace because your perspective did.\n\nName three things you're grateful for right now. Then give Him your anxieties. Trade the weight for His peace.",
                readingTimeMinutes: 3
            )
        ),
        DailyContent(
            verse: DailyVerse(
                reference: "Joshua 1:9",
                text: "Have I not commanded you? Be strong and courageous. Do not be frightened, and do not be dismayed, for the Lord your God is with you wherever you go."
            ),
            devotional: Devotional(
                title: "He Goes With You",
                body: "God doesn't say \"be strong because you're capable.\" He says \"be strong because I'm with you.\" The source of your courage is not your competence — it's His companionship.\n\nJoshua stood at the edge of an impossible task. Lead millions of people into hostile territory. Fill the shoes of Moses. Conquer fortified cities. And God's instruction? Don't be afraid. I'm coming with you.\n\nWhatever you're facing today — the meeting, the conversation, the diagnosis, the decision — you don't face it alone. The God who parted seas and crumbled walls walks beside you into every room, every challenge, every unknown.\n\nYou are not strong enough on your own. You were never meant to be. His presence is your strength.",
                readingTimeMinutes: 3
            )
        )
    ]

    static func contentForToday() -> DailyContent {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let index = (dayOfYear - 1) % dailyContent.count
        return dailyContent[index]
    }
}
