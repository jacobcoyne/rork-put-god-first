import Foundation

nonisolated enum PrayerCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case lordsPlayer = "The Lord's Prayer"
    case biblical = "Biblical Prayers"
    case earlyChurch = "Early Church"
    case theologians = "Theologian Prayers"
    case reformers = "Reformer Prayers"
    case morning = "Morning Prayers"
    case evening = "Evening Prayers"
    case peace = "Peace & Rest"
    case provision = "Provision"
    case gratitude = "Gratitude"
    case repentance = "Repentance"
    case spiritual = "Spiritual Warfare"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .lordsPlayer: return "hands.sparkles"
        case .biblical: return "book.closed.fill"
        case .earlyChurch: return "building.columns"
        case .theologians: return "text.book.closed"
        case .reformers: return "scroll"
        case .morning: return "sunrise"
        case .evening: return "moon.stars"
        case .peace: return "leaf"
        case .provision: return "hand.raised"
        case .gratitude: return "heart"
        case .repentance: return "drop"
        case .spiritual: return "shield.fill"
        }
    }

    var color: String {
        switch self {
        case .lordsPlayer: return "gold"
        case .biblical: return "blue"
        case .earlyChurch: return "stone"
        case .theologians: return "sage"
        case .reformers: return "brown"
        case .morning: return "amber"
        case .evening: return "indigo"
        case .peace: return "teal"
        case .provision: return "warm"
        case .gratitude: return "rose"
        case .repentance: return "gray"
        case .spiritual: return "red"
        }
    }
}

nonisolated struct Prayer: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let title: String
    let author: String
    let text: String
    let category: PrayerCategory

    init(id: UUID = UUID(), title: String, author: String, text: String, category: PrayerCategory) {
        self.id = id
        self.title = title
        self.author = author
        self.text = text
        self.category = category
    }
}

