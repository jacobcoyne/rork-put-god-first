import Foundation

nonisolated struct AlarmVerse: Sendable, Identifiable {
    let id: Int
    let reference: String
    let text: String
}

enum AlarmVerseLibrary {
    private static let recentKey = "recentVerseIds"
    private static let maxRecent = 10

    static let verses: [AlarmVerse] = [
        AlarmVerse(id: 1, reference: "Psalm 5:3", text: "In the morning, Lord, you hear my voice; in the morning I lay my requests before you and wait expectantly."),
        AlarmVerse(id: 2, reference: "Lamentations 3:22-23", text: "Because of the Lord's great love we are not consumed, for his compassions never fail. They are new every morning; great is your faithfulness."),
        AlarmVerse(id: 3, reference: "Psalm 118:24", text: "This is the day that the Lord has made; let us rejoice and be glad in it."),
        AlarmVerse(id: 4, reference: "Proverbs 3:5-6", text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight."),
        AlarmVerse(id: 5, reference: "Philippians 4:13", text: "I can do all things through Christ who strengthens me."),
        AlarmVerse(id: 6, reference: "Joshua 1:9", text: "Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go."),
        AlarmVerse(id: 7, reference: "Jeremiah 29:11", text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future."),
        AlarmVerse(id: 8, reference: "Psalm 23:1", text: "The Lord is my shepherd, I lack nothing."),
        AlarmVerse(id: 9, reference: "Romans 8:28", text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose."),
        AlarmVerse(id: 10, reference: "Isaiah 40:31", text: "But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint."),
        AlarmVerse(id: 11, reference: "Psalm 46:10", text: "Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth."),
        AlarmVerse(id: 12, reference: "Matthew 6:33", text: "But seek first his kingdom and his righteousness, and all these things will be given to you as well."),
        AlarmVerse(id: 13, reference: "Psalm 19:14", text: "May these words of my mouth and this meditation of my heart be pleasing in your sight, Lord, my Rock and my Redeemer."),
        AlarmVerse(id: 14, reference: "Romans 12:2", text: "Do not conform to the pattern of this world, but be transformed by the renewing of your mind."),
        AlarmVerse(id: 15, reference: "Psalm 139:14", text: "I praise you because I am fearfully and wonderfully made; your works are wonderful, I know that full well."),
        AlarmVerse(id: 16, reference: "2 Timothy 1:7", text: "For the Spirit God gave us does not make us timid, but gives us power, love and self-discipline."),
        AlarmVerse(id: 17, reference: "Psalm 143:8", text: "Let the morning bring me word of your unfailing love, for I have put my trust in you. Show me the way I should go, for to you I entrust my life."),
        AlarmVerse(id: 18, reference: "Colossians 3:23", text: "Whatever you do, work at it with all your heart, as working for the Lord, not for human masters."),
        AlarmVerse(id: 19, reference: "Psalm 90:14", text: "Satisfy us in the morning with your unfailing love, that we may sing for joy and be glad all our days."),
        AlarmVerse(id: 20, reference: "Isaiah 41:10", text: "So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you; I will uphold you with my righteous right hand."),
        AlarmVerse(id: 21, reference: "Ephesians 6:10", text: "Finally, be strong in the Lord and in his mighty power."),
        AlarmVerse(id: 22, reference: "Psalm 27:1", text: "The Lord is my light and my salvation, whom shall I fear? The Lord is the stronghold of my life, of whom shall I be afraid?"),
        AlarmVerse(id: 23, reference: "Galatians 5:22-23", text: "But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness, gentleness and self-control."),
        AlarmVerse(id: 24, reference: "1 Corinthians 16:13", text: "Be on your guard; stand firm in the faith; be courageous; be strong."),
        AlarmVerse(id: 25, reference: "Psalm 37:4", text: "Take delight in the Lord, and he will give you the desires of your heart."),
        AlarmVerse(id: 26, reference: "Matthew 11:28", text: "Come to me, all you who are weary and burdened, and I will give you rest."),
        AlarmVerse(id: 27, reference: "Hebrews 11:1", text: "Now faith is confidence in what we hope for and assurance about what we do not see."),
        AlarmVerse(id: 28, reference: "Psalm 34:8", text: "Taste and see that the Lord is good; blessed is the one who takes refuge in him."),
        AlarmVerse(id: 29, reference: "Philippians 4:6-7", text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus."),
        AlarmVerse(id: 30, reference: "Deuteronomy 31:6", text: "Be strong and courageous. Do not be afraid or terrified because of them, for the Lord your God goes with you; he will never leave you nor forsake you.")
    ]

    static func randomVerse() -> AlarmVerse {
        let recentIds = UserDefaults.standard.array(forKey: recentKey) as? [Int] ?? []
        let available = verses.filter { !recentIds.contains($0.id) }
        let chosen = (available.isEmpty ? verses : available).randomElement() ?? verses[0]
        trackVerse(chosen)
        return chosen
    }

    private static func trackVerse(_ verse: AlarmVerse) {
        var recentIds = UserDefaults.standard.array(forKey: recentKey) as? [Int] ?? []
        recentIds.append(verse.id)
        if recentIds.count > maxRecent {
            recentIds.removeFirst(recentIds.count - maxRecent)
        }
        UserDefaults.standard.set(recentIds, forKey: recentKey)
    }
}