nonisolated enum PrayerLibrary {
    static let prayers: [Prayer] = [
        // MARK: - The Lord's Prayer
        Prayer(
            title: "The Lord's Prayer",
            author: "Jesus Christ",
            text: "Our Father, who art in heaven,\nhallowed be thy name;\nthy kingdom come;\nthy will be done;\non earth as it is in heaven.\n\nGive us this day our daily bread.\nAnd forgive us our trespasses,\nas we forgive those who trespass against us.\nAnd lead us not into temptation;\nbut deliver us from evil.\n\nFor thine is the kingdom,\nthe power and the glory,\nfor ever and ever.\n\nAmen.",
            category: .lordsPlayer
        ),

        // MARK: - Biblical Prayers
        Prayer(
            title: "Prayer of Moses",
            author: "Moses (Psalm 90:12-17)",
            text: "Teach us to number our days,\nthat we may gain a heart of wisdom.\n\nRelent, Lord! How long will it be?\nHave compassion on your servants.\nSatisfy us in the morning with your unfailing love,\nthat we may sing for joy and be glad all our days.\n\nMake us glad for as many days as you have afflicted us,\nfor as many years as we have seen trouble.\nMay your deeds be shown to your servants,\nyour splendor to their children.\n\nMay the favor of the Lord our God rest on us;\nestablish the work of our hands for us —\nyes, establish the work of our hands.\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "Hannah's Prayer",
            author: "Hannah (1 Samuel 2:1-2)",
            text: "My heart rejoices in the Lord;\nin the Lord my horn is lifted high.\nMy mouth boasts over my enemies,\nfor I delight in your deliverance.\n\nThere is no one holy like the Lord;\nthere is no one besides you;\nthere is no Rock like our God.\n\nThe Lord brings death and makes alive;\nhe brings down to the grave and raises up.\nThe Lord sends poverty and wealth;\nhe humbles and he exalts.\n\nHe raises the poor from the dust\nand lifts the needy from the ash heap;\nhe seats them with princes\nand has them inherit a throne of honor.\n\nFor the foundations of the earth are the Lord's;\non them he has set the world.\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "Solomon's Prayer for Wisdom",
            author: "King Solomon (1 Kings 3:6-9)",
            text: "Lord my God, you have made your servant king\nin place of my father David.\nBut I am only a little child\nand do not know how to carry out my duties.\n\nYour servant is here among the people you have chosen,\na great people, too numerous to count or number.\n\nSo give your servant a discerning heart\nto govern your people\nand to distinguish between right and wrong.\nFor who is able to govern this great people of yours?\n\nGrant me wisdom, O God,\nthat I may walk in your ways\nand lead with justice and mercy.\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "David's Prayer of Repentance",
            author: "King David (Psalm 51:1-12)",
            text: "Have mercy on me, O God,\naccording to your unfailing love;\naccording to your great compassion\nblot out my transgressions.\n\nWash away all my iniquity\nand cleanse me from my sin.\nFor I know my transgressions,\nand my sin is always before me.\n\nCleanse me with hyssop, and I will be clean;\nwash me, and I will be whiter than snow.\nLet me hear joy and gladness;\nlet the bones you have crushed rejoice.\n\nHide your face from my sins\nand blot out all my iniquity.\nCreate in me a pure heart, O God,\nand renew a steadfast spirit within me.\n\nDo not cast me from your presence\nor take your Holy Spirit from me.\nRestore to me the joy of your salvation\nand grant me a willing spirit, to sustain me.\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "The Prayer of Jabez",
            author: "Jabez (1 Chronicles 4:10)",
            text: "Oh, that you would bless me\nand enlarge my territory!\n\nLet your hand be with me,\nand keep me from harm\nso that I will be free from pain.\n\nLord, I ask for your blessing today.\nExpand my influence for your kingdom.\nBe with me in all I do.\nProtect me from evil and from causing pain.\n\nI trust in your goodness\nand your generous heart toward your children.\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "Paul's Prayer for the Ephesians",
            author: "Apostle Paul (Ephesians 3:14-21)",
            text: "For this reason I kneel before the Father,\nfrom whom every family in heaven and on earth\nderives its name.\n\nI pray that out of his glorious riches\nhe may strengthen you with power\nthrough his Spirit in your inner being,\nso that Christ may dwell in your hearts through faith.\n\nAnd I pray that you, being rooted and established in love,\nmay have power, together with all the Lord's holy people,\nto grasp how wide and long and high and deep\nis the love of Christ,\nand to know this love that surpasses knowledge —\nthat you may be filled to the measure\nof all the fullness of God.\n\nNow to him who is able to do immeasurably more\nthan all we ask or imagine,\naccording to his power that is at work within us,\nto him be glory in the church\nand in Christ Jesus throughout all generations,\nfor ever and ever!\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "Paul's Prayer for the Philippians",
            author: "Apostle Paul (Philippians 1:9-11)",
            text: "And this is my prayer:\nthat your love may abound more and more\nin knowledge and depth of insight,\nso that you may be able to discern what is best\nand may be pure and blameless\nfor the day of Christ,\nfilled with the fruit of righteousness\nthat comes through Jesus Christ —\nto the glory and praise of God.\n\nLord, let my love grow deeper.\nGive me discernment and wisdom.\nMake me pure in heart.\nFill me with the fruit of your Spirit.\n\nAll for your glory.\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "The Magnificat",
            author: "Mary, Mother of Jesus (Luke 1:46-55)",
            text: "My soul glorifies the Lord\nand my spirit rejoices in God my Savior,\nfor he has been mindful\nof the humble state of his servant.\n\nFrom now on all generations will call me blessed,\nfor the Mighty One has done great things for me —\nholy is his name.\n\nHis mercy extends to those who fear him,\nfrom generation to generation.\nHe has performed mighty deeds with his arm;\nhe has scattered those who are proud\nin their inmost thoughts.\n\nHe has brought down rulers from their thrones\nbut has lifted up the humble.\nHe has filled the hungry with good things\nbut has sent the rich away empty.\n\nHe has helped his servant Israel,\nremembering to be merciful to Abraham\nand his descendants forever,\njust as he promised our ancestors.\n\nAmen.",
            category: .biblical
        ),
        Prayer(
            title: "Daniel's Prayer of Confession",
            author: "Daniel (Daniel 9:4-5, 17-19)",
            text: "Lord, the great and awesome God,\nwho keeps his covenant of love\nwith those who love him\nand keep his commandments,\n\nwe have sinned and done wrong.\nWe have been wicked and have rebelled;\nwe have turned away from your commands and laws.\n\nNow, our God, hear the prayers\nand petitions of your servant.\nFor your sake, Lord,\nlook with favor on your desolate sanctuary.\n\nGive ear, our God, and hear;\nopen your eyes and see the desolation.\nWe do not make requests of you\nbecause we are righteous,\nbut because of your great mercy.\n\nLord, listen! Lord, forgive!\nLord, hear and act!\nFor your sake, my God, do not delay.\n\nAmen.",
            category: .biblical
        ),

        // MARK: - Early Church
        Prayer(
            title: "The Jesus Prayer",
            author: "Desert Fathers",
            text: "Lord Jesus Christ,\nSon of God,\nhave mercy on me, a sinner.\n\nThis ancient prayer is meant to be repeated slowly and meditatively, breathing in with \"Lord Jesus Christ, Son of God\" and breathing out with \"have mercy on me, a sinner.\"\n\nLet each repetition draw you deeper into the presence of God.\nLet the words become the rhythm of your heart.\n\nLord Jesus Christ, Son of God,\nhave mercy on me, a sinner.\n\nAmen.",
            category: .earlyChurch
        ),
        Prayer(
            title: "Morning Prayer of St. Patrick",
            author: "St. Patrick",
            text: "I arise today through a mighty strength,\nthe invocation of the Trinity,\nthrough belief in the Threeness,\nthrough confession of the Oneness\nof the Creator of creation.\n\nChrist with me, Christ before me,\nChrist behind me, Christ in me,\nChrist beneath me, Christ above me,\nChrist on my right, Christ on my left,\nChrist when I lie down,\nChrist when I sit down,\nChrist when I arise.\n\nChrist in the heart of every man who thinks of me,\nChrist in the mouth of everyone who speaks of me,\nChrist in every eye that sees me,\nChrist in every ear that hears me.\n\nAmen.",
            category: .earlyChurch
        ),
        Prayer(
            title: "The Doxology",
            author: "Early Church Tradition",
            text: "Glory be to the Father,\nand to the Son,\nand to the Holy Spirit,\nas it was in the beginning,\nis now, and ever shall be,\nworld without end.\n\nAmen.",
            category: .earlyChurch
        ),
        Prayer(
            title: "Prayer of St. Clement of Rome",
            author: "St. Clement of Rome (c. 96 AD)",
            text: "We beg you, Lord,\nto help and defend us.\n\nDeliver the oppressed,\npity the insignificant,\nraise the fallen,\nshow yourself to the needy,\nheal the sick,\nbring back those of your people who have gone astray,\nfeed the hungry,\nlift up the weak,\ntake off the prisoners' chains.\n\nMay every nation come to know\nthat you alone are God,\nthat Jesus Christ is your Child,\nthat we are your people,\nthe sheep of your pasture.\n\nAmen.",
            category: .earlyChurch
        ),
        Prayer(
            title: "Prayer of St. Augustine",
            author: "St. Augustine (354–430 AD)",
            text: "Breathe in me, O Holy Spirit,\nthat my thoughts may all be holy.\n\nAct in me, O Holy Spirit,\nthat my work, too, may be holy.\n\nDraw my heart, O Holy Spirit,\nthat I love but what is holy.\n\nStrengthen me, O Holy Spirit,\nto defend all that is holy.\n\nGuard me, then, O Holy Spirit,\nthat I always may be holy.\n\nAmen.",
            category: .earlyChurch
        ),
        Prayer(
            title: "The Trisagion",
            author: "Ancient Liturgical Prayer",
            text: "Holy God,\nHoly Mighty,\nHoly Immortal,\nhave mercy on us.\n\nHoly God,\nHoly Mighty,\nHoly Immortal,\nhave mercy on us.\n\nHoly God,\nHoly Mighty,\nHoly Immortal,\nhave mercy on us.\n\nGlory to the Father, and to the Son,\nand to the Holy Spirit,\nnow and ever and unto ages of ages.\n\nAmen.",
            category: .earlyChurch
        ),
        Prayer(
            title: "Prayer of St. Ephrem the Syrian",
            author: "St. Ephrem (306–373 AD)",
            text: "O Lord and Master of my life,\ntake from me the spirit of sloth,\nfaint-heartedness, lust of power,\nand idle talk.\n\nBut give rather the spirit of chastity,\nhumility, patience, and love\nto your servant.\n\nYea, O Lord and King,\ngrant me to see my own errors\nand not to judge my brother,\nfor you are blessed unto ages of ages.\n\nAmen.",
            category: .earlyChurch
        ),
        Prayer(
            title: "The Nunc Dimittis",
            author: "Simeon (Luke 2:29–32)",
            text: "Lord, now you let your servant go in peace;\nyour word has been fulfilled.\n\nMy own eyes have seen the salvation\nwhich you have prepared\nin the sight of every people:\n\na light to reveal you to the nations\nand the glory of your people Israel.\n\nGlory to the Father, and to the Son,\nand to the Holy Spirit,\nas it was in the beginning,\nis now, and will be forever.\n\nAmen.",
            category: .earlyChurch
        ),

        // MARK: - Theologian Prayers
        Prayer(
            title: "Morning Consecration",
            author: "Charles Spurgeon",
            text: "Blessed Lord, as the day begins, I consecrate myself to you.\nLet my every thought be captured by your grace.\nLet my every word reflect your love.\nLet my every action honor your name.\n\nI do not know what this day holds,\nbut I know who holds this day.\nYou are sovereign over every hour,\nevery meeting, every conversation,\nevery trial and every triumph.\n\nI surrender my plans to your purposes.\nI trade my anxiety for your peace.\nI exchange my weakness for your strength.\n\nLead me, Lord. I follow.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "Prayer for Nearness to God",
            author: "A.W. Tozer",
            text: "O God, I have tasted thy goodness,\nand it has both satisfied me\nand made me thirsty for more.\n\nI am painfully conscious of my need\nof further grace.\nI am ashamed of my lack of desire.\n\nO God, the Triune God,\nI want to want thee;\nI long to be filled with longing;\nI thirst to be made more thirsty still.\n\nShow me thy glory, I pray thee,\nthat so I may know thee indeed.\nBegin in mercy a new work of love within me.\n\nSay to my soul, \"Rise up, my love,\nmy fair one, and come away.\"\n\nThen give me grace to rise and follow thee\nup from this misty lowland\nwhere I have wandered so long.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "Prayer for a Holy Life",
            author: "Dietrich Bonhoeffer",
            text: "O God, early in the morning I cry to you.\nHelp me to pray and to concentrate my thoughts on you;\nI cannot do this alone.\n\nIn me there is darkness,\nbut with you there is light;\nI am lonely, but you do not leave me;\nI am feeble in heart,\nbut with you there is help;\nI am restless, but with you there is peace.\n\nIn me there is bitterness,\nbut with you there is patience;\nI do not understand your ways,\nbut you know the way for me.\n\nRestore me to liberty,\nand enable me to live now\nthat I may answer before you and before men.\n\nLord, whatever this day may bring,\nyour name be praised.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "The Serenity Prayer",
            author: "Reinhold Niebuhr",
            text: "God, grant me the serenity\nto accept the things I cannot change,\nthe courage to change the things I can,\nand the wisdom to know the difference.\n\nLiving one day at a time,\nenjoying one moment at a time;\naccepting hardship as a pathway to peace;\ntaking, as Jesus did,\nthis sinful world as it is,\nnot as I would have it;\n\ntrusting that you will make all things right\nif I surrender to your will;\nso that I may be reasonably happy in this life\nand supremely happy with you forever in the next.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "Prayer of Self-Surrender",
            author: "Charles de Foucauld",
            text: "Father, I abandon myself into your hands;\ndo with me what you will.\n\nWhatever you may do, I thank you:\nI am ready for all, I accept all.\nLet only your will be done in me,\nand in all your creatures.\n\nI wish no more than this, O Lord.\nInto your hands I commend my soul;\nI offer it to you\nwith all the love of my heart,\nfor I love you, Lord,\nand so need to give myself,\nto surrender myself into your hands,\nwithout reserve,\nand with boundless confidence,\nfor you are my Father.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "Prayer Before Scripture",
            author: "John Calvin",
            text: "O Lord, heavenly Father,\nin whom is the fullness of light and wisdom,\nenlighten our minds by your Holy Spirit,\nand give us grace to receive your Word\nwith reverence and humility,\nwithout which no one can understand your truth.\n\nFor Christ's sake.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "Prayer for True Religion",
            author: "C.S. Lewis",
            text: "Lord, I pray that you would give me\nthe grace to see clearly.\n\nHelp me not to settle for a religion\nthat is merely comfortable,\nbut to pursue the one that is true.\n\nBreak my heart where it needs breaking.\nShake my foundations where they need shaking.\nReveal your character to me,\nnot as I wish you to be,\nbut as you truly are.\n\nFor in knowing you as you are,\nI will find joy I never imagined,\nand freedom I never knew I needed.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "Prayer for the Day",
            author: "Corrie ten Boom",
            text: "Lord Jesus, thank you\nthat you are with me today.\n\nThank you that I can never drift\nbeyond your love and care.\n\nEven when I walk through the darkest valley,\nyou are there.\nEven when the enemy surrounds me,\nyou prepare a table before me.\n\nI hold on to this promise:\nno pit is so deep\nthat your love is not deeper still.\n\nCarry me through this day\nwith the strength that only comes from you.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "The Valley of Vision",
            author: "Puritan Prayer (Anonymous)",
            text: "Lord, high and holy, meek and lowly,\nthou hast brought me to the valley of vision,\nwhere I live in the depths but see thee in the heights;\nhemmed in by mountains of sin I behold thy glory.\n\nLet me learn by paradox\nthat the way down is the way up,\nthat to be low is to be high,\nthat the broken heart is the healed heart,\nthat the contrite spirit is the rejoicing spirit,\nthat the repenting soul is the victorious soul,\nthat to have nothing is to possess all,\nthat to bear the cross is to wear the crown,\nthat to give is to receive.\n\nLet me find thy light in my darkness,\nthy life in my death,\nthy joy in my sorrow,\nthy grace in my sin,\nthy riches in my poverty,\nthy glory in my valley.\n\nAmen.",
            category: .theologians
        ),
        Prayer(
            title: "Prayer of Adoration",
            author: "Jonathan Edwards",
            text: "O God, thou art infinitely great and glorious.\nThy majesty fills all of creation.\nThe heavens declare thy glory,\nand the earth shows thy handiwork.\n\nMy soul is lost in wonder\nat the immensity of thy being.\nI am but dust, yet thou hast loved me.\nI am but a vapor, yet thou hast called me by name.\n\nOpen my eyes to behold thy beauty.\nSoften my heart to receive thy love.\nStrengthen my will to walk in thy ways.\n\nLet everything that has breath praise the Lord.\nAnd let my breath be the first.\n\nAmen.",
            category: .theologians
        ),

        // MARK: - Reformer Prayers
        Prayer(
            title: "A Mighty Fortress Prayer",
            author: "Martin Luther",
            text: "Lord God, you are my mighty fortress.\nYou are my refuge and my strength,\na very present help in trouble.\n\nThough the earth gives way,\nthough the mountains fall into the sea,\nI will not fear,\nfor you are with me.\n\nThe Lord Almighty is with us;\nthe God of Jacob is our fortress.\n\nStand with me this day, O Lord.\nFight my battles.\nCalm my fears.\nLet your Word be a lamp to my feet\nand a light to my path.\n\nHere I stand. I can do no other.\nGod help me.\n\nAmen.",
            category: .reformers
        ),
        Prayer(
            title: "Prayer for God's Help",
            author: "John Wesley",
            text: "O God, let me not turn coward\nbefore the difficulties of the day,\nor prove faithless to its duties.\n\nLet me not lose faith in other people.\nKeep me sweet and sound of heart,\nin spite of ingratitude, treachery, or meanness.\n\nPreserve me from minding little stings\nor giving them.\n\nHelp me to keep my heart clean,\nand to live so honestly and fearlessly\nthat no outward failure can dishearten me\nor take away the joy of conscious integrity.\n\nOpen wide the eyes of my soul\nthat I may see good in all things.\n\nGrant me this day some new vision\nof thy truth, some new experience of thy grace.\n\nAmen.",
            category: .reformers
        ),
        Prayer(
            title: "Prayer of Commitment",
            author: "John Knox",
            text: "Lord, give me Scotland, or I die!\n\nO God of mercy,\nset a fire in my heart for your people.\nLet me not rest while souls are lost.\nLet me not be comfortable\nwhile the gospel is not preached.\n\nGive me a burden for the nations.\nGive me tears for the lost.\nGive me words for the searching.\nGive me courage for the battle.\n\nI surrender my comfort,\nmy reputation,\nmy very life\nfor the advance of your kingdom.\n\nUse me, Lord, or use me up.\n\nAmen.",
            category: .reformers
        ),

        // MARK: - Morning Prayers
        Prayer(
            title: "A Morning Offering",
            author: "St. Ignatius of Loyola",
            text: "Lord, I give you my hands to do your work.\nI give you my feet to go your way.\nI give you my eyes to see as you do.\nI give you my tongue to speak your words.\nI give you my mind that you may think in me.\nI give you my spirit that you may pray in me.\n\nAbove all, I give you my heart\nthat you may love in me your Father\nand all mankind.\nI give you my whole self\nthat you may grow in me,\nso that it is you, Lord Jesus,\nwho live and work and pray in me.\n\nAmen.",
            category: .morning
        ),
        Prayer(
            title: "New Day Prayer",
            author: "Traditional",
            text: "Lord, thank you for a new day.\nBefore my feet touch the ground,\nI declare that you are good.\n\nBefore the world speaks to me,\nI listen for your voice.\nBefore my phone lights up with notifications,\nI turn my face to your light.\n\nThis day is yours.\nMy time is yours.\nMy heart is yours.\n\nOrder my steps.\nGuard my mouth.\nFill my mind with things above.\n\nLet me live this day\nas if it were the only one I have.\n\nIn Jesus' name, Amen.",
            category: .morning
        ),

        // MARK: - Evening Prayers
        Prayer(
            title: "Evening Rest",
            author: "Book of Common Prayer",
            text: "Lighten our darkness, we beseech thee, O Lord;\nand by thy great mercy defend us\nfrom all perils and dangers of this night;\nfor the love of thy only Son,\nour Savior Jesus Christ.\n\nVisit, we beseech thee, O Lord, this habitation,\nand drive far from it all snares of the enemy;\nlet thy holy angels dwell herein\nto preserve us in peace;\nand let thy blessing be upon us,\nthrough Jesus Christ our Lord.\n\nAmen.",
            category: .evening
        ),
        Prayer(
            title: "Night Prayer of Surrender",
            author: "Traditional",
            text: "Lord, as this day ends,\nI lay down my burdens at your feet.\n\nThe worries I carried — I give them to you.\nThe mistakes I made — I confess them to you.\nThe victories I saw — I give you the glory.\n\nWatch over me as I sleep.\nGuard my mind from anxious thoughts.\nLet your peace cover me like a blanket.\n\nAnd when morning comes,\nlet the first word on my lips\nbe your name.\n\nAmen.",
            category: .evening
        ),

        // MARK: - Peace & Rest
        Prayer(
            title: "Prayer for Peace",
            author: "St. Francis of Assisi",
            text: "Lord, make me an instrument of your peace:\nwhere there is hatred, let me sow love;\nwhere there is injury, pardon;\nwhere there is doubt, faith;\nwhere there is despair, hope;\nwhere there is darkness, light;\nwhere there is sadness, joy.\n\nO divine Master, grant that I may not so much seek\nto be consoled as to console,\nto be understood as to understand,\nto be loved as to love.\nFor it is in giving that we receive,\nit is in pardoning that we are pardoned,\nand it is in dying that we are born to eternal life.\n\nAmen.",
            category: .peace
        ),
        Prayer(
            title: "Prayer for Anxiety",
            author: "Based on Philippians 4:6-7",
            text: "Father, your Word says:\nDo not be anxious about anything,\nbut in every situation, by prayer and petition,\nwith thanksgiving, present your requests to God.\n\nAnd the peace of God,\nwhich transcends all understanding,\nwill guard your hearts and your minds\nin Christ Jesus.\n\nSo right now, I bring my anxiety to you.\nI name it. I release it. I trust you with it.\n\nGuard my heart, Lord.\nGuard my mind.\nReplace my worry with worship.\nReplace my fear with faith.\n\nYour peace is enough.\n\nAmen.",
            category: .peace
        ),

        // MARK: - Provision
        Prayer(
            title: "Prayer of Provision",
            author: "George Müller",
            text: "Father, you know my needs before I speak them.\nYou clothe the lilies and feed the sparrows,\nand you have promised to care for me.\n\nI bring my needs to you this morning —\nnot with anxiety, but with trust.\nNot with demand, but with dependence.\n\nProvide for me today, Lord.\nNot just bread for my body,\nbut nourishment for my soul.\nNot just resources for my plans,\nbut wisdom for your purposes.\n\nI will trust you in abundance.\nI will trust you in scarcity.\nFor you are faithful in all seasons.\n\nAmen.",
            category: .provision
        ),

        // MARK: - Gratitude
        Prayer(
            title: "A Heart of Gratitude",
            author: "Traditional",
            text: "Gracious God, I pause this morning to give thanks.\n\nThank you for the gift of breath.\nThank you for the mercy of a new day.\nThank you for the people you have placed in my life.\nThank you for your Word that guides my steps.\nThank you for your Spirit that comforts my soul.\n\nWhen I am tempted to complain,\nremind me of your goodness.\nWhen I am tempted to worry,\nremind me of your faithfulness.\n\nLet gratitude be the lens\nthrough which I see this entire day.\n\nIn Jesus' name, Amen.",
            category: .gratitude
        ),
        Prayer(
            title: "Psalm of Thanksgiving",
            author: "Based on Psalm 103",
            text: "Praise the Lord, O my soul;\nall my inmost being, praise his holy name.\n\nPraise the Lord, O my soul,\nand forget not all his benefits —\nwho forgives all your sins\nand heals all your diseases,\nwho redeems your life from the pit\nand crowns you with love and compassion,\nwho satisfies your desires with good things\nso that your youth is renewed like the eagle's.\n\nThe Lord is compassionate and gracious,\nslow to anger, abounding in love.\nAs a father has compassion on his children,\nso the Lord has compassion on those who fear him.\n\nFrom everlasting to everlasting\nthe Lord's love is with those who fear him.\n\nPraise the Lord, O my soul!\n\nAmen.",
            category: .gratitude
        ),

        // MARK: - Repentance
        Prayer(
            title: "Prayer of Confession",
            author: "Book of Common Prayer",
            text: "Most merciful God,\nI confess that I have sinned against you\nin thought, word, and deed,\nby what I have done,\nand by what I have left undone.\n\nI have not loved you with my whole heart;\nI have not loved my neighbors as myself.\n\nI am truly sorry and I humbly repent.\nFor the sake of your Son Jesus Christ,\nhave mercy on me and forgive me;\nthat I may delight in your will,\nand walk in your ways,\nto the glory of your name.\n\nAmen.",
            category: .repentance
        ),
        Prayer(
            title: "A Contrite Heart",
            author: "Based on Psalm 32",
            text: "Blessed is the one whose transgressions are forgiven,\nwhose sins are covered.\n\nLord, when I kept silent,\nmy bones wasted away\nthrough my groaning all day long.\n\nThen I acknowledged my sin to you\nand did not cover up my iniquity.\nI said, \"I will confess my transgressions to the Lord\" —\nand you forgave the guilt of my sin.\n\nYou are my hiding place;\nyou will protect me from trouble\nand surround me with songs of deliverance.\n\nI will instruct you and teach you\nin the way you should go;\nI will counsel you with my loving eye on you.\n\nRejoice in the Lord and be glad, you righteous;\nsing, all you who are upright in heart!\n\nAmen.",
            category: .repentance
        ),

        // MARK: - Spiritual Warfare
        Prayer(
            title: "The Armor of God",
            author: "Based on Ephesians 6:10-18",
            text: "Lord, I put on your full armor today.\n\nI fasten the belt of truth around my waist.\nI put on the breastplate of righteousness.\nI fit my feet with the readiness\nthat comes from the gospel of peace.\n\nI take up the shield of faith,\nwith which I can extinguish\nall the flaming arrows of the evil one.\n\nI take the helmet of salvation\nand the sword of the Spirit,\nwhich is the Word of God.\n\nAnd I pray in the Spirit\non all occasions\nwith all kinds of prayers and requests.\n\nI stand firm today, Lord.\nNot in my own strength,\nbut in your mighty power.\n\nAmen.",
            category: .spiritual
        ),
        Prayer(
            title: "Prayer of Protection",
            author: "Based on Psalm 91",
            text: "He who dwells in the shelter of the Most High\nwill rest in the shadow of the Almighty.\n\nI will say of the Lord,\n\"He is my refuge and my fortress,\nmy God, in whom I trust.\"\n\nHe will cover me with his feathers,\nand under his wings I will find refuge;\nhis faithfulness will be my shield and rampart.\n\nI will not fear the terror of night,\nnor the arrow that flies by day.\n\nA thousand may fall at my side,\nten thousand at my right hand,\nbut it will not come near me.\n\nFor he will command his angels concerning me\nto guard me in all my ways.\n\nBecause he loves me, says the Lord,\nI will rescue him;\nI will protect him,\nfor he acknowledges my name.\n\nAmen.",
            category: .spiritual
        ),
    ]

    static func prayers(for category: PrayerCategory) -> [Prayer] {
        prayers.filter { $0.category == category }
    }
}
