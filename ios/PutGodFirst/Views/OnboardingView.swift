import SwiftUI
import FamilyControls
import RevenueCat

struct OnboardingView: View {
    @Bindable var viewModel: AppViewModel
    @State private var currentPage: Int = 0
    @State private var nameInput: String = ""
    @State private var phoneHabit: String = ""
    @State private var prayerConfidence: Double = 0.3
    @State private var selectedMinutes: Int = 5
    @State private var journeyDotsLoaded: Int = 0
    @State private var showTrialSession: Bool = false
    @State private var trialCompleted: Bool = false
    @State private var reflectionText: String = ""
    @State private var selectedPlan: PaywallPlan = .yearly
    @State private var showAppPicker: Bool = false
    @State private var isPurchasing: Bool = false
    @State private var isRestoringPurchases: Bool = false
    @State private var isPurchasingLifetime: Bool = false
    @State private var purchaseError: String = ""
    @State private var showPurchaseError: Bool = false
    @State private var familyControlsAuthorized: Bool = false
    @State private var onboardingActivitySelection: FamilyActivitySelection = ScreenTimeService.shared.activitySelection
    @State private var selectedDenomination: String = ""
    @State private var selectedGoals: Set<String> = []
    @State private var signatureLines: [[CGPoint]] = []
    @State private var currentSignatureLine: [CGPoint] = []

    @State private var showAuthError: Bool = false

    @State private var textReveal: [Bool] = Array(repeating: false, count: 8)
    @State private var statsRevealed: Int = 0
    @State private var statCounters: [Double] = Array(repeating: 0, count: 8)
    @State private var brainStatsRevealed: Int = 0
    @State private var brainStatCounters: [Double] = Array(repeating: 0, count: 6)
    @State private var pageAppear: Bool = false
    @State private var sunriseGlow: Bool = false
    @State private var raysRotating: Bool = false
    @State private var encounterDarkness: Double = 1.0
    @State private var encounterGlow: Bool = false
    @State private var encounterRays: Bool = false
    @State private var lightBurst: Bool = false
    @State private var particleFloat: [Bool] = Array(repeating: false, count: 12)
    @State private var crossScale: CGFloat = 0
    @State private var crossOpacity: Double = 0
    @State private var crossInnerGlow: Bool = false
    @State private var ringScales: [CGFloat] = Array(repeating: 0.3, count: 4)
    @State private var ringOpacities: [Double] = Array(repeating: 0, count: 4)
    @State private var verticalBeam: Bool = false
    @State private var horizontalBeam: Bool = false
    @State private var ambientPulse: Bool = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var bgPulsePhase: Bool = false
    @State private var textGlowPulse: Bool = false
    @State private var dayPathRevealed: Int = 0
    @State private var pathGlowPulse: Bool = false
    @State private var cloudDrift1: CGFloat = 0
    @State private var cloudDrift2: CGFloat = 0
    @State private var cloudDrift3: CGFloat = 0
    @State private var blockerAppsRevealed: Int = 0
    @State private var blockerShieldAppear: Bool = false
    @State private var blockerStrikethrough: [Bool] = Array(repeating: false, count: 6)
    @State private var blockerCardsShake: Bool = false
    @State private var blockerScanLine: CGFloat = -200
    @State private var blockerScanVisible: Bool = false
    @State private var blockerShieldPulse: Bool = false
    @State private var blockerShieldRays: Bool = false
    @State private var blockerCardsShrink: Bool = false
    @State private var blockerParticles: [Bool] = Array(repeating: false, count: 10)
    @State private var blockerGlowPulse: Bool = false
    @State private var blockerVortex: Bool = false
    @State private var warmOrbsFloat: [Bool] = Array(repeating: false, count: 8)
    @State private var warmPulse: Bool = false
    @State private var warmIconGlow: Bool = false
    @State private var selectedPhoneHours: Int = 0
    @State private var readyToTradeAnswer: String = ""
    @State private var buildProgressValues: [Double] = [0, 0, 0, 0]
    @State private var buildProgressRevealed: Int = 0
    @State private var buildComplete: Bool = false
    @State private var graphAnimProgress: Double = 0
    @State private var chartGlowPulse: Bool = false
    @State private var chartLabelScale: CGFloat = 0
    @State private var growthPhase: Int = 0
    @State private var growthCenterScale: CGFloat = 0
    @State private var statsCountUpHours: Double = 0
    @State private var statsCountUpDays: Double = 0
    @State private var statsCountUpYears: Double = 0
    @State private var statsCountUpLifetimeDays: Double = 0
    @State private var statsCountUpBooks: Double = 0
    @State private var loadingSpinning: Bool = false

    @State private var bellSwing: Double = 0
    @State private var bellScale: CGFloat = 0
    @State private var bellGlowPulse: Bool = false
    @State private var bellRingPhase: Int = 0
    @State private var bellRipples: [Bool] = Array(repeating: false, count: 4)
    @State private var bellSparkles: [Bool] = Array(repeating: false, count: 8)
    @State private var bellClapperSwing: Double = 0
    @State private var bellShimmer: CGFloat = -1.0
    @State private var bellFloatOffset: CGFloat = 0

    @State private var visionPhase: Int = 0
    @State private var visionBeforeItems: [Bool] = Array(repeating: false, count: 3)
    @State private var visionAfterItems: [Bool] = Array(repeating: false, count: 3)
    @State private var visionLightBurst: Bool = false
    @State private var visionDarkBg: Double = 1.0
    @State private var visionWarmBg: Double = 0.0
    @State private var visionBeforeShake: Bool = false
    @State private var visionBeforeFade: Double = 1.0
    @State private var visionAfterGlow: Bool = false
    @State private var visionSunrise: CGFloat = 0
    @State private var visionRaysRotation: Double = 0
    @State private var visionRaysVisible: Bool = false
    @State private var visionParticles: [Bool] = Array(repeating: false, count: 8)
    @State private var visionFlipProgress: Double = 0
    @State private var visionScreenCrack: Bool = false
    @State private var visionPhoneScale: CGFloat = 1.0
    @State private var visionPhoneOffset: CGFloat = 0

    @State private var trialOrbScale: CGFloat = 0.3
    @State private var trialOrbGlow: Bool = false
    @State private var trialRaysRotation: Double = 0
    @State private var trialRaysVisible: Bool = false
    @State private var trialParticles: [Bool] = Array(repeating: false, count: 10)
    @State private var trialPulseRing1: CGFloat = 0.6
    @State private var trialPulseRing2: CGFloat = 0.5
    @State private var trialPulseRing3: CGFloat = 0.4
    @State private var trialRingOpacity1: Double = 0
    @State private var trialRingOpacity2: Double = 0
    @State private var trialRingOpacity3: Double = 0
    @State private var trialIconFloat: CGFloat = 0
    @State private var trialShimmer: CGFloat = -1.0
    @State private var trialDoveReveal: Bool = false
    @State private var trialLightBurst: Bool = false
    @State private var trialEmberPhase: Bool = false
    @State private var trialHaloBreath: Bool = false
    @State private var trialRipple1: CGFloat = 0.3
    @State private var trialRipple2: CGFloat = 0.3
    @State private var trialRipple3: CGFloat = 0.3
    @State private var trialRippleOp1: Double = 0
    @State private var trialRippleOp2: Double = 0
    @State private var trialRippleOp3: Double = 0
    @State private var trialButtonShimmer: CGFloat = -0.5
    @State private var sessionConfetti: Bool = false

    @State private var communityCounter: Double = 0
    @State private var communityAvatarsRevealed: Int = 0
    @State private var communityOrbitAngle: Double = 0
    @State private var communityInnerOrbit: Double = 0
    @State private var communityPulse: Bool = false
    @State private var communityGlowBurst: Bool = false
    @State private var communityConnectionPulse: Bool = false
    @State private var communityFloatPhase: [Bool] = Array(repeating: false, count: 12)
    @State private var communitySparkles: [Bool] = Array(repeating: false, count: 8)
    @State private var communityRingScale: CGFloat = 0.3
    @State private var communityRingOpacity: Double = 0
    @State private var communityCenterGlow: Bool = false

    @State private var fairTrialDoveFloat: CGFloat = 0
    @State private var fairTrialGlowPulse: Bool = false
    @State private var fairTrialVsPulse: Bool = false
    @State private var fairTrialParticlePhase: [Bool] = Array(repeating: false, count: 6)
    @State private var commitmentGlowPulse: Bool = false
    @State private var commitmentBulletReveal: [Bool] = Array(repeating: false, count: 4)
    @State private var commitmentSignatureGlow: Bool = false
    @State private var commitmentCheckmarkShown: Bool = false

    @State private var habitsFloatingOrbs: [Bool] = Array(repeating: false, count: 10)
    @State private var habitsNodeRipple: [CGFloat] = Array(repeating: 0.4, count: 5)
    @State private var habitsNodeRippleOp: [Double] = Array(repeating: 0, count: 5)
    @State private var habitsLineProgress: [CGFloat] = Array(repeating: 0, count: 4)
    @State private var habitsTitleShimmer: CGFloat = -1.0
    @State private var habitsCardShimmer: CGFloat = -200
    @State private var habitsCrownDrop: Bool = false
    @State private var habitsStarBurst: [Bool] = Array(repeating: false, count: 4)

    private let totalPages: Int = 30

    enum PaywallPlan: String { case weekly, yearly }

    private var subscriptionService: SubscriptionService { SubscriptionService.shared }

    private var currentOffering: Offering? {
        subscriptionService.offerings?.current
    }

    private var annualPackage: Package? {
        currentOffering?.annual ?? currentOffering?.availablePackages.first { $0.packageType == .annual }
    }

    private var weeklyPackage: Package? {
        currentOffering?.weekly ?? currentOffering?.availablePackages.first { $0.packageType == .weekly }
    }

    private var selectedPackage: Package? {
        selectedPlan == .yearly ? annualPackage : weeklyPackage
    }

    private var annualPriceString: String {
        annualPackage?.storeProduct.localizedPriceString ?? "$59.99"
    }

    private var weeklyPriceString: String {
        weeklyPackage?.storeProduct.localizedPriceString ?? "$3.99"
    }

    private var annualPerWeekString: String {
        if let pkg = annualPackage {
            let price = pkg.storeProduct.price as Decimal
            let weekly = price / 52
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = pkg.storeProduct.priceFormatter?.locale ?? .current
            return formatter.string(from: weekly as NSDecimalNumber) ?? "$1.15"
        }
        return "$1.15"
    }

    private var trialText: String {
        if let pkg = selectedPackage, let intro = pkg.storeProduct.introductoryDiscount {
            let val = intro.subscriptionPeriod.value
            switch intro.subscriptionPeriod.unit {
            case .day: return "\(val)-day free trial"
            case .week: return "\(val)-week free trial"
            case .month: return "\(val)-month free trial"
            default: return "Free trial"
            }
        }
        return "3-day free trial"
    }

    private var selectedPriceLabel: String {
        selectedPlan == .yearly ? "\(annualPriceString)/year" : "\(weeklyPriceString)/week"
    }

    private var yearlyHours: Int {
        (selectedMinutes * 365) / 60
    }

    private var yearlyPhoneHours: Int {
        (selectedPhoneHours > 0 ? selectedPhoneHours : 5) * 365
    }

    private var phoneStatsDays: Int {
        yearlyPhoneHours / 24
    }

    private var phoneStatsLifetimeYears: Int {
        Int(Double(yearlyPhoneHours) * 50.0 / 8760.0)
    }

    private var phoneStatsLifetimeDays: Int {
        phoneStatsLifetimeYears * 365
    }

    private var phoneStatsMissedBooks: Int {
        yearlyPhoneHours / 6
    }

    var body: some View {
        ZStack {
            warmOnboardingBg

            if showTrialSession {
                TrialSessionView(
                    userName: nameInput.isEmpty ? "Friend" : nameInput,
                    selectedMinutes: selectedMinutes,
                    prayerConfidence: prayerConfidence,
                    phoneHabit: phoneHabit,
                    onComplete: {
                        trialCompleted = true
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showTrialSession = false
                            currentPage = 23
                        }
                    }
                )
            } else {
                pageContent
                    .id(currentPage)
                    .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch currentPage {
        case 0: welcomePage
        case 1: namePage
        case 2: denominationPage
        case 3: spiritualGoalsPage
        case 4: visionPage
        case 5: whatDoesItDoPage
        case 6: habitPage
        case 7: phoneHoursPage
        case 8: phoneStatsPage
        case 9: brainSciencePage
        case 10: hardwiredPage
        case 11: confidencePage
        case 12: timePage
        case 13: buyInPage
        case 14: bibleStatsPage
        case 15: bibleReadingQuizPage
        case 16: memorizeScripturePage
        case 17: scriptureUnlockFeaturesPage
        case 18: creatingBibleModePage
        case 19: communityPage
        case 20: socialBlockerPage
        case 21: familyControlsPage
        case 22: trialInvitePage
        case 23: sessionEndPage
        case 24: transformationPage
        case 25: lastingHabitsPage
        case 26: fairTrialPolicyPage
        case 27: commitmentSignaturePage
        case 28: notificationPage
        case 29: pricingPage
        default: EmptyView()
        }
    }

    // MARK: - Screen 0: Welcome

    private let accentBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    private let accentBlueBright = Color(red: 0.35, green: 0.7, blue: 1.0)

    private let sunriseGold = Color(red: 1.0, green: 0.82, blue: 0.42)
    private let sunrisePeach = Color(red: 1.0, green: 0.62, blue: 0.38)
    private let sunriseRose = Color(red: 0.92, green: 0.48, blue: 0.45)
    private let horizonWarm = Color(red: 1.0, green: 0.68, blue: 0.28)
    private let dawnCream = Color(red: 1.0, green: 0.92, blue: 0.78)
    private let deepIndigo = Color(red: 0.04, green: 0.02, blue: 0.14)
    private let nightViolet = Color(red: 0.08, green: 0.03, blue: 0.22)
    private let twilightBlue = Color(red: 0.1, green: 0.08, blue: 0.32)

    @State private var grassSway: Bool = false
    @State private var flowersBloom: Bool = false
    @State private var flowerPulse: Bool = false
    @State private var grassVisible: Double = 0

    @State private var starsVisible: Bool = false
    @State private var starTwinkle: [Bool] = Array(repeating: false, count: 20)
    @State private var welcomeShootProgress: [CGFloat] = Array(repeating: 0, count: 8)
    @State private var welcomeShootOpacity: [Double] = Array(repeating: 0, count: 8)
    @State private var crossFlashOpacity: Double = 0
    @State private var sunOrb: CGFloat = 0
    @State private var horizonGlowIntensity: Double = 0
    @State private var warmthSpread: Bool = false
    @State private var crossRiseProgress: CGFloat = 0
    @State private var skyAwakening: Double = 0
    @State private var horizonBand: Double = 0
    @State private var nightFade: Double = 1.0
    @State private var dawnBreaking: Double = 0
    @State private var goldenHour: Double = 0
    @State private var cloudsLit: Double = 0
    @State private var atmosphereWarmth: Double = 0

    private var welcomePage: some View {
        GeometryReader { geo in
            let screenH = geo.size.height
            let screenW = geo.size.width
            let horizonY: CGFloat = screenH * 0.48
            let crossRestY: CGFloat = horizonY - 100
            let crossStartY: CGFloat = horizonY + 140

            ZStack {
                Color.black.ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.02, blue: 0.18).interpolated(to: Color(red: 0.12, green: 0.08, blue: 0.42), amount: skyAwakening * 0.9),
                        Color(red: 0.08, green: 0.03, blue: 0.22).interpolated(to: Color(red: 0.16, green: 0.12, blue: 0.52), amount: skyAwakening * 0.88),
                        Color(red: 0.06, green: 0.02, blue: 0.2).interpolated(to: Color(red: 0.14, green: 0.16, blue: 0.55), amount: skyAwakening * 0.92),
                        Color(red: 0.04, green: 0.02, blue: 0.14).interpolated(to: Color(red: 0.1, green: 0.22, blue: 0.62), amount: skyAwakening * 0.94),
                        Color(red: 0.03, green: 0.01, blue: 0.1).interpolated(to: Color(red: 0.15, green: 0.35, blue: 0.75), amount: skyAwakening * 0.93),
                        Color(red: 0.02, green: 0.01, blue: 0.08).interpolated(to: Color(red: 0.25, green: 0.5, blue: 0.88), amount: skyAwakening * 0.9),
                        Color(red: 0.35, green: 0.55, blue: 0.92).opacity(dawnBreaking * 0.72),
                        Color(red: 0.48, green: 0.65, blue: 0.92).opacity(dawnBreaking * 0.55),
                        sunrisePeach.opacity(dawnBreaking * 0.3),
                        horizonWarm.opacity(goldenHour * 0.45),
                        sunriseGold.opacity(goldenHour * 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(skyAwakening)

                RadialGradient(
                    colors: [
                        sunriseGold.opacity(horizonBand * 0.6),
                        horizonWarm.opacity(horizonBand * 0.38),
                        sunrisePeach.opacity(horizonBand * 0.18),
                        sunriseRose.opacity(horizonBand * 0.06),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: horizonY / screenH),
                    startRadius: 0,
                    endRadius: horizonBand > 0 ? 380 : 30
                )
                .ignoresSafeArea()

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                dawnCream.opacity(horizonGlowIntensity * 0.7),
                                sunriseGold.opacity(horizonGlowIntensity * 0.5),
                                horizonWarm.opacity(horizonGlowIntensity * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 350
                        )
                    )
                    .frame(width: 620, height: 190)
                    .position(x: screenW / 2, y: horizonY + 20)
                    .blur(radius: 50)

                RadialGradient(
                    colors: [
                        dawnCream.opacity(lightBurst ? 0.25 : 0),
                        sunriseGold.opacity(lightBurst ? 0.18 : 0),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: (crossRestY - 20) / screenH),
                    startRadius: 0,
                    endRadius: lightBurst ? 500 : 30
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        sunriseGold.opacity(bgPulsePhase ? 0.06 : 0.01),
                        dawnCream.opacity(bgPulsePhase ? 0.04 : 0.005),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: (crossRestY - 20) / screenH),
                    startRadius: 80,
                    endRadius: 450
                )
                .ignoresSafeArea()

                ForEach(0..<20, id: \.self) { i in
                    let starX: [CGFloat] = [0.12, 0.88, 0.35, 0.72, 0.18, 0.55, 0.92, 0.08, 0.45, 0.78, 0.28, 0.62, 0.05, 0.95, 0.42, 0.68, 0.15, 0.82, 0.52, 0.38]
                    let starY: [CGFloat] = [0.05, 0.03, 0.1, 0.07, 0.15, 0.02, 0.12, 0.19, 0.06, 0.14, 0.22, 0.09, 0.18, 0.04, 0.13, 0.02, 0.25, 0.1, 0.17, 0.23]
                    let starSize: [CGFloat] = [2, 1.5, 2.5, 1, 3, 2, 1.5, 2, 1, 2.5, 1.5, 3, 1, 2, 2.5, 1.5, 1, 2, 3, 1.5]

                    Circle()
                        .fill(Color.white)
                        .frame(width: starSize[i], height: starSize[i])
                        .position(
                            x: screenW * starX[i],
                            y: screenH * starY[i]
                        )
                        .opacity(starsVisible ? (starTwinkle[i] ? 0.9 : 0.35) * nightFade : 0)
                        .blur(radius: starSize[i] > 2 ? 0.5 : 0)
                }

                let shootPaths: [(sx: CGFloat, sy: CGFloat, ex: CGFloat, ey: CGFloat, sz: CGFloat)] = [
                    (0.05, 0.04, 0.52, 0.20, 2.5), (0.92, 0.03, 0.38, 0.18, 3),
                    (0.28, 0.01, 0.75, 0.15, 2), (0.72, 0.02, 0.18, 0.24, 3.5),
                    (0.15, 0.07, 0.65, 0.28, 2), (0.82, 0.05, 0.32, 0.22, 2.5),
                    (0.42, 0.01, 0.88, 0.13, 2), (0.58, 0.06, 0.12, 0.30, 3),
                ]
                ForEach(0..<8, id: \.self) { si in
                    let sd = shootPaths[si]
                    let sp = welcomeShootProgress[si]
                    let cx = sd.sx + (sd.ex - sd.sx) * sp
                    let cy = sd.sy + (sd.ey - sd.sy) * sp
                    ZStack {
                        ForEach(0..<6, id: \.self) { t in
                            let tp = max(0, sp - CGFloat(t) * 0.04)
                            let tx = sd.sx + (sd.ex - sd.sx) * tp
                            let ty = sd.sy + (sd.ey - sd.sy) * tp
                            Circle()
                                .fill(Color.white.opacity(Double(6 - t) / 10.0))
                                .frame(width: sd.sz * CGFloat(6 - t) / 6.0)
                                .position(x: screenW * tx, y: screenH * ty)
                        }
                        Circle()
                            .fill(.white)
                            .frame(width: sd.sz + 1)
                            .shadow(color: sunriseGold.opacity(0.7), radius: 8)
                            .shadow(color: .white, radius: 4)
                            .position(x: screenW * cx, y: screenH * cy)
                    }
                    .opacity(welcomeShootOpacity[si])
                }

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                dawnCream.opacity(0.5),
                                sunriseGold.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .center,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3, height: verticalBeam ? 700 : 0)
                    .position(x: screenW / 2, y: crossRestY - 350)
                    .blur(radius: 14)
                    .opacity(verticalBeam ? 0.5 : 0)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                sunriseGold.opacity(0.35),
                                dawnCream.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .center,
                            endPoint: .leading
                        )
                    )
                    .frame(width: horizontalBeam ? 600 : 0, height: 2)
                    .position(x: screenW / 2, y: crossRestY - 40)
                    .blur(radius: 12)
                    .opacity(horizontalBeam ? 0.4 : 0)

                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    dawnCream.opacity(0.5),
                                    sunriseGold.opacity(0.35),
                                    horizonWarm.opacity(0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: CGFloat(3 - i)
                        )
                        .frame(
                            width: 100 + CGFloat(i) * 80,
                            height: 100 + CGFloat(i) * 80
                        )
                        .scaleEffect(ringScales[i])
                        .opacity(ringOpacities[i])
                        .blur(radius: CGFloat(i) * 2.5 + 1)
                        .position(x: screenW / 2, y: crossRestY - 20)
                }

                let cloudBase = horizonY + 10

                ZStack {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    sunriseGold.opacity(cloudsLit * 0.8),
                                    horizonWarm.opacity(cloudsLit * 0.55),
                                    sunrisePeach.opacity(cloudsLit * 0.25),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.5, y: 0.2),
                                startRadius: 0,
                                endRadius: 280
                            )
                        )
                        .frame(width: screenW * 1.6, height: 240)
                        .position(x: screenW / 2, y: cloudBase + 30)
                        .blur(radius: 35)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    dawnCream.opacity(cloudsLit * 0.55),
                                    sunriseGold.opacity(cloudsLit * 0.4),
                                    Color.white.opacity(cloudsLit * 0.2)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: screenW * 1.4, height: 100)
                        .blur(radius: 4)
                        .position(x: screenW * 0.5 + cloudDrift1, y: cloudBase + 25)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    sunriseGold.opacity(cloudsLit * 0.4),
                                    Color.white.opacity(cloudsLit * 0.2)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: screenW * 1.1, height: 75)
                        .blur(radius: 6)
                        .position(x: screenW * 0.55 + cloudDrift2, y: cloudBase + 50)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    sunriseGold.opacity(cloudsLit * 0.45),
                                    horizonWarm.opacity(cloudsLit * 0.3),
                                    sunrisePeach.opacity(cloudsLit * 0.15)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 360, height: 70)
                        .blur(radius: 3)
                        .position(x: screenW * 0.45 + cloudDrift3, y: cloudBase)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    dawnCream.opacity(cloudsLit * 0.4),
                                    sunrisePeach.opacity(cloudsLit * 0.2)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 300, height: 60)
                        .blur(radius: 3)
                        .position(x: screenW * 0.2 + cloudDrift2 * 0.7, y: cloudBase + 15)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    horizonWarm.opacity(cloudsLit * 0.35),
                                    sunriseGold.opacity(cloudsLit * 0.2)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 280, height: 55)
                        .blur(radius: 3)
                        .position(x: screenW * 0.8 + cloudDrift1 * 0.6, y: cloudBase + 10)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    dawnCream.opacity(cloudsLit * 0.3),
                                    Color.white.opacity(cloudsLit * 0.15)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 220, height: 50)
                        .blur(radius: 4)
                        .position(x: screenW * 0.35 + cloudDrift3 * 0.8, y: cloudBase - 15)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    dawnCream.opacity(cloudsLit * 0.45),
                                    sunriseGold.opacity(cloudsLit * 0.3)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: screenW * 1.3, height: 90)
                        .blur(radius: 6)
                        .position(x: screenW * 0.5 + cloudDrift3 * 0.4, y: cloudBase + 65)

                    CloudShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    sunriseGold.opacity(cloudsLit * 0.35),
                                    horizonWarm.opacity(cloudsLit * 0.2)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: screenW, height: 70)
                        .blur(radius: 5)
                        .position(x: screenW * 0.5 + cloudDrift1 * 0.3, y: cloudBase + 85)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    horizonWarm.opacity(atmosphereWarmth * 0.3),
                                    sunriseGold.opacity(atmosphereWarmth * 0.4),
                                    sunrisePeach.opacity(atmosphereWarmth * 0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: screenW, height: screenH * 0.35)
                        .position(x: screenW / 2, y: screenH - screenH * 0.175)
                        .blur(radius: 20)
                }

                VStack(spacing: 0) {
                    Spacer()
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(red: 0.08, green: 0.22, blue: 0.06).opacity(grassVisible * 0.15),
                            Color(red: 0.1, green: 0.28, blue: 0.08).opacity(grassVisible * 0.28),
                            Color(red: 0.08, green: 0.24, blue: 0.06).opacity(grassVisible * 0.38),
                            Color(red: 0.06, green: 0.2, blue: 0.05).opacity(grassVisible * 0.42)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: screenH * 0.35)
                    .blur(radius: 30)
                }
                .ignoresSafeArea()

                let currentCrossY = crossStartY + (crossRestY - crossStartY) * crossRiseProgress

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    sunriseGold.opacity(encounterGlow ? 0.3 : 0),
                                    dawnCream.opacity(encounterGlow ? 0.18 : 0),
                                    horizonWarm.opacity(encounterGlow ? 0.1 : 0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: encounterGlow ? 280 : 25
                            )
                        )
                        .frame(width: 560, height: 560)
                        .scaleEffect(ambientPulse ? 1.08 : 1.0)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    dawnCream.opacity(encounterGlow ? 0.25 : 0),
                                    sunriseGold.opacity(encounterGlow ? 0.12 : 0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 160
                            )
                        )
                        .frame(width: 320, height: 320)
                        .scaleEffect(ambientPulse ? 0.93 : 1.07)

                    LuminousCrossShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white,
                                    dawnCream,
                                    sunriseGold
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 95, height: 120)
                        .shadow(color: .white.opacity(0.95), radius: 10, y: -3)
                        .shadow(color: dawnCream.opacity(0.8), radius: 5, y: -1)
                        .shadow(color: sunriseGold.opacity(crossInnerGlow ? 0.7 : 0.25), radius: 35, y: 0)
                        .shadow(color: horizonWarm.opacity(crossInnerGlow ? 0.5 : 0.15), radius: 60, y: 0)
                        .shadow(color: sunriseGold.opacity(0.6), radius: 25, y: 0)
                        .shadow(color: horizonWarm.opacity(0.4), radius: 50, y: 0)
                        .shadow(color: sunriseGold.opacity(crossInnerGlow ? 0.8 : 0.3), radius: 20, y: 0)
                        .shadow(color: .white.opacity(0.5), radius: 4, y: 1)
                        .scaleEffect(crossScale)
                        .opacity(crossOpacity)

                    LuminousCrossShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    sunriseGold.opacity(crossInnerGlow ? 0.4 : 0.1),
                                    horizonWarm.opacity(crossInnerGlow ? 0.25 : 0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 95, height: 120)
                        .blur(radius: 30)
                        .scaleEffect(crossScale * 1.5)
                        .opacity(crossOpacity * 0.7)

                    LuminousCrossShape()
                        .fill(
                            LinearGradient(
                                colors: [
                                    dawnCream.opacity(crossInnerGlow ? 0.55 : 0.15),
                                    sunriseGold.opacity(crossInnerGlow ? 0.3 : 0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 95, height: 120)
                        .blur(radius: 18)
                        .scaleEffect(crossScale * 1.3)
                        .opacity(crossOpacity * 0.75)

                    LuminousCrossShape()
                        .fill(sunriseGold.opacity(0.15))
                        .frame(width: 95, height: 120)
                        .blur(radius: 45)
                        .scaleEffect(crossScale * 2.0)
                        .opacity(crossOpacity * 0.5)
                }
                .position(x: screenW / 2, y: currentCrossY)

                ForEach(0..<12, id: \.self) { i in
                    let particleX: [CGFloat] = [-120, 90, -60, 130, -100, 50, -140, 110, -30, 80, -80, 60]
                    let particleStartY: [CGFloat] = [20, 50, 10, 40, 30, 15, 55, 5, 35, 45, 25, 55]
                    let particleEndY: [CGFloat] = [-320, -280, -350, -300, -310, -340, -270, -360, -290, -330, -310, -350]
                    let particleSizes: [CGFloat] = [3, 4, 2, 5, 3, 2, 4, 3, 2, 3, 4, 2]
                    let particleColors: [Color] = [dawnCream, sunriseGold, .white, sunriseGold.opacity(0.8), sunrisePeach, dawnCream.opacity(0.9), .white.opacity(0.8), sunriseGold, dawnCream, .white, sunrisePeach, sunriseGold.opacity(0.7)]

                    Circle()
                        .fill(particleColors[i])
                        .frame(width: particleSizes[i], height: particleSizes[i])
                        .position(
                            x: screenW / 2 + particleX[i],
                            y: currentCrossY + (particleFloat[i] ? particleEndY[i] : particleStartY[i])
                        )
                        .opacity(particleFloat[i] ? 0 : 0.7)
                        .blur(radius: particleSizes[i] > 3 ? 1 : 0)
                }

                Color.white
                    .opacity(crossFlashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer()
                    Spacer()

                    (Text("Come and meet with\n")
                        .foregroundColor(.white.opacity(0.92))
                    + Text("the God who loves you")
                        .foregroundColor(dawnCream))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .shadow(color: sunriseGold.opacity(0.6), radius: 20, y: 0)
                        .shadow(color: .white.opacity(0.15), radius: 8, y: 0)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 25)
                        .blur(radius: textReveal[1] ? 0 : 4)

                    Spacer()
                        .frame(height: 32)

                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("Put God First.")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, dawnCream, sunriseGold.opacity(0.9)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: sunriseGold.opacity(0.8), radius: 18, y: 0)
                                .shadow(color: sunriseGold.opacity(0.4), radius: 40, y: 0)
                            Text("Feed your soul before you scroll.")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white.opacity(0.85), dawnCream.opacity(0.7), horizonWarm.opacity(0.6)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: horizonWarm.opacity(0.5), radius: 12, y: 0)
                        }
                            .multilineTextAlignment(.center)
                            .opacity(textReveal[2] ? 1 : 0)
                            .offset(y: textReveal[2] ? 0 : 18)
                            .blur(radius: textReveal[2] ? 0 : 3)
                    }

                    Spacer().frame(height: 28)

                    welcomePageIndicator(current: 0)
                        .padding(.top, 8)

                    Button {
                        advance()
                    } label: {
                        HStack(spacing: 10) {
                            Text("Begin My Journey")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(Color(red: 0.25, green: 0.12, blue: 0.05))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [dawnCream, sunriseGold.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .shadow(color: sunriseGold.opacity(0.5), radius: 20, y: 4)
                        .shadow(color: horizonWarm.opacity(0.3), radius: 10, y: 2)
                    }
                    .opacity(textReveal[3] ? 1 : 0)
                    .offset(y: textReveal[3] ? 0 : 30)
                    .scaleEffect(textReveal[3] ? 1 : 0.9)

                    Spacer().frame(height: 50)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 28)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            resetReveals()
            encounterDarkness = 1.0
            encounterGlow = false
            encounterRays = false
            crossScale = 0
            crossOpacity = 0
            crossInnerGlow = false
            lightBurst = false
            verticalBeam = false
            horizontalBeam = false
            ambientPulse = false
            bgPulsePhase = false
            shimmerOffset = -200
            textGlowPulse = false
            ringScales = Array(repeating: 0.3, count: 4)
            ringOpacities = Array(repeating: 0, count: 4)
            particleFloat = Array(repeating: false, count: 12)
            cloudDrift1 = 0
            cloudDrift2 = 0
            cloudDrift3 = 0
            starsVisible = false
            starTwinkle = Array(repeating: false, count: 20)
            welcomeShootProgress = Array(repeating: 0, count: 8)
            welcomeShootOpacity = Array(repeating: 0, count: 8)
            crossFlashOpacity = 0
            sunOrb = 0
            horizonGlowIntensity = 0
            warmthSpread = false
            crossRiseProgress = 0
            skyAwakening = 0
            horizonBand = 0
            nightFade = 1.0
            dawnBreaking = 0
            goldenHour = 0
            cloudsLit = 0
            atmosphereWarmth = 0

            withAnimation(.easeIn(duration: 0.5)) {
                starsVisible = true
            }

            for i in 0..<20 {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1.2...2.5))
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.15)
                ) {
                    starTwinkle[i] = true
                }
            }

            let shootDelays: [Double] = [0.15, 0.45, 0.8, 0.25, 0.6, 1.0, 0.5, 0.9]
            let shootDurs: [Double] = [0.7, 0.8, 0.6, 0.9, 0.65, 0.75, 0.55, 0.85]
            for i in 0..<8 {
                DispatchQueue.main.asyncAfter(deadline: .now() + shootDelays[i]) {
                    withAnimation(.linear(duration: 0.01)) { welcomeShootOpacity[i] = 1.0 }
                    withAnimation(.easeOut(duration: shootDurs[i])) { welcomeShootProgress[i] = 1.0 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + shootDurs[i] * 0.7) {
                        withAnimation(.easeOut(duration: 0.3)) { welcomeShootOpacity[i] = 0 }
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.6)) {
                    crossOpacity = 0.3
                    crossScale = 0.4
                }
                withAnimation(.easeOut(duration: 1.5)) {
                    skyAwakening = 0.3
                    horizonBand = 0.15
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.spring(response: 2.8, dampingFraction: 0.65)) {
                    crossRiseProgress = 1.0
                    crossOpacity = 1.0
                    crossScale = 1.08
                }

                withAnimation(.easeOut(duration: 4.0)) {
                    skyAwakening = 1.0
                    nightFade = 0.0
                }
                withAnimation(.easeOut(duration: 3.5).delay(0.5)) {
                    horizonBand = 1.0
                    dawnBreaking = 1.0
                }
                withAnimation(.easeOut(duration: 3.0).delay(1.0)) {
                    goldenHour = 1.0
                    horizonGlowIntensity = 1.0
                    encounterGlow = true
                }
                withAnimation(.easeOut(duration: 2.5).delay(1.5)) {
                    cloudsLit = 1.0
                    atmosphereWarmth = 1.0
                }
                withAnimation(.easeOut(duration: 2.0).delay(2.0)) {
                    grassVisible = 1.0
                }

            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                withAnimation(.easeOut(duration: 0.12)) { crossFlashOpacity = 0.7 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.easeOut(duration: 0.6)) { crossFlashOpacity = 0 }
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    crossScale = 1.0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeOut(duration: 1.2)) {
                    lightBurst = true
                }
                withAnimation(.easeOut(duration: 0.8).delay(0.05)) {
                    verticalBeam = true
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
                    horizontalBeam = true
                }

                for i in 0..<4 {
                    let delay = Double(i) * 0.08
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay)) {
                        ringScales[i] = 1.0
                        ringOpacities[i] = Double(4 - i) / 5.0
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    crossInnerGlow = true
                    ambientPulse = true
                    bgPulsePhase = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 12.0).repeatForever(autoreverses: true)) {
                    cloudDrift1 = 25
                }
                withAnimation(.easeInOut(duration: 16.0).repeatForever(autoreverses: true)) {
                    cloudDrift2 = -20
                }
                withAnimation(.easeInOut(duration: 14.0).repeatForever(autoreverses: true)) {
                    cloudDrift3 = 18
                }
            }

            for i in 0..<12 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                    withAnimation(
                        .easeOut(duration: Double.random(in: 3.0...5.0))
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.2)
                    ) {
                        particleFloat[i] = true
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation(.easeOut(duration: 1.2)) { textReveal[1] = true }
                typingHaptic()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.3) {
                withAnimation(.easeOut(duration: 1.0)) { textReveal[2] = true }
                typingHaptic()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { textReveal[3] = true }
                typingHaptic()
            }
        }
    }



    // MARK: - Screen 1: Name

    private var namePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 14) {
                    Text("Let\u{2019}s make this personal.")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 16)

                    Text("What should we call you?")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 12)
                }

                VStack(spacing: 12) {
                    TextField("Your name", text: $nameInput)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Theme.cardBg)
                        )
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 12)

                    Text("We\u{2019}ll use your name to build a prayer journey just for you.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[3] ? 1 : 0)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 1)

                onboardingButton("Continue") {
                    viewModel.userName = nameInput.trimmingCharacters(in: .whitespaces)
                    advance()
                }
                .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 4, baseDelay: 0.2, interval: 0.3) }
    }

    // MARK: - Screen 2: Denomination

    private var denominationPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 14) {
                    Text("What\u{2019}s your faith\nbackground, \(displayName)?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 16)

                    Text("This helps us personalize your experience.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 12)
                }

                VStack(spacing: 10) {
                    denominationOption("Protestant", emoji: "\u{271D}\u{FE0F}")
                    denominationOption("Catholic", emoji: "\u{1F4FF}")
                    denominationOption("Orthodox", emoji: "\u{2626}\u{FE0F}")
                    denominationOption("Non-Denominational", emoji: "\u{1F49B}")
                    denominationOption("Just exploring", emoji: "\u{2728}")
                }
                .opacity(textReveal[2] ? 1 : 0)
                .offset(y: textReveal[2] ? 0 : 10)
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 2)

                onboardingButton("Continue") {
                    viewModel.denomination = selectedDenomination
                    advance()
                }
                .opacity(selectedDenomination.isEmpty ? 0.5 : 1.0)
                .disabled(selectedDenomination.isEmpty)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 3, baseDelay: 0.2, interval: 0.3) }
    }

    private func denominationOption(_ label: String, emoji: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDenomination = label
            }
            typingHaptic()
        } label: {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 24))
                    .frame(width: 32)

                Text(label)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                if selectedDenomination == label {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(sunriseGold)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedDenomination == label ? sunriseGold.opacity(0.1) : Theme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(selectedDenomination == label ? sunriseGold : Color.clear, lineWidth: 2)
                    )
            )
        }
    }

    // MARK: - Screen 3: Spiritual Goals

    private var spiritualGoalsPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 14) {
                    Text("How do you hope to grow?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 16)

                    Text("Pick all that apply.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 12)
                }

                VStack(spacing: 10) {
                    goalOption("Deeper prayer life", emoji: "\u{1F64F}", color: sunriseGold)
                    goalOption("Bible knowledge", emoji: "\u{1F4D6}", color: Theme.skyBlue)
                    goalOption("Closer relationship with God", emoji: "\u{2764}\u{FE0F}", color: Theme.dawnRose)
                    goalOption("Breaking bad habits", emoji: "\u{1F6E1}\u{FE0F}", color: Theme.mint)
                    goalOption("More peace & less anxiety", emoji: "\u{1F33F}", color: Theme.lavender)
                    goalOption("Consistency & discipline", emoji: "\u{1F525}", color: Theme.dawnAmber)
                }
                .opacity(textReveal[2] ? 1 : 0)
                .offset(y: textReveal[2] ? 0 : 10)
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 3)

                onboardingButton("Continue") {
                    viewModel.spiritualGoals = Array(selectedGoals)
                    advance()
                }
                .opacity(selectedGoals.isEmpty ? 0.5 : 1.0)
                .disabled(selectedGoals.isEmpty)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 3, baseDelay: 0.2, interval: 0.3) }
    }

    private func goalOption(_ label: String, emoji: String, color: Color) -> some View {
        let isSelected = selectedGoals.contains(label)
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isSelected {
                    selectedGoals.remove(label)
                } else {
                    selectedGoals.insert(label)
                }
            }
            typingHaptic()
        } label: {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 24))
                    .frame(width: 32)
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSelected)

                Text(label)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.1) : Theme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
    }

    @State private var visionBeforePulse: Bool = false
    @State private var visionBeforeDroop: Bool = false

    // MARK: - Screen 4: Vision Casting

    private var visionPage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Color(red: 0.06, green: 0.04, blue: 0.1)
                    .ignoresSafeArea()
                    .opacity(visionDarkBg)

                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.08, blue: 0.22),
                        Color(red: 0.06, green: 0.2, blue: 0.48),
                        Color(red: 0.2, green: 0.45, blue: 0.78),
                        sunriseGold.opacity(0.6),
                        dawnCream.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .opacity(visionWarmBg)

                RadialGradient(
                    colors: [
                        dawnCream.opacity(visionLightBurst ? 0.9 : 0),
                        sunriseGold.opacity(visionLightBurst ? 0.5 : 0),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: visionLightBurst ? max(w, h) : 10
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        sunriseGold.opacity(visionAfterGlow ? 0.15 : 0),
                        horizonWarm.opacity(visionAfterGlow ? 0.08 : 0),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0.7),
                    startRadius: 20,
                    endRadius: 300
                )
                .ignoresSafeArea()

                if visionRaysVisible {
                    ForEach(0..<8, id: \.self) { i in
                        let angle = Double(i) * 45.0
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [sunriseGold.opacity(0.15), Color.clear],
                                    startPoint: .center,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 300, height: 2)
                            .rotationEffect(.degrees(angle + visionRaysRotation))
                            .position(x: w / 2, y: h * 0.7)
                            .blur(radius: 4)
                    }
                }

                ForEach(0..<8, id: \.self) { i in
                    let px: [CGFloat] = [0.15, 0.85, 0.3, 0.7, 0.2, 0.8, 0.45, 0.55]
                    let py: [CGFloat] = [0.2, 0.25, 0.35, 0.15, 0.4, 0.3, 0.18, 0.38]
                    let sizes: [CGFloat] = [3, 4, 2, 3, 5, 2, 3, 4]
                    Circle()
                        .fill(dawnCream)
                        .frame(width: sizes[i], height: sizes[i])
                        .position(
                            x: w * px[i],
                            y: h * py[i] + (visionParticles[i] ? -60 : 0)
                        )
                        .opacity(visionParticles[i] ? 0.8 : 0)
                        .blur(radius: sizes[i] > 3 ? 1 : 0)
                }

                VStack(spacing: 0) {
                    Spacer()

                    Text("\(displayName), imagine your\nmornings if God spoke first.")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(visionPhase >= 2 ? Color.white : Theme.textPrimary.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .shadow(color: visionPhase >= 2 ? sunriseGold.opacity(0.5) : .clear, radius: 15)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 20)
                        .animation(.easeOut(duration: 0.8), value: textReveal[0])
                        .animation(.easeInOut(duration: 1.0), value: visionPhase)

                    Spacer().frame(height: 24)

                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.14, green: 0.06, blue: 0.08),
                                        Color(red: 0.1, green: 0.04, blue: 0.06)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.red.opacity(0.4), Color.red.opacity(0.12)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(height: 195)
                            .overlay(
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("\u{1F634}")
                                            .font(.system(size: 14))
                                        Text("BEFORE")
                                            .font(.system(size: 11, weight: .black, design: .rounded))
                                            .foregroundStyle(Color.red.opacity(0.85))
                                            .tracking(2)
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Text("\u{1F4F1}")
                                                .font(.system(size: 11))
                                            Text("\u{1F635}")
                                                .font(.system(size: 11))
                                                .offset(y: visionBeforeDroop ? 2 : -2)
                                        }
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.top, 14)

                                    Spacer().frame(height: 12)

                                    VStack(spacing: 8) {
                                        visionBeforeRow(emoji: "\u{1F611}", text: "Reach for phone first", sfIcon: "\u{1F4F3}", index: 0)
                                        visionBeforeRow(emoji: "\u{1F628}", text: "Stress starts immediately", sfIcon: "\u{1F494}", index: 1)
                                        visionBeforeRow(emoji: "\u{1F62B}", text: "Prayer gets pushed later", sfIcon: "\u{23F0}", index: 2)
                                    }
                                    .padding(.horizontal, 16)

                                    Spacer()
                                }
                            )
                            .shadow(color: Color.red.opacity(visionBeforePulse ? 0.2 : 0.05), radius: 20)
                            .scaleEffect(visionPhoneScale)
                            .offset(x: visionBeforeShake ? 4 : 0)
                            .opacity(visionPhase >= 1 ? visionBeforeFade : 0)
                            .offset(y: visionPhase >= 1 ? 0 : 30)

                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.08, green: 0.16, blue: 0.06),
                                        Color(red: 0.06, green: 0.14, blue: 0.22),
                                        Color(red: 0.12, green: 0.2, blue: 0.08)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [sunriseGold.opacity(0.6), Color(red: 0.4, green: 0.8, blue: 0.4).opacity(0.3)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(height: 195)
                            .overlay(
                                VStack(spacing: 0) {
                                    HStack {
                                        Text("\u{2728}")
                                            .font(.system(size: 14))
                                        Text("AFTER")
                                            .font(.system(size: 11, weight: .black, design: .rounded))
                                            .foregroundStyle(Theme.readableGold)
                                            .tracking(2)
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Text("\u{2600}\u{FE0F}")
                                                .font(.system(size: 11))
                                            Text("\u{1F64F}")
                                                .font(.system(size: 11))
                                        }
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.top, 14)

                                    Spacer().frame(height: 12)

                                    VStack(spacing: 8) {
                                        visionAfterRow(emoji: "\u{1F60C}", text: "Peace before pressure", sfIcon: "\u{1F3D6}", index: 0)
                                        visionAfterRow(emoji: "\u{1F525}", text: "God speaks first", sfIcon: "\u{1F399}", index: 1)
                                        visionAfterRow(emoji: "\u{1F4AA}", text: "Grounded all day", sfIcon: "\u{1F9D8}", index: 2)
                                    }
                                    .padding(.horizontal, 16)

                                    Spacer()
                                }
                            )
                            .shadow(color: sunriseGold.opacity(visionAfterGlow ? 0.35 : 0), radius: 30)
                            .opacity(visionPhase >= 2 ? 1 : 0)
                            .scaleEffect(visionPhase >= 2 ? 1.0 : 0.85)
                            .offset(y: visionPhase >= 2 ? 0 : 30)
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 20)

                    Spacer().frame(height: 14)

                    VStack(spacing: 14) {
                        pageIndicator(current: 4)

                        onboardingButton("I Want This") {
                            advance()
                        }
                        .frame(maxWidth: 260)
                        .opacity(visionPhase >= 2 ? 1 : 0)
                    }
                    .padding(.bottom, 44)

                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            resetReveals()
            visionPhase = 0
            visionBeforeItems = Array(repeating: false, count: 3)
            visionAfterItems = Array(repeating: false, count: 3)
            visionLightBurst = false
            visionDarkBg = 1.0
            visionWarmBg = 0.0
            visionBeforeShake = false
            visionBeforeFade = 1.0
            visionAfterGlow = false
            visionSunrise = 0
            visionRaysRotation = 0
            visionRaysVisible = false
            visionParticles = Array(repeating: false, count: 8)
            visionPhoneScale = 1.0
            visionPhoneOffset = 0
            visionScreenCrack = false
            visionFlipProgress = 0
            visionBeforePulse = false
            visionBeforeDroop = false

            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textReveal[0] = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    visionPhase = 1
                }
                for i in 0..<3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                            visionBeforeItems[i] = true
                        }
                        let g = UIImpactFeedbackGenerator(style: .heavy)
                        g.impactOccurred()
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    visionBeforePulse = true
                    visionBeforeDroop = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.06).repeatCount(10, autoreverses: true)) {
                    visionBeforeShake = true
                }
                let g = UIImpactFeedbackGenerator(style: .heavy)
                g.impactOccurred()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    visionPhoneScale = 0.96
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                withAnimation(.easeIn(duration: 0.4)) {
                    visionLightBurst = true
                }
                let g = UINotificationFeedbackGenerator()
                g.notificationOccurred(.success)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    visionDarkBg = 0
                    visionWarmBg = 1.0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
                withAnimation(.easeOut(duration: 0.5)) {
                    visionLightBurst = false
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                    visionPhase = 2
                }
                visionRaysVisible = true
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    visionRaysRotation = 360
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    visionAfterGlow = true
                }

                for i in 0..<3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.35) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            visionAfterItems[i] = true
                        }
                        let g = UIImpactFeedbackGenerator(style: .soft)
                        g.impactOccurred()
                    }
                }

                for i in 0..<8 {
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.0...4.0))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.25)
                    ) {
                        visionParticles[i] = true
                    }
                }
            }
        }
    }

    private func visionBeforeRow(emoji: String, text: String, sfIcon: String, index: Int) -> some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 18))
                .frame(width: 28)
            Text(sfIcon)
                .font(.system(size: 14))
                .frame(width: 20)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.75))
            Spacer()
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.08))
        )
        .opacity(visionBeforeItems[safe: index] == true ? 1 : 0)
        .offset(x: visionBeforeItems[safe: index] == true ? 0 : -20)
    }

    private func visionAfterRow(emoji: String, text: String, sfIcon: String, index: Int) -> some View {
        HStack(spacing: 10) {
            Text(emoji)
                .font(.system(size: 18))
                .frame(width: 28)
            Text(sfIcon)
                .font(.system(size: 14))
                .frame(width: 20)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.95))
            Spacer()
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(sunriseGold.opacity(0.12))
        )
        .opacity(visionAfterItems[safe: index] == true ? 1 : 0)
        .offset(y: visionAfterItems[safe: index] == true ? 0 : 15)
        .scaleEffect(visionAfterItems[safe: index] == true ? 1 : 0.95)
    }

    // MARK: - Screen 3: Habit Mirror

    private var habitPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 14) {
                    Text("Be honest, \(displayName)\u{2026}")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 16)

                    Text("When do you usually reach\nfor your phone?")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 12)
                }

                VStack(spacing: 10) {
                    habitOption("Immediately when I wake up", icon: "alarm.fill")
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 10)
                    habitOption("Within 5 minutes", icon: "clock.fill")
                        .opacity(textReveal[3] ? 1 : 0)
                        .offset(y: textReveal[3] ? 0 : 10)
                    habitOption("After I get out of bed", icon: "bed.double.fill")
                        .opacity(textReveal[4] ? 1 : 0)
                        .offset(y: textReveal[4] ? 0 : 10)
                    habitOption("I try to wait", icon: "hand.raised.fill")
                        .opacity(textReveal[5] ? 1 : 0)
                        .offset(y: textReveal[5] ? 0 : 10)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 6)

                onboardingButton("Continue") {
                    advance()
                }
                .opacity(phoneHabit.isEmpty ? 0.5 : 1.0)
                .disabled(phoneHabit.isEmpty)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 6, baseDelay: 0.2, interval: 0.15) }
    }

    // MARK: - Screen 4: Brain Science

    private var brainSciencePage: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        ZStack {
                            Text("🧠")
                                .font(.system(size: 64))
                            Text("⚡")
                                .font(.system(size: 40))
                                .offset(x: 28, y: -22)
                                .rotationEffect(.degrees(-15))
                            Text("⚡")
                                .font(.system(size: 30))
                                .offset(x: -30, y: -18)
                                .rotationEffect(.degrees(15))
                            Text("⚡")
                                .font(.system(size: 24))
                                .offset(x: 20, y: 24)
                                .rotationEffect(.degrees(-30))
                        }
                        .opacity(textReveal[0] ? 1 : 0)
                        .scaleEffect(textReveal[0] ? 1 : 0.5)

                        Text("Your brain wasn\u{2019}t built\nfor this, \(displayName).")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 16)

                        Text("When you reach for your phone first thing, here\u{2019}s what happens:")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .opacity(textReveal[1] ? 1 : 0)
                    }

                    VStack(spacing: 8) {
                        brainStatRow(label: "Cortisol spikes from morning stress", value: 38, index: 0, color: Theme.coral)
                        brainStatRow(label: "Anxiety increases from social media first", value: 41, index: 1, color: Theme.hotPink)
                        brainStatRow(label: "Focus drops when screens come before prayer", value: 47, index: 2, color: Theme.electricBlue)
                        brainStatRow(label: "Of people check their phone within 10 min of waking", value: 80, index: 3, color: Theme.lavender)
                        brainStatRow(label: "Report feeling \u{201C}behind\u{201D} before the day starts", value: 65, index: 4, color: Theme.skyBlue)
                        brainStatRow(label: "Say phone habits hurt their spiritual life", value: 73, index: 5, color: Theme.blueAccent)
                    }

                    Text("Your mornings are setting the tone\nfor your entire day.")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.coral)
                        .multilineTextAlignment(.center)
                        .italic()
                        .opacity(brainStatsRevealed >= 6 ? 1 : 0)
                        .offset(y: brainStatsRevealed >= 6 ? 0 : 10)
                        .animation(.easeOut(duration: 0.5), value: brainStatsRevealed)
                }

                Spacer().frame(height: 40)

                VStack(spacing: 16) {
                    pageIndicator(current: 9)

                    onboardingButton("What Can I Do?") {
                        advance()
                    }
                    .opacity(brainStatsRevealed >= 6 ? 1.0 : 0.4)
                    .disabled(brainStatsRevealed < 6)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            resetReveals()
            brainStatsRevealed = 0
            brainStatCounters = Array(repeating: 0, count: 6)

            withAnimation(.easeOut(duration: 0.5)) { textReveal[0] = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) { textReveal[1] = true }

            let targetValues: [Double] = [38, 41, 47, 80, 65, 73]
            for i in 0..<6 {
                let delay = 0.8 + Double(i) * 0.25
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        brainStatsRevealed = i + 1
                    }
                    withAnimation(.easeOut(duration: 0.8)) {
                        brainStatCounters[i] = targetValues[i]
                    }
                }
            }
        }
    }

    // MARK: - Screen 5: Hardwired for God

    private var hardwiredPage: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("But here\u{2019}s the good news,\n\(displayName).")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 16)

                        Text("You were hardwired to seek God.\nWhen you start with Jesus, everything changes.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(textReveal[2] ? 1 : 0)
                            .offset(y: textReveal[2] ? 0 : 12)
                    }

                    VStack(spacing: 10) {
                        hardwiredCard(
                            icon: "leaf.fill",
                            title: "Peace Before Pressure",
                            body: "Less anxiety, more emotional stability all day.",
                            color: Theme.mint,
                            index: 3
                        )
                        hardwiredCard(
                            icon: "brain",
                            title: "Your Brain on Prayer",
                            body: "Prayer activates your brain\u{2019}s center of calm, focus, and wisdom.",
                            color: Theme.skyBlue,
                            index: 4
                        )
                        hardwiredCard(
                            icon: "bolt.heart.fill",
                            title: "Designed for Connection",
                            body: "Starting with God sets your whole nervous system at peace.",
                            color: Theme.lavender,
                            index: 5
                        )
                        hardwiredCard(
                            icon: "sun.max.fill",
                            title: "Set Up for Success",
                            body: "His peace flows into every conversation, challenge, and decision.",
                            color: Theme.blueAccent,
                            index: 6
                        )
                    }


                }

                Spacer().frame(height: 40)

                VStack(spacing: 16) {
                    pageIndicator(current: 10)

                    onboardingButton("I\u{2019}m Ready") {
                        advance()
                    }
                    .opacity(textReveal[7] ? 1 : 0)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            resetReveals()
            for i in 0..<8 {
                let delay = 0.2 + Double(i) * 0.35
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    textReveal[i] = true
                }
            }
        }
    }

    // MARK: - Screen 6: Prayer Confidence

    private var confidencePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Text("How confident do you feel\nin prayer right now?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 16)

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Theme.blueAccent.opacity(0.06))
                            .frame(width: 120, height: 120)

                        Text(confidenceEmoji)
                            .font(.system(size: 52))
                    }
                    .opacity(textReveal[1] ? 1 : 0)
                    .scaleEffect(textReveal[1] ? 1 : 0.7)

                    Text(confidenceLabel)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.blueAccent)

                    VStack(spacing: 8) {
                        Slider(value: $prayerConfidence, in: 0...1)
                            .tint(Theme.blueAccent)
                            .padding(.horizontal, 8)

                        HStack {
                            Text("Struggle to focus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                            Text("Consistent & strong")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(.horizontal, 8)
                    }
                    .opacity(textReveal[2] ? 1 : 0)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Theme.cardBg)
                )

                Text("No matter where you are, God meets you there.\nThis app will help you grow.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(textReveal[3] ? 1 : 0)
                    .offset(y: textReveal[3] ? 0 : 8)
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 11)

                onboardingButton("Continue") {
                    advance()
                }
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 4, baseDelay: 0.2, interval: 0.4) }
    }

    // MARK: - Screen 7: Time Capacity

    private var timePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Text("How much time could you\ngive God first thing?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 16)

                VStack(spacing: 10) {
                    timeOption(2)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 10)
                    timeOption(5)
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 10)
                    timeOption(10)
                        .opacity(textReveal[3] ? 1 : 0)
                        .offset(y: textReveal[3] ? 0 : 10)
                    timeOption(15)
                        .opacity(textReveal[4] ? 1 : 0)
                        .offset(y: textReveal[4] ? 0 : 10)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 12)

                onboardingButton("Continue") {
                    viewModel.prayerDurationMinutes = selectedMinutes
                    advance()
                }
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 5, baseDelay: 0.2, interval: 0.15) }
    }

    // MARK: - Screen 8: Bible Statistics

    private var bibleStatsPage: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        Text("Studies show that people\nwho read their Bible\n4x per week experience:")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 16)
                    }

                    VStack(spacing: 8) {
                        bibleStatRow(label: "Loneliness drops", value: 38, index: 0, color: Theme.skyBlue)
                        bibleStatRow(label: "Anger issues drop", value: 32, index: 1, color: Theme.blueAccent)
                        bibleStatRow(label: "Bitterness in relationships drops", value: 40, index: 2, color: Theme.lavender)
                        bibleStatRow(label: "Alcoholism drops", value: 57, index: 3, color: Theme.coral)
                        bibleStatRow(label: "Feeling spiritually stagnant drops", value: 60, index: 4, color: Theme.mint)
                        bibleStatRow(label: "Viewing pornography drops", value: 61, index: 5, color: Theme.electricBlue)
                    }

                    Text("\(displayName), God\u{2019}s Word changes everything.")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.blueAccent)
                        .multilineTextAlignment(.center)
                        .italic()
                        .opacity(statsRevealed >= 6 ? 1 : 0)
                        .offset(y: statsRevealed >= 6 ? 0 : 10)
                        .animation(.easeOut(duration: 0.5), value: statsRevealed)
                }

                Spacer().frame(height: 40)

                VStack(spacing: 16) {
                    pageIndicator(current: 14)

                    onboardingButton("Continue") {
                        advance()
                    }
                    .opacity(statsRevealed >= 6 ? 1.0 : 0.4)
                    .disabled(statsRevealed < 6)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            resetReveals()
            statsRevealed = 0
            statCounters = Array(repeating: 0, count: 6)

            withAnimation(.easeOut(duration: 0.5)) { textReveal[0] = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) { textReveal[1] = true }

            let targetValues: [Double] = [38, 32, 40, 57, 60, 61]
            for i in 0..<6 {
                let delay = 0.8 + Double(i) * 0.25
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        statsRevealed = i + 1
                    }
                    withAnimation(.easeOut(duration: 0.8)) {
                        statCounters[i] = targetValues[i]
                    }
                }
            }
        }
    }

    // MARK: - Screen 9: Emotional Buy-In

    private var buyInPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Text("\(displayName), here\u{2019}s what\nthis could become.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 16)

                VStack(spacing: 20) {
                    Text("\(yearlyHours)+")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [sunriseGold, horizonWarm], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: sunriseGold.opacity(0.5), radius: 20)
                        .opacity(textReveal[1] ? 1 : 0)
                        .scaleEffect(textReveal[1] ? 1 : 0.5)

                    Text("hours a year with God")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .opacity(textReveal[2] ? 1 : 0)

                    Text("Just \(selectedMinutes) minutes a day.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(textReveal[2] ? 1 : 0)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(sunriseGold.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(sunriseGold.opacity(0.2), lineWidth: 1)
                        )
                )

                Text("Small daily obedience becomes\na transformed life.")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(Theme.textSecondary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[3] ? 1 : 0)
                    .offset(y: textReveal[3] ? 0 : 10)
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 13)

                onboardingButton("Continue") {
                    advance()
                }
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 4, baseDelay: 0.2, interval: 0.4) }
    }

    // MARK: - Screen 10: Building Journey

    private var buildingPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 36) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [sunriseGold.opacity(warmIconGlow ? 0.2 : 0.06), dawnCream.opacity(0.04), Color.clear],
                                center: .center, startRadius: 5, endRadius: 55
                            )
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(warmIconGlow ? 1.08 : 0.95)

                    Image(systemName: "hammer.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(colors: [sunriseGold, horizonWarm], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: sunriseGold.opacity(0.4), radius: 10)
                }
                .opacity(textReveal[0] ? 1 : 0)
                .scaleEffect(textReveal[0] ? 1 : 0.5)

                Text("We\u{2019}re building your\nprayer journey.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 16)

                VStack(spacing: 16) {
                    journeyBuildItem("Seek God before distraction", index: 0)
                    journeyBuildItem("Build a consistent prayer rhythm", index: 1)
                    journeyBuildItem("Grow deeper with Jesus", index: 2)
                    journeyBuildItem("Guard your heart and mind daily", index: 3)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 18)

                onboardingButton("Continue") {
                    advance()
                }
                .opacity(journeyDotsLoaded >= 4 ? 1.0 : 0.4)
                .disabled(journeyDotsLoaded < 4)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            resetReveals()
            withAnimation(.easeOut(duration: 0.5)) { textReveal[0] = true }
            journeyDotsLoaded = 0
            for i in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6 + 0.5) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        journeyDotsLoaded = i + 1
                    }
                }
            }
        }
    }

    // MARK: - Screen 11: Community

    private var communityPage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let centerX = w / 2
            let centerY = h * 0.38

            ZStack {
                Color(red: 0.04, green: 0.02, blue: 0.1)
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.02, blue: 0.12),
                        Color(red: 0.08, green: 0.04, blue: 0.22),
                        Color(red: 0.12, green: 0.06, blue: 0.3),
                        Color(red: 0.08, green: 0.04, blue: 0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Theme.logoBlue.opacity(communityGlowBurst ? 0.25 : 0.08),
                        Theme.logoPurple.opacity(communityGlowBurst ? 0.15 : 0.04),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0.38),
                    startRadius: 20,
                    endRadius: communityGlowBurst ? 350 : 200
                )
                .ignoresSafeArea()

                ForEach(0..<8, id: \.self) { i in
                    let sx: [CGFloat] = [0.1, 0.9, 0.25, 0.75, 0.15, 0.85, 0.4, 0.6]
                    let sy: [CGFloat] = [0.15, 0.2, 0.55, 0.6, 0.35, 0.45, 0.1, 0.65]
                    let sizes: [CGFloat] = [3, 2, 4, 2, 3, 2, 3, 2]
                    Circle()
                        .fill(Color.white)
                        .frame(width: sizes[i], height: sizes[i])
                        .position(x: w * sx[i], y: h * sy[i] + (communitySparkles[i] ? -15 : 15))
                        .opacity(communitySparkles[i] ? 0.8 : 0.15)
                        .blur(radius: sizes[i] > 2 ? 1 : 0)
                }

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Theme.logoBlue.opacity(0.3), Theme.logoPurple.opacity(0.15)],
                            startPoint: .top, endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 260, height: 260)
                    .scaleEffect(communityRingScale)
                    .opacity(communityRingOpacity * 0.5)
                    .position(x: centerX, y: centerY)

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Theme.logoIndigo.opacity(0.25), Theme.logoBlue.opacity(0.1)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(communityRingScale)
                    .opacity(communityRingOpacity * 0.4)
                    .position(x: centerX, y: centerY)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Theme.logoBlue.opacity(communityCenterGlow ? 0.3 : 0.05),
                                Theme.logoPurple.opacity(communityCenterGlow ? 0.15 : 0.02),
                                Color.clear
                            ],
                            center: .center, startRadius: 5, endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(communityPulse ? 1.12 : 0.92)
                    .position(x: centerX, y: centerY)

                let outerR: CGFloat = 120
                let innerR: CGFloat = 72
                let outerAvatars: [(String, Color)] = [
                    ("J", Theme.logoBlue), ("M", Theme.logoPurple), ("S", Theme.logoIndigo),
                    ("A", Theme.dawnAmber), ("R", Theme.logoDeepPurple), ("L", Theme.skyBlue),
                    ("D", Theme.lavender), ("K", Theme.logoViolet)
                ]
                let innerAvatars: [(String, Color)] = [
                    ("P", Theme.dawnRose), ("G", Theme.logoBlue.opacity(0.8)),
                    ("E", Theme.mint), ("C", Theme.logoPurple.opacity(0.8))
                ]

                ForEach(0..<outerAvatars.count, id: \.self) { i in
                    let baseAngle = (Double(i) / Double(outerAvatars.count)) * 360.0
                    let angle = baseAngle + communityOrbitAngle
                    let rad = angle * .pi / 180
                    let ax = centerX + outerR * cos(rad)
                    let ay = centerY + outerR * sin(rad)
                    let floatY: CGFloat = communityFloatPhase[i] ? -4 : 4

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [outerAvatars[i].1.opacity(0.5), outerAvatars[i].1.opacity(0.15), Color.clear],
                                    center: .center, startRadius: 2, endRadius: 28
                                )
                            )
                            .frame(width: 56, height: 56)
                            .scaleEffect(communityPulse ? 1.15 : 0.9)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [outerAvatars[i].1, outerAvatars[i].1.opacity(0.7)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(outerAvatars[i].0)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: outerAvatars[i].1.opacity(0.6), radius: 10)
                    }
                    .position(x: ax, y: ay + floatY)
                    .opacity(communityAvatarsRevealed > i ? 1 : 0)
                    .scaleEffect(communityAvatarsRevealed > i ? 1 : 0.3)
                }

                ForEach(0..<innerAvatars.count, id: \.self) { i in
                    let baseAngle = (Double(i) / Double(innerAvatars.count)) * 360.0 + 45
                    let angle = baseAngle + communityInnerOrbit
                    let rad = angle * .pi / 180
                    let ax = centerX + innerR * cos(rad)
                    let ay = centerY + innerR * sin(rad)
                    let fi = i + 8
                    let floatY: CGFloat = communityFloatPhase[fi] ? -3 : 3

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [innerAvatars[i].1.opacity(0.4), Color.clear],
                                    center: .center, startRadius: 2, endRadius: 22
                                )
                            )
                            .frame(width: 44, height: 44)
                            .scaleEffect(communityPulse ? 1.1 : 0.9)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [innerAvatars[i].1, innerAvatars[i].1.opacity(0.6)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text(innerAvatars[i].0)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: innerAvatars[i].1.opacity(0.5), radius: 8)
                    }
                    .position(x: ax, y: ay + floatY)
                    .opacity(communityAvatarsRevealed > (i + 8) ? 1 : 0)
                    .scaleEffect(communityAvatarsRevealed > (i + 8) ? 1 : 0.3)
                }

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.logoBlue.opacity(communityCenterGlow ? 0.6 : 0.2),
                                    Theme.logoPurple.opacity(communityCenterGlow ? 0.3 : 0.1),
                                    Color.clear
                                ],
                                center: .center, startRadius: 5, endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "cross.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(color: .white.opacity(0.5), radius: 4)
                        )
                        .shadow(color: Theme.logoBlue.opacity(0.7), radius: 15)
                        .shadow(color: Theme.logoPurple.opacity(0.4), radius: 25)
                }
                .position(x: centerX, y: centerY)
                .scaleEffect(communityAvatarsRevealed > 0 ? 1 : 0)
                .opacity(communityAvatarsRevealed > 0 ? 1 : 0)

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        Text("You\u{2019}re not alone.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: Theme.logoBlue.opacity(0.6), radius: 20)
                            .opacity(textReveal[0] ? 1 : 0)
                            .offset(y: textReveal[0] ? 0 : 20)

                        Text("Join thousands of believers\nwho are putting God first...")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 14)

                        HStack(spacing: 24) {
                            communityStatPill(value: "47", label: "countries", icon: "globe")
                            communityStatPill(value: "2M+", label: "prayers", icon: "hands.sparkles.fill")
                            communityStatPill(value: "98%", label: "stay faithful", icon: "flame.fill")
                        }
                        .opacity(textReveal[3] ? 1 : 0)
                        .offset(y: textReveal[3] ? 0 : 16)
                    }
                    .padding(.top, h * 0.58)

                    Spacer()

                    VStack(spacing: 16) {
                        pageIndicator(current: 19)

                        Button {
                            advance()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Join the Movement")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                            )
                            .shadow(color: Theme.logoIndigo.opacity(0.5), radius: 16, y: 6)
                        }
                        .opacity(textReveal[4] ? 1 : 0)
                        .offset(y: textReveal[4] ? 0 : 20)
                    }
                    .padding(.bottom, 50)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 28)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            resetReveals()
            communityCounter = 0
            communityAvatarsRevealed = 0
            communityOrbitAngle = 0
            communityInnerOrbit = 0
            communityPulse = false
            communityGlowBurst = false
            communityConnectionPulse = false
            communityFloatPhase = Array(repeating: false, count: 12)
            communitySparkles = Array(repeating: false, count: 8)
            communityRingScale = 0.3
            communityRingOpacity = 0
            communityCenterGlow = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    communityAvatarsRevealed = 1
                }
                withAnimation(.easeOut(duration: 0.8)) {
                    communityRingScale = 1.0
                    communityRingOpacity = 1.0
                }
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred()
            }

            for i in 1..<12 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + Double(i) * 0.12) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                        communityAvatarsRevealed = i + 1
                    }
                    if i % 3 == 0 {
                        let g = UIImpactFeedbackGenerator(style: .light)
                        g.impactOccurred()
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.8)) { textReveal[0] = true }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { textReveal[1] = true }
                withAnimation(.easeOut(duration: 1.8)) {
                    communityCounter = 12847
                }
                withAnimation(.easeOut(duration: 0.6)) {
                    communityGlowBurst = true
                }
                let g = UINotificationFeedbackGenerator()
                g.notificationOccurred(.success)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeOut(duration: 0.8)) { textReveal[2] = true }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { textReveal[3] = true }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { textReveal[4] = true }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                    communityOrbitAngle = 360
                }
                withAnimation(.linear(duration: 45).repeatForever(autoreverses: false)) {
                    communityInnerOrbit = -360
                }
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    communityPulse = true
                    communityCenterGlow = true
                }
            }

            for i in 0..<12 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.0...3.5))
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.2)
                    ) {
                        communityFloatPhase[i] = true
                    }
                }
            }

            for i in 0..<8 {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1.5...2.5))
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.3)
                ) {
                    communitySparkles[i] = true
                }
            }
        }
    }

    private func communityStatPill(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Theme.logoBlue)
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Screen 12: Social Blocker

    private var socialBlockerPage: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.01, blue: 0.12),
                    Color(red: 0.07, green: 0.02, blue: 0.22),
                    Color(red: 0.12, green: 0.04, blue: 0.3),
                    Color(red: 0.18, green: 0.06, blue: 0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    accentBlueBright.opacity(blockerGlowPulse ? 0.15 : 0.03),
                    Theme.primary.opacity(blockerGlowPulse ? 0.08 : 0.01),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()

            ForEach(0..<10, id: \.self) { i in
                Circle()
                    .fill(
                        [Color.red, .pink, .cyan, .blue, .purple, .orange, accentBlueBright, .white, Theme.primary, .yellow][i]
                    )
                    .frame(width: CGFloat([3, 4, 2, 5, 3, 4, 2, 3, 5, 2][i]),
                           height: CGFloat([3, 4, 2, 5, 3, 4, 2, 3, 5, 2][i]))
                    .offset(
                        x: CGFloat([-80, 120, -40, 90, -110, 60, -130, 100, -20, 70][i]),
                        y: blockerParticles[i]
                            ? CGFloat([-350, -300, -380, -320, -340, -360, -310, -370, -330, -350][i])
                            : CGFloat([50, 80, 30, 70, 60, 40, 90, 20, 55, 75][i])
                    )
                    .opacity(blockerParticles[i] ? 0 : 0.8)
                    .blur(radius: CGFloat([0, 1, 0, 1, 0, 1, 0, 0, 1, 0][i]))
            }

            if blockerScanVisible {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.red.opacity(0.25), Color.red.opacity(0.5), Color.red.opacity(0.25), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 60)
                    .blur(radius: 8)
                    .offset(y: blockerScanLine)
            }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    Text("No more\ndoomscrolling.")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: Theme.blueAccent.opacity(0.5), radius: 20, y: 0)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 20)

                    ZStack {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            socialAppCard(icon: "play.rectangle.fill", name: "Videos", color: .red, index: 0)
                            socialAppCard(icon: "camera.fill", name: "Photos", color: .pink, index: 1)
                            socialAppCard(icon: "music.note", name: "Shorts", color: .cyan, index: 2)
                            socialAppCard(icon: "bubble.left.fill", name: "Social", color: .blue, index: 3)
                            socialAppCard(icon: "globe", name: "Browse", color: .purple, index: 4)
                            socialAppCard(icon: "newspaper.fill", name: "News", color: .orange, index: 5)
                        }
                        .scaleEffect(blockerCardsShrink ? 0.88 : 1.0)
                        .rotationEffect(.degrees(blockerCardsShake ? 1.5 : 0))

                        if blockerShieldAppear {
                            ZStack {
                                ForEach(0..<3, id: \.self) { ring in
                                    Circle()
                                        .strokeBorder(
                                            accentBlueBright.opacity(blockerShieldPulse ? 0.4 - Double(ring) * 0.12 : 0.1),
                                            lineWidth: CGFloat(3 - ring)
                                        )
                                        .frame(
                                            width: CGFloat(90 + ring * 50),
                                            height: CGFloat(90 + ring * 50)
                                        )
                                        .scaleEffect(blockerShieldPulse ? 1.15 : 0.9)
                                }

                                if blockerShieldRays {
                                    ForEach(0..<8, id: \.self) { ray in
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [accentBlueBright.opacity(0.6), Color.clear],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: 2, height: 60)
                                            .blur(radius: 3)
                                            .offset(y: -65)
                                            .rotationEffect(.degrees(Double(ray) * 45))
                                    }
                                }

                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                .white.opacity(0.25),
                                                accentBlueBright.opacity(0.15),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 160, height: 160)
                                    .scaleEffect(blockerShieldPulse ? 1.1 : 0.95)

                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 56))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white, accentBlueBright],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Theme.blueAccent.opacity(0.9), radius: 30)
                                    .shadow(color: .white.opacity(0.6), radius: 15)
                                    .shadow(color: accentBlueBright.opacity(0.5), radius: 50)
                            }
                            .transition(.scale(scale: 0.1).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 8)

                    VStack(spacing: 14) {
                        HStack(spacing: 8) {
                            Text("\u{1F319}")
                                .font(.system(size: 16))
                            Text("Every midnight, your social apps lock.")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 10)

                        Text("They unlock only when you\ncomplete your morning prayer.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .opacity(textReveal[2] ? 1 : 0)
                            .offset(y: textReveal[2] ? 0 : 10)

                        Text("Feed your soul, not the scroll.")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [accentBlueBright, Theme.primaryBright],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: accentBlueBright.opacity(0.5), radius: 12, y: 0)
                            .opacity(textReveal[3] ? 1 : 0)
                            .scaleEffect(textReveal[3] ? 1 : 0.85)
                    }
                }

                Spacer()

                VStack(spacing: 16) {
                    welcomePageIndicator(current: 20)

                    Button {
                        advance()
                    } label: {
                        Text("I Need This")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.08, green: 0.02, blue: 0.2))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                Capsule()
                                    .fill(.white)
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: [accentBlueBright.opacity(0.5), Theme.primary.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: .white.opacity(0.15), radius: 16, y: 6)
                    }
                    .opacity(textReveal[4] ? 1 : 0)
                    .offset(y: textReveal[4] ? 0 : 20)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            resetReveals()
            blockerAppsRevealed = 0
            blockerShieldAppear = false
            blockerStrikethrough = Array(repeating: false, count: 6)
            blockerCardsShake = false
            blockerScanLine = -200
            blockerScanVisible = false
            blockerShieldPulse = false
            blockerShieldRays = false
            blockerCardsShrink = false
            blockerParticles = Array(repeating: false, count: 10)
            blockerGlowPulse = false
            blockerVortex = false

            withAnimation(.easeOut(duration: 0.6).delay(0.2)) { textReveal[0] = true }

            for i in 0..<6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.12) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        blockerAppsRevealed = i + 1
                    }
                    let g = UIImpactFeedbackGenerator(style: .light)
                    g.impactOccurred(intensity: 0.5 + Double(i) * 0.1)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                blockerScanVisible = true
                withAnimation(.easeInOut(duration: 1.2)) {
                    blockerScanLine = 200
                }
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred(intensity: 0.7)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(
                    .easeInOut(duration: 0.08)
                    .repeatCount(12, autoreverses: true)
                ) {
                    blockerCardsShake = true
                }
                let g = UIImpactFeedbackGenerator(style: .heavy)
                g.impactOccurred()
            }

            for j in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 + Double(j) * 0.15) {
                    let g = UIImpactFeedbackGenerator(style: .rigid)
                    g.impactOccurred(intensity: 0.8 - Double(j) * 0.15)
                }
            }

            for i in 0..<6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8 + Double(i) * 0.12) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        blockerStrikethrough[i] = true
                    }
                    let g = UIImpactFeedbackGenerator(style: .rigid)
                    g.impactOccurred(intensity: 0.6)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                blockerScanVisible = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                withAnimation(.easeIn(duration: 0.4)) {
                    blockerCardsShrink = true
                }
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.9) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.5)) {
                    blockerShieldAppear = true
                }
                let n = UINotificationFeedbackGenerator()
                n.notificationOccurred(.success)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                withAnimation(.easeOut(duration: 0.4)) {
                    blockerShieldRays = true
                }
                let g = UIImpactFeedbackGenerator(style: .heavy)
                g.impactOccurred(intensity: 0.9)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    blockerShieldPulse = true
                    blockerGlowPulse = true
                }
            }

            for i in 0..<10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(
                        .easeOut(duration: Double.random(in: 2.5...4.0))
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.15)
                    ) {
                        blockerParticles[i] = true
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                withAnimation(.easeOut(duration: 0.5)) { textReveal[1] = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
                withAnimation(.easeOut(duration: 0.5)) { textReveal[2] = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.9) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { textReveal[3] = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
                withAnimation(.easeOut(duration: 0.5)) { textReveal[4] = true }
            }
        }
    }

    // MARK: - Screen 13: Family Controls

    private var familyControlsPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(Theme.blueAccent.opacity(0.08))
                        .frame(width: 140, height: 140)
                        .scaleEffect(textReveal[0] ? 1 : 0.5)

                    Group {
                        if familyControlsAuthorized {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(Theme.limeGreen)
                        } else {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(Theme.blueGradient)
                        }
                    }
                        .opacity(textReveal[0] ? 1 : 0)
                        .scaleEffect(textReveal[0] ? 1 : 0.3)
                        .contentTransition(.symbolEffect(.replace))
                }

                VStack(spacing: 14) {
                    Text(familyControlsAuthorized ? "Choose Apps to Block" : "Enable App Blocking")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 16)
                        .contentTransition(.opacity)

                    Text(familyControlsAuthorized
                         ? "Select which apps to pause each night\nuntil you complete your morning prayer."
                         : "GodFirst needs permission to\ntemporarily pause social media apps\neach night until your morning prayer.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 12)
                        .contentTransition(.opacity)
                }

                if !familyControlsAuthorized {
                    VStack(spacing: 12) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.blueAccent.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 17))
                                    .foregroundStyle(Theme.blueAccent)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Midnight")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Social apps pause automatically")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                        }

                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.limeGreen.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "sun.horizon.fill")
                                    .font(.system(size: 17))
                                    .foregroundStyle(Theme.limeGreen)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Morning")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Put God First \u{2192} apps unlock")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                        }

                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.skyBlue.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 17))
                                    .foregroundStyle(Theme.skyBlue)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Always in Control")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Disable anytime in settings")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Theme.cardBg)
                    )
                    .opacity(textReveal[3] ? 1 : 0)
                    .offset(y: textReveal[3] ? 0 : 12)

                    Button {
                        requestFamilyControls()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 16))
                            Text("Enable App Blocking")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.blueGradient))
                        .shadow(color: Theme.blueAccent.opacity(0.4), radius: 12, y: 6)
                    }
                    .opacity(textReveal[4] ? 1 : 0)
                } else {
                    Button {
                        showAppPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "app.badge.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Theme.blueAccent)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Select Apps to Block")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(appSelectionSummary)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary.opacity(0.5))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Theme.cardBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(Theme.blueAccent.opacity(0.3), lineWidth: 1.5)
                                )
                        )
                    }
                    .familyActivityPicker(
                        isPresented: $showAppPicker,
                        selection: $onboardingActivitySelection
                    )
                    .onChange(of: onboardingActivitySelection) { _, newValue in
                        ScreenTimeService.shared.activitySelection = newValue
                    }
                    .opacity(textReveal[3] ? 1 : 0)

                    Button {
                        ScreenTimeService.shared.activateGodFirstMode()
                        advance()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 16))
                            Text("Continue")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.blueGradient))
                        .shadow(color: Theme.blueAccent.opacity(0.4), radius: 12, y: 6)
                    }
                    .opacity(hasSelectedApps ? 1.0 : 0.4)
                    .disabled(!hasSelectedApps)
                    .opacity(textReveal[4] ? 1 : 0)
                }

                Button {
                    advance()
                } label: {
                    Text("Maybe Later")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .opacity(textReveal[4] ? 1 : 0)
            }

            Spacer()

            pageIndicator(current: 21)
                .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            familyControlsAuthorized = ScreenTimeService.shared.isAuthorized
            revealSequence(count: 5, baseDelay: 0.2, interval: 0.35)
        }
        .alert("Family Controls Unavailable", isPresented: $showAuthError) {
            Button("Continue Anyway") { advance() }
            Button("Try Again") { requestFamilyControls() }
        } message: {
            Text("Please make sure you are signed into iCloud in Settings and try again. If the issue persists, go to Settings > Screen Time and ensure Screen Time is enabled.")
        }
    }

    private var hasSelectedApps: Bool {
        !onboardingActivitySelection.applicationTokens.isEmpty || !onboardingActivitySelection.categoryTokens.isEmpty
    }

    private var appSelectionSummary: String {
        let count = onboardingActivitySelection.applicationTokens.count + onboardingActivitySelection.categoryTokens.count
        if count == 0 {
            return "Tap to choose apps & categories"
        }
        return "\(count) item\(count == 1 ? "" : "s") selected"
    }

    // MARK: - Screen 14: Notifications

    private var notificationPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    sunriseGold.opacity(bellGlowPulse ? 0.3 : 0.1),
                                    horizonWarm.opacity(bellGlowPulse ? 0.15 : 0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)

                    Text("\u{1F514}")
                        .font(.system(size: 90))
                        .shadow(color: sunriseGold.opacity(bellGlowPulse ? 0.7 : 0.3), radius: bellGlowPulse ? 25 : 10)
                        .scaleEffect(bellScale)
                        .offset(y: bellFloatOffset)
                        .rotationEffect(.degrees(bellSwing))
                }
                .frame(height: 200)
                .opacity(textReveal[0] ? 1 : 0)

                VStack(spacing: 14) {
                    Text("Stay Faithful")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 16)

                    Text("Don\u{2019}t forget to turn on notifications so we can remind you to put God first every day!")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 12)
                }

                Button {
                    NotificationService.requestPermission()
                    advance()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 16))
                            .symbolEffect(.bounce, value: bellRingPhase)
                        Text("Turn On Reminders")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(Theme.logoGradient))
                    .shadow(color: Theme.logoBlue.opacity(0.4), radius: 12, y: 6)
                }
                .opacity(textReveal[3] ? 1 : 0)

                Button {
                    advance()
                } label: {
                    Text("Maybe Later")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .opacity(textReveal[3] ? 1 : 0)
            }

            Spacer()

            pageIndicator(current: 28)
                .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            revealSequence(count: 4, baseDelay: 0.2, interval: 0.3)
            startBellAnimation()
        }
        .onDisappear {
            bellSwing = 0
            bellScale = 0
            bellGlowPulse = false
            bellRingPhase = 0
            bellRipples = Array(repeating: false, count: 4)
            bellSparkles = Array(repeating: false, count: 8)
            bellClapperSwing = 0
            bellShimmer = -1.0
            bellFloatOffset = 0
        }
    }

    private func startBellAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
            bellScale = 1.0
        }

        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            bellFloatOffset = -6
        }

        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.3)) {
            bellGlowPulse = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startBellRinging()
        }


    }

    private func startBellRinging() {
        func ringCycle() {
            let swingSequence: [(Double, Double)] = [
                (18, 0.12), (-14, 0.11), (10, 0.10), (-7, 0.09), (4, 0.08), (-2, 0.08), (0, 0.15)
            ]
            var totalDelay: Double = 0
            for (angle, duration) in swingSequence {
                let d = totalDelay
                DispatchQueue.main.asyncAfter(deadline: .now() + d) {
                    withAnimation(.spring(response: duration, dampingFraction: 0.35)) {
                        bellSwing = angle
                        bellClapperSwing = -angle / 18.0
                    }
                }
                totalDelay += duration + 0.02
            }

            bellRingPhase += 1

            for i in 0..<4 {
                let delay = Double(i) * 0.2
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    bellRipples[i] = false
                    withAnimation(.easeOut(duration: 1.2)) {
                        bellRipples[i] = true
                    }
                }
            }

            for i in 0..<8 {
                let delay = 0.1 + Double(i) * 0.06
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    bellSparkles[i] = false
                    withAnimation(.easeOut(duration: 0.8)) {
                        bellSparkles[i] = true
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                ringCycle()
            }
        }
        ringCycle()
    }

    // MARK: - Screen: Bible Alarm Onboarding

    @State private var bibleReadingFrequency: String = ""
    @State private var wantsToMemorize: String = ""
    @State private var scriptureFeatureReveal: [Bool] = Array(repeating: false, count: 4)
    @State private var scriptureOrbGlow: Bool = false
    @State private var scriptureOrbScale: CGFloat = 0

    private var bibleReadingQuizPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.28, green: 0.50, blue: 0.95).opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)

                    Text("\u{1F4D6}")
                        .font(.system(size: 80))
                        .shadow(color: sunriseGold.opacity(0.5), radius: 15)
                }
                .opacity(textReveal[0] ? 1 : 0)

                VStack(spacing: 8) {
                    Text("Quick question\u{2026}")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Help us personalize your Bible experience")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .multilineTextAlignment(.center)
                .opacity(textReveal[1] ? 1 : 0)
                .offset(y: textReveal[1] ? 0 : 14)

                VStack(alignment: .leading, spacing: 16) {
                    Text("How often do you read the Bible?")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    ForEach(["Every day", "A few times a week", "Once a week", "Rarely or never"], id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                bibleReadingFrequency = option
                            }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(bibleReadingFrequency == option ? Color.clear : Color(.separator).opacity(0.3), lineWidth: 1.5)
                                        .frame(width: 24, height: 24)
                                    if bibleReadingFrequency == option {
                                        Circle()
                                            .fill(Color(red: 0.28, green: 0.50, blue: 0.95))
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                Text(option)
                                    .font(.system(size: 15, weight: bibleReadingFrequency == option ? .semibold : .regular, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(bibleReadingFrequency == option ? Color(red: 0.28, green: 0.50, blue: 0.95).opacity(0.08) : Theme.cardBg)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(bibleReadingFrequency == option ? Color(red: 0.28, green: 0.50, blue: 0.95).opacity(0.3) : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .opacity(textReveal[2] ? 1 : 0)
                .offset(y: textReveal[2] ? 0 : 16)
            }
            .padding(.horizontal, 28)

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 15)

                onboardingButton("Continue") {
                    ScriptureUnlockService.shared.bibleReadingFrequency = bibleReadingFrequency
                    advance()
                }
                .opacity(!bibleReadingFrequency.isEmpty ? 1 : 0.5)
                .disabled(bibleReadingFrequency.isEmpty)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 50)
        }
        .onAppear {
            revealSequence(count: 4, baseDelay: 0.2, interval: 0.25)
        }
    }

    private var memorizeScripturePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    sunriseGold.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)

                    Text("\u{1F9E0}")
                        .font(.system(size: 80))
                        .shadow(color: sunriseGold.opacity(0.5), radius: 15)
                }
                .opacity(textReveal[0] ? 1 : 0)

                VStack(spacing: 8) {
                    Text("One more thing\u{2026}")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    Text("God\u{2019}s Word transforms when you carry it with you")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }
                .multilineTextAlignment(.center)
                .opacity(textReveal[1] ? 1 : 0)
                .offset(y: textReveal[1] ? 0 : 14)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Do you want to memorize scripture this year?")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    ForEach(["Yes \u{2014} I\u{2019}d love that!", "Maybe \u{2014} I\u{2019}d like to try", "Not sure yet"], id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                wantsToMemorize = option
                            }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(wantsToMemorize == option ? Color.clear : Color(.separator).opacity(0.3), lineWidth: 1.5)
                                        .frame(width: 24, height: 24)
                                    if wantsToMemorize == option {
                                        Circle()
                                            .fill(sunriseGold)
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                Text(option)
                                    .font(.system(size: 15, weight: wantsToMemorize == option ? .semibold : .regular, design: .rounded))
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(wantsToMemorize == option ? sunriseGold.opacity(0.08) : Theme.cardBg)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(wantsToMemorize == option ? sunriseGold.opacity(0.3) : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .opacity(textReveal[2] ? 1 : 0)
                .offset(y: textReveal[2] ? 0 : 16)
            }
            .padding(.horizontal, 28)

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 16)

                onboardingButton("See How It Works") {
                    ScriptureUnlockService.shared.wantToMemorize = wantsToMemorize.contains("Yes") || wantsToMemorize.contains("Maybe")
                    if wantsToMemorize.contains("Yes") || wantsToMemorize.contains("Maybe") {
                        ScriptureUnlockService.shared.isEnabled = true
                    }
                    advance()
                }
                .opacity(!wantsToMemorize.isEmpty ? 1 : 0.5)
                .disabled(wantsToMemorize.isEmpty)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 50)
        }
        .onAppear {
            revealSequence(count: 4, baseDelay: 0.2, interval: 0.25)
        }
    }

    private var scriptureUnlockFeaturesPage: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)

                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.52, green: 0.35, blue: 0.95).opacity(scriptureOrbGlow ? 0.35 : 0.08),
                                        Color(red: 0.42, green: 0.28, blue: 0.82).opacity(scriptureOrbGlow ? 0.18 : 0.03),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 140
                                )
                            )
                            .frame(width: 280, height: 280)
                            .blur(radius: 30)

                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 90))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.52, green: 0.35, blue: 0.95), Color(red: 0.62, green: 0.45, blue: 1.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Color(red: 0.52, green: 0.35, blue: 0.95).opacity(scriptureOrbGlow ? 0.8 : 0.3), radius: scriptureOrbGlow ? 25 : 10)
                            .scaleEffect(scriptureOrbScale)
                    }
                    .frame(height: 220)
                    .opacity(textReveal[0] ? 1 : 0)

                    VStack(spacing: 10) {
                        Text("Learn & Memorize Scripture")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 16)

                        Text("Take a break from distractions.\nSpeak God's Word and refocus.")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.52, green: 0.35, blue: 0.95), Color(red: 0.62, green: 0.45, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 16)
                    }
                    .multilineTextAlignment(.center)

                    scriptureUnlockDemoCard
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 20)

                    VStack(spacing: 10) {
                        scriptureFeatureItem(
                            icon: "mic.fill",
                            title: "Speak God's Word",
                            subtitle: "Recite a verse aloud to refocus on what matters",
                            color: Color(red: 0.52, green: 0.35, blue: 0.95),
                            index: 0
                        )
                        scriptureFeatureItem(
                            icon: "brain",
                            title: "Memorize Scripture Daily",
                            subtitle: "Build lasting Bible knowledge one verse at a time",
                            color: sunriseGold,
                            index: 1
                        )
                        scriptureFeatureItem(
                            icon: "pause.circle.fill",
                            title: "Pause Social Distractions",
                            subtitle: "Step away from apps and focus on God instead",
                            color: Theme.successEmerald,
                            index: 2
                        )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 20)
            }

            VStack(spacing: 16) {
                pageIndicator(current: 17)

                onboardingButton("I'm Ready") {
                    advance()
                }
                .opacity(textReveal[5] ? 1 : 0)
                .scaleEffect(textReveal[5] ? 1 : 0.95)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 50)
        }
        .onAppear {
            revealSequence(count: 7, baseDelay: 0.2, interval: 0.25)
            startScriptureOnboardingAnimation()
        }
        .onDisappear {
            scriptureOrbScale = 0
            scriptureOrbGlow = false
            scriptureFeatureReveal = Array(repeating: false, count: 4)
        }
    }

    private var scriptureUnlockDemoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.06, blue: 0.16),
                            Color(red: 0.12, green: 0.08, blue: 0.22)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 0.52, green: 0.35, blue: 0.95))
                    Text("APPS LOCKED")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Color(red: 0.52, green: 0.35, blue: 0.95))
                }

                VStack(spacing: 4) {
                    Text("\u{201C}Trust in the Lord with all")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("your heart...\u{201D}")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\u{2014} Proverbs 3:5")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(sunriseGold.opacity(0.8))
                        .padding(.top, 4)
                }

                HStack(spacing: 8) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(sunriseGold)
                    Text("Read aloud to unlock")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.vertical, 24)
        }
        .frame(height: 200)
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.52, green: 0.35, blue: 0.95).opacity(0.4), sunriseGold.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color(red: 0.52, green: 0.35, blue: 0.95).opacity(0.15), radius: 20, y: 8)
    }

    private func scriptureFeatureItem(icon: String, title: String, subtitle: String, color: Color, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Theme.limeGreen.opacity(0.8))
                .scaleEffect(scriptureFeatureReveal[index] ? 1 : 0)
                .opacity(scriptureFeatureReveal[index] ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.cardBg)
                .shadow(color: color.opacity(0.06), radius: 8, y: 2)
        )
        .opacity(textReveal[min(3 + index, textReveal.count - 1)] ? 1 : 0)
        .offset(y: textReveal[min(3 + index, textReveal.count - 1)] ? 0 : 14)
    }

    private func startScriptureOnboardingAnimation() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            scriptureOrbScale = 1.0
        }

        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) {
            scriptureOrbGlow = true
        }

        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2 + Double(i) * 0.25) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scriptureFeatureReveal[i] = true
                }
            }
        }
    }

    // MARK: - Screen 13: Trial Invitation

    private var trialInvitePage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    VStack(spacing: 6) {
                        Text("Your first session is")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)

                        Text("FREE.")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.limeGreen, Color(red: 0.2, green: 0.95, blue: 0.6), Theme.limeGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Theme.limeGreen.opacity(0.7), radius: 16)
                            .shadow(color: Theme.limeGreen.opacity(0.3), radius: 32)
                    }
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 18)

                    Text("Start putting God first now.")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 14)
                }

                VStack(spacing: 12) {
                    trialMiniCard(
                        headerColors: [Color(red: 0.96, green: 0.40, blue: 0.35), Color(red: 1.0, green: 0.62, blue: 0.45)],
                        icon: "book.fill",
                        label: "VERSE OF THE DAY",
                        preview: "\u{201C}In the morning, Lord, you hear my voice...\u{201D}",
                        index: 2
                    )
                    trialMiniCard(
                        headerColors: [Color(red: 0.28, green: 0.50, blue: 0.95), Color(red: 0.50, green: 0.65, blue: 1.0)],
                        icon: "text.book.closed.fill",
                        label: "TODAY\u{2019}S DEVOTIONAL",
                        preview: "A short reflection to start your day with God.",
                        index: 3
                    )
                    trialMiniCard(
                        headerColors: [Theme.icePurple, Theme.iceBlue],
                        icon: "hands.sparkles.fill",
                        label: "GUIDED PRAYER",
                        preview: "A personal prayer time to close your session.",
                        index: 4
                    )
                }
                .padding(.top, 4)

                Text("Then decide if this is for you.")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(sunriseGold.opacity(0.85))
                    .italic()
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[5] ? 1 : 0)
                    .offset(y: textReveal[5] ? 0 : 8)
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 22)

                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showTrialSession = true
                    }
                } label: {
                    ZStack {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [sunriseGold, horizonWarm, sunrisePeach],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: sunriseGold.opacity(0.4), radius: 20, y: 8)
                            .shadow(color: horizonWarm.opacity(0.2), radius: 10, y: 4)

                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("Start My Free Session")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
                .opacity(textReveal[6] ? 1 : 0)
                .scaleEffect(textReveal[6] ? 1 : 0.92)

                Text("No account needed \u{2022} Takes 3 minutes")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary.opacity(0.6))
                    .opacity(textReveal[6] ? 1 : 0)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            revealSequence(count: 7, baseDelay: 0.3, interval: 0.3)
            startTrialInviteAnimation()
        }
        .onDisappear {
            trialOrbScale = 0.3
            trialOrbGlow = false
            trialRaysRotation = 0
            trialRaysVisible = false
            trialParticles = Array(repeating: false, count: 10)
            trialPulseRing1 = 0.6
            trialPulseRing2 = 0.5
            trialPulseRing3 = 0.4
            trialRingOpacity1 = 0
            trialRingOpacity2 = 0
            trialRingOpacity3 = 0
            trialIconFloat = 0
            trialDoveReveal = false
            trialLightBurst = false
            trialEmberPhase = false
            trialHaloBreath = false
            trialRipple1 = 0.3
            trialRipple2 = 0.3
            trialRipple3 = 0.3
            trialRippleOp1 = 0
            trialRippleOp2 = 0
            trialRippleOp3 = 0
            trialButtonShimmer = -0.5
        }
    }

    private func trialFeatureRow(icon: String, label: String, color: Color, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(color)
            }

            Text(label)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Theme.limeGreen.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.cardBg)
                .shadow(color: color.opacity(0.06), radius: 8, y: 2)
        )
        .opacity(textReveal[index] ? 1 : 0)
        .offset(y: textReveal[index] ? 0 : 14)
    }

    private func trialMiniCard(headerColors: [Color], icon: String, label: String, preview: String, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: headerColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            Text(preview)
                .font(.system(size: 14, weight: .regular, design: .serif))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(4)
                .lineLimit(2)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Theme.cardBg)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(headerColors.first?.opacity(0.3) ?? Color.clear, lineWidth: 1)
        )
        .shadow(color: headerColors.first?.opacity(0.12) ?? Color.clear, radius: 8, y: 4)
        .opacity(textReveal[index] ? 1 : 0)
        .offset(y: textReveal[index] ? 0 : 14)
    }

    private func startTrialInviteAnimation() {
        withAnimation(.spring(response: 0.9, dampingFraction: 0.65).delay(0.15)) {
            trialOrbScale = 1.0
        }

        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            trialLightBurst = true
        }

        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4)) {
            trialDoveReveal = true
        }

        withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
            trialRippleOp1 = 0.8
            trialRipple1 = 1.0
        }
        withAnimation(.easeOut(duration: 1.0).delay(0.7)) {
            trialRippleOp2 = 0.5
            trialRipple2 = 1.0
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            trialRippleOp3 = 0.35
            trialRipple3 = 1.0
        }

        withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
            trialRaysRotation = 360
        }

        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.5)) {
            trialOrbGlow = true
        }

        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(0.6)) {
            trialHaloBreath = true
        }

        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            trialIconFloat = -10
        }

        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.5)) {
            trialRipple1 = 1.06
        }
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1.7)) {
            trialRipple2 = 1.05
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.9)) {
            trialRipple3 = 1.04
        }

        func shimmerCycle() {
            trialButtonShimmer = -0.5
            withAnimation(.easeInOut(duration: 1.8)) {
                trialButtonShimmer = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                shimmerCycle()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            shimmerCycle()
        }

        func emberCycle() {
            withAnimation(.easeIn(duration: 3.0)) {
                trialEmberPhase = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                trialEmberPhase = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    emberCycle()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            emberCycle()
        }
    }

    // MARK: - Screen 14: Session End

    private var sessionEndPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [sunriseGold.opacity(warmIconGlow ? 0.22 : 0.08), Theme.limeGreen.opacity(0.06), Color.clear],
                                center: .center, startRadius: 10, endRadius: 80
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(textReveal[0] ? (warmIconGlow ? 1.1 : 0.95) : 0.5)

                    if sessionConfetti {
                        ForEach(0..<16, id: \.self) { i in
                            ConfettiParticle(index: i)
                        }
                    }

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(colors: [sunriseGold, Theme.limeGreen], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: sunriseGold.opacity(0.4), radius: 12)
                        .opacity(textReveal[0] ? 1 : 0)
                        .scaleEffect(textReveal[0] ? 1 : 0.3)
                        .symbolEffect(.bounce, value: sessionConfetti)
                }

                VStack(spacing: 14) {
                    Text("This is what putting\nGod first feels like.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 16)

                    Text("Imagine starting every day like this.\nYour heart at peace. Your mind clear.\nYour spirit alive.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(textReveal[2] ? 1 : 0)
                        .offset(y: textReveal[2] ? 0 : 12)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 23)

                onboardingButton("See My Full Journey") {
                    advance()
                }
                .opacity(textReveal[3] ? 1 : 0)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            revealSequence(count: 4, baseDelay: 0.3, interval: 0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    sessionConfetti = true
                }
                let notif = UINotificationFeedbackGenerator()
                notif.notificationOccurred(.success)
            }
        }
    }

    // MARK: - Screen 15: Transformation + 7 Day Path

    private let journeyDays: [(icon: String, label: String)] = [
        ("door.left.hand.open", "Secret Place"),
        ("shield.fill", "Resistance"),
        ("ear.fill", "Hearing God"),
        ("bolt.fill", "Authority"),
        ("hands.sparkles.fill", "Surrender"),
        ("person.2.fill", "Intercession"),
        ("crown.fill", "God First")
    ]

    private var journeyDayColors: [Color] {
        [sunriseGold, horizonWarm, sunrisePeach, Theme.skyBlue, Theme.lavender, Theme.mint, Theme.limeGreen]
    }

    private var journeyOrbitRing: some View {
        let radius: CGFloat = 115
        return ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: 2)
                .frame(width: radius * 2, height: radius * 2)

            Circle()
                .trim(from: 0, to: CGFloat(dayPathRevealed) / 7.0)
                .stroke(
                    LinearGradient(
                        colors: [sunriseGold.opacity(0.5), Theme.limeGreen.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: radius * 2, height: radius * 2)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: dayPathRevealed)
        }
        .opacity(textReveal[2] ? 1 : 0)
        .scaleEffect(textReveal[2] ? 1 : 0.7)
    }

    private var journeyCenterOrb: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [sunriseGold.opacity(pathGlowPulse ? 0.25 : 0.1), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 50
                    )
                )
                .frame(width: 80, height: 80)

            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(sunriseGold)
                .symbolEffect(.pulse, options: .repeating, isActive: dayPathRevealed >= 7)
        }
        .opacity(textReveal[2] ? 1 : 0)
        .scaleEffect(textReveal[2] ? 1 : 0.3)
    }

    private func journeyDayNode(index: Int) -> some View {
        let radius: CGFloat = 115
        let angle: Double = -(.pi / 2) + (2 * .pi / 7) * Double(index)
        let x: CGFloat = radius * cos(angle)
        let y: CGFloat = radius * sin(angle)
        let isRevealed: Bool = (index + 1) <= dayPathRevealed
        let dayColor: Color = journeyDayColors[index]
        let dayInfo = journeyDays[index]

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(dayColor.opacity(isRevealed ? 0.2 : 0.04))
                    .frame(width: 44, height: 44)

                Circle()
                    .strokeBorder(dayColor.opacity(isRevealed ? 0.5 : 0.12), lineWidth: 1.5)
                    .frame(width: 44, height: 44)

                if isRevealed {
                    Image(systemName: dayInfo.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(dayColor)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary.opacity(0.25))
                }
            }

            Text(dayInfo.label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(isRevealed ? dayColor : Theme.textSecondary.opacity(0.25))
                .lineLimit(1)
        }
        .offset(x: x, y: y)
        .scaleEffect(isRevealed ? 1 : 0.7)
        .opacity(textReveal[2] ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: dayPathRevealed)
    }

    private var transformationPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                Text("Your 7-Day Journey")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 16)

                Text("Meet with God daily\u{2014}one step at a time.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[1] ? 1 : 0)
                    .offset(y: textReveal[1] ? 0 : 12)
            }

            Spacer().frame(height: 24)

            ZStack {
                journeyOrbitRing
                journeyCenterOrb
                ForEach(0..<7, id: \.self) { i in
                    journeyDayNode(index: i)
                }
            }
            .frame(height: 300)

            Spacer().frame(height: 20)

            VStack(spacing: 4) {
                Text("\u{201C}Seek first the kingdom of God\u{201D}")
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(sunriseGold)
                    .italic()
                    .multilineTextAlignment(.center)
                Text("\u{2014} Matthew 6:33")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(sunriseGold.opacity(0.5))
            }
            .opacity(dayPathRevealed >= 7 ? 1 : 0)
            .offset(y: dayPathRevealed >= 7 ? 0 : 8)
            .animation(.easeOut(duration: 0.5), value: dayPathRevealed)

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 24)

                onboardingButton("Continue") {
                    advance()
                }
                .opacity(dayPathRevealed >= 7 ? 1 : 0)
                .scaleEffect(dayPathRevealed >= 7 ? 1 : 0.95)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: dayPathRevealed)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            resetReveals()
            dayPathRevealed = 0
            pathGlowPulse = false

            withAnimation(.easeOut(duration: 0.6)) { textReveal[0] = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) { textReveal[1] = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) { textReveal[2] = true }

            for i in 0..<7 {
                let delay = 1.0 + Double(i) * 0.25
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        dayPathRevealed = i + 1
                    }
                    let impact = UIImpactFeedbackGenerator(style: i == 6 ? .heavy : .light)
                    impact.impactOccurred()
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    pathGlowPulse = true
                }
            }
        }
    }

    // MARK: - Screen 16: Pricing (Must Choose)

    private var pricingPage: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                VStack(spacing: 24) {
                    VStack(spacing: 14) {
                        pricingFlameAnimation
                            .opacity(textReveal[0] ? 1 : 0)
                            .scaleEffect(textReveal[0] ? 1 : 0.3)

                        Text("Start Your Journey")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .opacity(textReveal[1] ? 1 : 0)
                            .offset(y: textReveal[1] ? 0 : 16)

                        Text("Block distracting apps until you\nspend time with God each morning.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .opacity(textReveal[2] ? 1 : 0)
                    }

                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.limeGreen)
                            Text("\(trialText.uppercased()) \u{2014} You won\u{2019}t be charged today!")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.limeGreen)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Theme.limeGreen.opacity(0.1))
                        )

                        HStack(spacing: 6) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.blueAccent)
                            Text("TikTok, Instagram, X \u{2014} locked until you pray")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.blueAccent)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Theme.blueAccent.opacity(0.08))
                        )
                    }
                    .opacity(textReveal[3] ? 1 : 0)
                    .scaleEffect(textReveal[3] ? 1 : 0.9)

                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedPlan = .weekly }
                        } label: {
                            VStack(spacing: 0) {
                                if selectedPlan == .weekly {
                                    Text("\(trialText.uppercased())")
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Theme.limeGreen))
                                        .offset(y: -12)
                                        .zIndex(1)
                                        .transition(.scale.combined(with: .opacity))
                                }

                                VStack(spacing: 8) {
                                    if selectedPlan != .weekly {
                                        Spacer().frame(height: 4)
                                    }
                                    Text("Weekly")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.textPrimary)
                                    Text("\(weeklyPriceString)/week")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Theme.textSecondary)
                                    Spacer().frame(height: 4)
                                    Image(systemName: selectedPlan == .weekly ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 26))
                                        .foregroundStyle(selectedPlan == .weekly ? Theme.logoIndigo : Theme.textSecondary.opacity(0.3))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, selectedPlan == .weekly ? 6 : 20)
                                .padding(.bottom, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Theme.cardBg)
                                    if selectedPlan == .weekly {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Theme.logoIndigo.opacity(0.06))
                                    }
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(
                                            selectedPlan == .weekly
                                                ? LinearGradient(colors: [Theme.logoBlue, Theme.logoPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                : LinearGradient(colors: [Theme.textSecondary.opacity(0.15)], startPoint: .top, endPoint: .bottom),
                                            lineWidth: selectedPlan == .weekly ? 2.5 : 1
                                        )
                                }
                            )
                            .shadow(color: selectedPlan == .weekly ? Theme.logoIndigo.opacity(0.25) : .clear, radius: 12, y: 4)
                        }

                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedPlan = .yearly }
                        } label: {
                            VStack(spacing: 0) {
                                Text("BEST DEAL")
                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(LinearGradient(colors: [Theme.dawnGold, Theme.dawnAmber], startPoint: .leading, endPoint: .trailing)))
                                    .offset(y: -12)
                                    .zIndex(1)

                                VStack(spacing: 8) {
                                    Text("Yearly")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.textPrimary)
                                    Text("\(annualPerWeekString)/week")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Theme.textSecondary)
                                    Spacer().frame(height: 4)
                                    Image(systemName: selectedPlan == .yearly ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 26))
                                        .foregroundStyle(selectedPlan == .yearly ? Theme.logoIndigo : Theme.textSecondary.opacity(0.3))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, selectedPlan == .yearly ? 6 : 20)
                                .padding(.bottom, 16)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Theme.cardBg)
                                    if selectedPlan == .yearly {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Theme.logoIndigo.opacity(0.06))
                                    }
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(
                                            selectedPlan == .yearly
                                                ? LinearGradient(colors: [Theme.logoBlue, Theme.logoPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                : LinearGradient(colors: [Theme.textSecondary.opacity(0.15)], startPoint: .top, endPoint: .bottom),
                                            lineWidth: selectedPlan == .yearly ? 2.5 : 1
                                        )
                                }
                            )
                            .shadow(color: selectedPlan == .yearly ? Theme.logoIndigo.opacity(0.25) : .clear, radius: 12, y: 4)
                        }
                    }
                    .opacity(textReveal[4] ? 1 : 0)
                    .offset(y: textReveal[4] ? 0 : 16)

                }

                noPaymentDueNowCard
                    .opacity(textReveal[4] ? 1 : 0)
                    .padding(.top, 16)

                onboardingWhyThisWorksCard
                    .opacity(textReveal[4] ? 1 : 0)
                    .padding(.top, 12)

                Spacer().frame(height: 8)

                VStack(spacing: 12) {
                    Button {
                        Task { await handleOnboardingPurchase() }
                    } label: {
                        Group {
                            if isPurchasing || subscriptionService.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Start My Free 3 Days")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Capsule().fill(
                                selectedPackage != nil
                                    ? LinearGradient(colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                            )
                        )
                        .shadow(color: selectedPackage != nil ? Theme.logoIndigo.opacity(0.4) : .clear, radius: 12, y: 6)
                    }
                    .disabled(isPurchasing || isRestoringPurchases || subscriptionService.isLoading || selectedPackage == nil)
                    .opacity(selectedPackage == nil && !subscriptionService.isLoading ? 0.6 : 1)
                    .opacity(textReveal[4] ? 1 : 0)

                    Text(selectedPlanPricingDetail)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.2), value: selectedPlan)

                    if let lifetimePkg = subscriptionService.lifetimePackage {
                        Button {
                            Task { await handleOnboardingLifetimePurchase() }
                        } label: {
                            HStack(spacing: 6) {
                                if isPurchasingLifetime {
                                    ProgressView()
                                        .tint(Theme.dawnGold)
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "infinity")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Theme.dawnGold)
                                    Text("Lifetime Access \(lifetimePkg.storeProduct.localizedPriceString)")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Theme.textPrimary)
                                    Text("one-time")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(
                                Capsule()
                                    .fill(Theme.dawnGold.opacity(0.08))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Theme.dawnGold.opacity(0.25), lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(isPurchasing || isRestoringPurchases || isPurchasingLifetime)
                    }

                    Text(onboardingDisclosureText)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(Theme.textSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)

                    Button {
                        Task { await handleOnboardingRestore() }
                    } label: {
                        HStack(spacing: 6) {
                            if isRestoringPurchases {
                                ProgressView()
                                    .tint(Theme.blueAccent)
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 13))
                            }
                            Text("Already subscribed? Restore")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Theme.blueAccent)
                    }
                    .disabled(isPurchasing || isRestoringPurchases)

                    HStack(spacing: 20) {
                        Link("Privacy", destination: URL(string: "https://www.putgodfirstapp.com/privacy")!)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.textSecondary.opacity(0.6))
                        Link("Terms", destination: URL(string: "https://www.putgodfirstapp.com/terms")!)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.textSecondary.opacity(0.6))
                    }
                }
                .padding(.bottom, 50)
                .alert("Purchase Error", isPresented: $showPurchaseError) {
                    Button("OK") {}
                } message: {
                    Text(purchaseError)
                }
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            revealSequence(count: 5, baseDelay: 0.2, interval: 0.3)
        }
        .task {
            await subscriptionService.fetchOfferings()
        }
    }

    private var selectedPlanPricingDetail: String {
        if selectedPlan == .yearly {
            if let pkg = annualPackage, let intro = pkg.storeProduct.introductoryDiscount {
                let val = intro.subscriptionPeriod.value
                let unitStr: String
                switch intro.subscriptionPeriod.unit {
                case .day: unitStr = "\(val) days"
                case .week: unitStr = "\(val) weeks"
                case .month: unitStr = "\(val) months"
                default: unitStr = ""
                }
                if !unitStr.isEmpty {
                    return "\(unitStr) free, then just \(annualPerWeekString)/week"
                }
            }
            return "3 days free, then just \(annualPerWeekString)/week"
        } else {
            if let pkg = weeklyPackage, let intro = pkg.storeProduct.introductoryDiscount {
                let val = intro.subscriptionPeriod.value
                let unitStr: String
                switch intro.subscriptionPeriod.unit {
                case .day: unitStr = "\(val) days"
                case .week: unitStr = "\(val) weeks"
                case .month: unitStr = "\(val) months"
                default: unitStr = ""
                }
                if !unitStr.isEmpty {
                    return "\(unitStr) free, then \(weeklyPriceString)/week"
                }
            }
            return "3 days free, then \(weeklyPriceString)/week"
        }
    }

    private var pricingSummaryText: String {
        if let pkg = selectedPackage, let intro = pkg.storeProduct.introductoryDiscount {
            let val = intro.subscriptionPeriod.value
            let unitStr: String
            switch intro.subscriptionPeriod.unit {
            case .day: unitStr = "\(val) days"
            case .week: unitStr = "\(val) weeks"
            case .month: unitStr = "\(val) months"
            default: unitStr = ""
            }
            if !unitStr.isEmpty {
                return "\(unitStr) free, then \(weeklyPriceString)/week or \(annualPriceString)/year (\(annualPerWeekString)/week)"
            }
        }
        return "3 days free, then \(weeklyPriceString)/week or \(annualPriceString)/year (\(annualPerWeekString)/week)"
    }

    private var onboardingPurchaseButtonTitle: String {
        guard let pkg = selectedPackage else { return "Subscribe" }
        if let intro = pkg.storeProduct.introductoryDiscount {
            let val = intro.subscriptionPeriod.value
            switch intro.subscriptionPeriod.unit {
            case .day: return "Start My \(val)-Day Free Trial"
            case .week: return "Start My \(val)-Week Free Trial"
            case .month: return "Start My \(val)-Month Free Trial"
            default: return "Start My Free Trial"
            }
        }
        let price = pkg.storeProduct.localizedPriceString
        let period = selectedPlan == .yearly ? "year" : "week"
        return "Subscribe \(price)/\(period)"
    }

    private var onboardingSubscriptionSummary: String {
        guard let pkg = selectedPackage else { return "" }
        let price = pkg.storeProduct.localizedPriceString
        let period = selectedPlan == .yearly ? "year" : "week"
        if let intro = pkg.storeProduct.introductoryDiscount {
            let val = intro.subscriptionPeriod.value
            let unitStr: String
            switch intro.subscriptionPeriod.unit {
            case .day: unitStr = "\(val)-day"
            case .week: unitStr = "\(val)-week"
            case .month: unitStr = "\(val)-month"
            default: unitStr = ""
            }
            if !unitStr.isEmpty {
                return "\(unitStr) free trial, then \(price)/\(period)"
            }
        }
        return "\(price)/\(period) • auto-renewable subscription"
    }

    private var onboardingDisclosureText: String {
        guard let pkg = selectedPackage else {
            return "Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Manage subscriptions in Settings."
        }
        let price = pkg.storeProduct.localizedPriceString
        let period = selectedPlan == .yearly ? "year" : "week"
        var text = "Payment of \(price)/\(period) will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Manage subscriptions in your device Settings."
        if let intro = pkg.storeProduct.introductoryDiscount {
            let val = intro.subscriptionPeriod.value
            let unitStr: String
            switch intro.subscriptionPeriod.unit {
            case .day: unitStr = "\(val)-day"
            case .week: unitStr = "\(val)-week"
            case .month: unitStr = "\(val)-month"
            default: unitStr = ""
            }
            if !unitStr.isEmpty {
                text = "Start your \(unitStr) free trial. After the trial, " + text.prefix(1).lowercased() + text.dropFirst()
            }
        }
        return text
    }

    private func handleOnboardingPurchase() async {
        guard let pkg = selectedPackage else {
            if subscriptionService.isLoading {
                return
            }
            await subscriptionService.fetchOfferings()
            if selectedPackage == nil {
                purchaseError = "Unable to load subscription options. Please check your internet connection and try again."
                showPurchaseError = true
            }
            return
        }
        isPurchasing = true
        let success = await subscriptionService.purchase(package: pkg)
        isPurchasing = false
        if success {
            completeOnboarding()
        } else if let err = subscriptionService.errorMessage {
            purchaseError = err
            showPurchaseError = true
            subscriptionService.errorMessage = nil
        }
    }

    private func handleOnboardingLifetimePurchase() async {
        guard let pkg = subscriptionService.lifetimePackage else { return }
        isPurchasingLifetime = true
        let success = await subscriptionService.purchase(package: pkg)
        isPurchasingLifetime = false
        if success {
            completeOnboarding()
        } else if let err = subscriptionService.errorMessage {
            purchaseError = err
            showPurchaseError = true
            subscriptionService.errorMessage = nil
        }
    }

    private func handleOnboardingRestore() async {
        isRestoringPurchases = true
        let success = await subscriptionService.restorePurchases()
        isRestoringPurchases = false
        if success {
            completeOnboarding()
        } else {
            purchaseError = "No active subscription found. Please subscribe to continue."
            showPurchaseError = true
            subscriptionService.errorMessage = nil
        }
    }

    private func completeOnboarding() {
        viewModel.journeyStyle = .guided
        viewModel.showAppBlockingSetup = true
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.hasCompletedOnboarding = true
        }
    }

    private var pricingFlameAnimation: some View {
        AnimatedFlameView()
    }

    private var noPaymentDueNowCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.limeGreen)
                Text("No Payment Due Now")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 12) {
                trustBullet(icon: "checkmark.seal.fill", color: Theme.limeGreen, text: "You won\u{2019}t be charged for 3 days")
                trustBullet(icon: "arrow.counterclockwise", color: Theme.dawnGold, text: "Cancel anytime, no questions asked")
                trustBullet(icon: "bell.badge.fill", color: Theme.blueAccent, text: "We\u{2019}ll remind you before trial ends")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Theme.textSecondary.opacity(0.12), lineWidth: 1)
                    )
            )
        }
    }

    private func trustBullet(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var onboardingWhyThisWorksCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.blueAccent)
                Text("Why it works")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
            }

            Text("Your social apps stay locked until you\u{2019}ve spent time with God. No willpower needed \u{2014} the app does the hard part for you.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Text("Stop doom-scrolling. Start God-seeking.")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.dawnGold)
                .italic()
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.textSecondary.opacity(0.12), lineWidth: 1)
                )
        )
    }

    // MARK: - What Does It Do

    private var whatDoesItDoPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                Text("WHAT DOES IT DO?")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(2)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 10)

                Group {
                    Text("Before you scroll,\nPut God First locks\nyour apps until you\n")
                        .foregroundColor(Theme.textPrimary)
                    + Text("pause for Scripture")
                        .foregroundColor(Theme.amber)
                }
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .opacity(textReveal[1] ? 1 : 0)
                .offset(y: textReveal[1] ? 0 : 20)
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 5)

                onboardingButton("Continue") {
                    advance()
                }
                .opacity(textReveal[1] ? 1 : 0)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 2, baseDelay: 0.3, interval: 0.6) }
    }

    // MARK: - Phone Hours

    private var phoneHoursPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Text("How many hours a day\ndo you spend on\nyour phone?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 16)

                VStack(spacing: 10) {
                    phoneHourOption("2 hours or less", value: 2)
                    phoneHourOption("3\u{2013}4 hours", value: 4)
                    phoneHourOption("4\u{2013}6 hours", value: 5)
                    phoneHourOption("6\u{2013}8 hours", value: 7)
                    phoneHourOption("8+ hours", value: 9)
                }
                .opacity(textReveal[1] ? 1 : 0)
                .offset(y: textReveal[1] ? 0 : 12)
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 7)

                onboardingButton("Continue") {
                    advance()
                }
                .opacity(selectedPhoneHours > 0 ? 1.0 : 0.5)
                .disabled(selectedPhoneHours == 0)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear { revealSequence(count: 2, baseDelay: 0.2, interval: 0.3) }
    }

    private func phoneHourOption(_ label: String, value: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPhoneHours = value
            }
            typingHaptic()
        } label: {
            HStack {
                Text(label)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if selectedPhoneHours == value {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.blueAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedPhoneHours == value ? Theme.blueAccent.opacity(0.08) : Theme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(selectedPhoneHours == value ? Theme.blueAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
    }

    // MARK: - Phone Stats

    private var phoneStatsPage: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                Group {
                    Text("You\u{2019}ll spend ")
                        .foregroundColor(Theme.textPrimary)
                    + Text("\(Int(statsCountUpHours).formatted(.number)) hours")
                        .foregroundColor(Theme.coral)
                    + Text("\non your phone this year.")
                        .foregroundColor(Theme.textPrimary)
                }
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .opacity(textReveal[0] ? 1 : 0)
                .offset(y: textReveal[0] ? 0 : 16)
                .animation(.easeOut(duration: 0.5), value: textReveal[0])

                Group {
                    Text("That\u{2019}s ")
                        .foregroundColor(Theme.textPrimary)
                    + Text("\(Int(statsCountUpDays)) full days")
                        .foregroundColor(Theme.coral)
                    + Text(" this year alone.")
                        .foregroundColor(Theme.textPrimary)
                }
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .opacity(textReveal[1] ? 1 : 0)
                .offset(y: textReveal[1] ? 0 : 16)
                .animation(.easeOut(duration: 0.5), value: textReveal[1])

                Group {
                    Text("Over your lifetime, that\u{2019}s ")
                        .foregroundColor(Theme.textPrimary)
                    + Text("\(Int(statsCountUpYears)) years")
                        .foregroundColor(Theme.coral)
                    + Text(" staring at a screen.")
                        .foregroundColor(Theme.textPrimary)
                }
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .opacity(textReveal[2] ? 1 : 0)
                .offset(y: textReveal[2] ? 0 : 12)
                .animation(.easeOut(duration: 0.5), value: textReveal[2])

                Group {
                    Text("That\u{2019}s ")
                        .foregroundColor(Theme.textPrimary)
                    + Text("\(Int(statsCountUpLifetimeDays).formatted(.number)) days")
                        .foregroundColor(Theme.coral)
                    + Text(" you\u{2019}ll never get back.")
                        .foregroundColor(Theme.textPrimary)
                }
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .opacity(textReveal[3] ? 1 : 0)
                .offset(y: textReveal[3] ? 0 : 12)
                .animation(.easeOut(duration: 0.5), value: textReveal[3])

                Text("But this is all about to change\nonce you start putting God first\nevery morning.")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.coral)
                    .multilineTextAlignment(.leading)
                    .opacity(textReveal[4] ? 1 : 0)
                    .offset(y: textReveal[4] ? 0 : 16)
                    .animation(.easeOut(duration: 0.6), value: textReveal[4])
            }

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 8)

                onboardingButton("Continue") {
                    advance()
                }
                .opacity(textReveal[4] ? 1 : 0)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            resetReveals()
            statsCountUpHours = 0
            statsCountUpDays = 0
            statsCountUpYears = 0
            statsCountUpLifetimeDays = 0

            let targetHours = yearlyPhoneHours
            let targetDays = phoneStatsDays
            let targetYears = phoneStatsLifetimeYears
            let targetLifetimeDays = phoneStatsLifetimeDays

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.5)) { textReveal[0] = true }
                typingHaptic()
                animateCounter(from: 0, to: targetHours, duration: 1.5) { val in
                    statsCountUpHours = Double(val)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.5)) { textReveal[1] = true }
                typingHaptic()
                animateCounter(from: 0, to: targetDays, duration: 1.0) { val in
                    statsCountUpDays = Double(val)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) { textReveal[2] = true }
                typingHaptic()
                animateCounter(from: 0, to: targetYears, duration: 1.0) { val in
                    statsCountUpYears = Double(val)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeOut(duration: 0.5)) { textReveal[3] = true }
                typingHaptic()
                animateCounter(from: 0, to: targetLifetimeDays, duration: 1.0) { val in
                    statsCountUpLifetimeDays = Double(val)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
                withAnimation(.easeOut(duration: 0.6)) { textReveal[4] = true }
                typingHaptic()
            }
        }
    }


    private func animateCounter(from start: Int, to end: Int, duration: Double, update: @escaping (Int) -> Void) {
        let steps = min(max(abs(end - start), 1), 60)
        let interval = duration / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                let progress = Double(i) / Double(steps)
                let eased = 1.0 - pow(1.0 - progress, 3)
                let value = start + Int(Double(end - start) * eased)
                withAnimation(.linear(duration: interval)) {
                    update(value)
                }
            }
        }
    }



    @State private var buildRingProgress: Double = 0
    @State private var buildRingRotation: Double = 0
    @State private var buildParticleBurst: Bool = false
    @State private var buildCheckBounce: Bool = false
    @State private var buildOrbitAngle: Double = 0
    @State private var buildCenterPulse: Bool = false
    @State private var buildCenterScale: CGFloat = 0.3
    @State private var buildGlowIntensity: Double = 0
    @State private var buildConfettiPhase: [Bool] = Array(repeating: false, count: 16)
    @State private var buildStepGlow: [Bool] = Array(repeating: false, count: 4)
    @State private var buildFlashOpacity: Double = 0
    @State private var buildShimmerX: CGFloat = -200

    // MARK: - Creating Bible Mode

    private var creatingBibleModePage: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Theme.bg.ignoresSafeArea()

                RadialGradient(
                    colors: [
                        sunriseGold.opacity(buildGlowIntensity * 0.12),
                        Theme.logoIndigo.opacity(buildGlowIntensity * 0.06),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: 0.28),
                    startRadius: 10,
                    endRadius: 300
                )
                .ignoresSafeArea()

                ForEach(0..<16, id: \.self) { i in
                    let angle = Double(i) * 22.5
                    let rad = (angle + buildOrbitAngle) * .pi / 180
                    let radius: CGFloat = buildComplete ? 200 : 0
                    let sizes: [CGFloat] = [4, 6, 3, 5, 4, 7, 3, 5, 6, 4, 3, 5, 7, 4, 6, 3]
                    let colors: [Color] = [sunriseGold, Theme.logoBlue, dawnCream, Theme.limeGreen, sunrisePeach, Theme.logoIndigo, .white, Theme.mint, sunriseGold, Theme.skyBlue, horizonWarm, Theme.lavender, dawnCream, Theme.limeGreen, sunriseGold, Theme.logoBlue]
                    Circle()
                        .fill(colors[i])
                        .frame(width: sizes[i], height: sizes[i])
                        .position(
                            x: w / 2 + cos(rad) * radius,
                            y: h * 0.28 + sin(rad) * radius
                        )
                        .opacity(buildConfettiPhase[i] ? 0 : 0.9)
                        .blur(radius: sizes[i] > 5 ? 1 : 0)
                }

                Color.white
                    .opacity(buildFlashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer().frame(height: h * 0.08)

                    ZStack {
                        ForEach(0..<3, id: \.self) { ring in
                            Circle()
                                .strokeBorder(
                                    AngularGradient(
                                        colors: [
                                            sunriseGold.opacity(0.4),
                                            Theme.logoBlue.opacity(0.3),
                                            Theme.logoIndigo.opacity(0.2),
                                            sunriseGold.opacity(0.4)
                                        ],
                                        center: .center
                                    ),
                                    lineWidth: CGFloat(3 - ring)
                                )
                                .frame(width: CGFloat(100 + ring * 40), height: CGFloat(100 + ring * 40))
                                .rotationEffect(.degrees(buildOrbitAngle * (ring % 2 == 0 ? 1 : -1)))
                                .opacity(buildCenterScale > 0.5 ? Double(3 - ring) / 4.0 : 0)
                                .blur(radius: CGFloat(ring) * 0.5)
                        }

                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        sunriseGold.opacity(buildCenterPulse ? 0.35 : 0.15),
                                        Theme.logoIndigo.opacity(buildCenterPulse ? 0.15 : 0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(buildCenterPulse ? 1.15 : 0.9)

                        ZStack {
                            if buildComplete {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 56, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Theme.limeGreen, Color(red: 0.2, green: 0.85, blue: 0.5)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Theme.limeGreen.opacity(0.6), radius: 20)
                                    .shadow(color: Theme.limeGreen.opacity(0.3), radius: 40)
                                    .scaleEffect(buildCheckBounce ? 1.12 : 0.95)
                                    .transition(.scale(scale: 0.2).combined(with: .opacity))
                            } else {
                                Image(systemName: "cross.fill")
                                    .font(.system(size: 48, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [sunriseGold, horizonWarm],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: sunriseGold.opacity(0.6), radius: 16)
                                    .shadow(color: horizonWarm.opacity(0.3), radius: 30)
                                    .rotationEffect(.degrees(loadingSpinning ? 360 : 0))
                            }
                        }
                        .scaleEffect(buildCenterScale)

                        Circle()
                            .trim(from: 0, to: buildRingProgress)
                            .stroke(
                                AngularGradient(
                                    colors: buildComplete
                                        ? [Theme.limeGreen, Color(red: 0.2, green: 0.9, blue: 0.5), Theme.limeGreen]
                                        : [sunriseGold, horizonWarm, Theme.logoBlue, Theme.logoIndigo, sunriseGold],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: buildComplete ? Theme.limeGreen.opacity(0.5) : sunriseGold.opacity(0.4), radius: 8)
                    }
                    .frame(height: 180)

                    Spacer().frame(height: 28)

                    Text(buildComplete ? "Your Plan Is Ready!" : "Creating Your\nPut God First Plan")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            buildComplete
                                ? AnyShapeStyle(LinearGradient(colors: [Theme.limeGreen, Color(red: 0.2, green: 0.85, blue: 0.5)], startPoint: .leading, endPoint: .trailing))
                                : AnyShapeStyle(Theme.textPrimary)
                        )
                        .multilineTextAlignment(.center)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 16)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.5), value: buildComplete)

                    if !buildComplete {
                        Text("Personalizing for \(displayName)...")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(textReveal[0] ? 1 : 0)
                            .transition(.opacity)
                    }

                    Spacer().frame(height: 28)

                    VStack(spacing: 10) {
                        buildStepRow("magnifyingglass", "Analyzing your habits", index: 0)
                        buildStepRow("target", "Tuning spiritual focus", index: 1)
                        buildStepRow("book.fill", "Matching you with verses", index: 2)
                        buildStepRow("sparkles", "Crafting your daily rhythm", index: 3)
                    }
                    .padding(.horizontal, 8)
                    .opacity(textReveal[1] ? 1 : 0)

                    Spacer().frame(height: 20)

                    HStack(spacing: 8) {
                        Text("\(Int(buildRingProgress * 100))%")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(
                                buildComplete
                                    ? AnyShapeStyle(Theme.limeGreen)
                                    : AnyShapeStyle(LinearGradient(colors: [sunriseGold, horizonWarm], startPoint: .leading, endPoint: .trailing))
                            )
                            .contentTransition(.numericText())
                            .monospacedDigit()
                        Text(buildComplete ? "complete" : "building")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                            .textCase(.uppercase)
                    }
                    .opacity(textReveal[1] ? 1 : 0)

                    Spacer()

                    if buildComplete {
                        VStack(spacing: 14) {
                            Text("\(displayName), everything is set.\nLet\u{2019}s put God first.")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)

                            onboardingButton("Continue") {
                                advance()
                            }
                        }
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            resetReveals()
            buildProgressValues = [0, 0, 0, 0]
            buildProgressRevealed = 0
            buildComplete = false
            buildRingProgress = 0
            buildRingRotation = 0
            buildParticleBurst = false
            buildCheckBounce = false
            buildOrbitAngle = 0
            buildCenterPulse = false
            buildCenterScale = 0.3
            buildGlowIntensity = 0
            buildConfettiPhase = Array(repeating: false, count: 16)
            buildStepGlow = Array(repeating: false, count: 4)
            buildFlashOpacity = 0
            buildShimmerX = -200
            loadingSpinning = false

            withAnimation(.easeOut(duration: 0.6)) { textReveal[0] = true }

            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                buildCenterScale = 1.0
            }

            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                buildGlowIntensity = 1.0
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.6)) { textReveal[1] = true }

            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false).delay(0.5)) {
                buildOrbitAngle = 360
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.8)) {
                buildCenterPulse = true
            }

            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false).delay(0.5)) {
                loadingSpinning = true
            }

            for i in 0..<4 {
                let startDelay = 1.0 + Double(i) * 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        buildProgressRevealed = i + 1
                    }
                    let impact = UIImpactFeedbackGenerator(style: i == 3 ? .heavy : .medium)
                    impact.impactOccurred()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + 0.15) {
                    withAnimation(.easeOut(duration: 1.2)) {
                        buildProgressValues[i] = 1.0
                        buildRingProgress = Double(i + 1) / 4.0
                    }
                    withAnimation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true)) {
                        buildStepGlow[i] = true
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                withAnimation(.easeOut(duration: 0.1)) { buildFlashOpacity = 0.6 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.5)) { buildFlashOpacity = 0 }
                }

                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)

                withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
                    buildComplete = true
                    loadingSpinning = false
                }

                withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                    buildCheckBounce = true
                }

                for i in 0..<16 {
                    withAnimation(
                        .easeOut(duration: Double.random(in: 1.5...3.0))
                        .delay(Double(i) * 0.05)
                    ) {
                        buildConfettiPhase[i] = true
                    }
                }

                withAnimation(.easeOut(duration: 1.5)) {
                    buildGlowIntensity = 2.0
                }
            }
        }
    }

    private func buildStepRow(_ emoji: String, _ label: String, index: Int) -> some View {
        let isRevealed = index < buildProgressRevealed
        let isDone = buildProgressValues[safe: index].map { $0 >= 1.0 } ?? false
        let isGlowing = buildStepGlow[safe: index] ?? false
        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        isDone
                            ? Theme.limeGreen.opacity(0.18)
                            : (isRevealed ? sunriseGold.opacity(0.12) : Theme.cardBg)
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: isGlowing ? sunriseGold.opacity(0.3) : .clear, radius: 8)

                if isDone {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.limeGreen)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                        .symbolEffect(.bounce, value: isDone)
                } else if isRevealed {
                    Image(systemName: emoji)
                        .font(.system(size: 20))
                        .foregroundStyle(sunriseGold)
                        .scaleEffect(isGlowing ? 1.2 : 1.0)
                } else {
                    Image(systemName: emoji)
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.textSecondary)
                        .opacity(0.4)
                }
            }

            Text(label)
                .font(.system(size: 15, weight: isDone ? .bold : .semibold, design: .rounded))
                .foregroundStyle(isDone ? Theme.textPrimary : (isRevealed ? Theme.textPrimary.opacity(0.8) : Theme.textSecondary.opacity(0.5)))

            Spacer()

            if isRevealed && !isDone {
                ProgressView()
                    .tint(sunriseGold)
                    .scaleEffect(0.8)
                    .transition(.scale.combined(with: .opacity))
            } else if isDone {
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.limeGreen)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isDone ? Theme.limeGreen.opacity(0.06) : Theme.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isDone ? Theme.limeGreen.opacity(0.2) : (isRevealed && !isDone ? sunriseGold.opacity(0.15) : Color.clear),
                            lineWidth: 1
                        )
                )
        )
        .opacity(isRevealed ? 1 : 0.4)
        .offset(y: isRevealed ? 0 : 8)
        .scaleEffect(isRevealed ? 1.0 : 0.97)
        .animation(.spring(response: 0.5, dampingFraction: 0.65), value: buildProgressRevealed)
        .animation(.easeOut(duration: 0.4), value: isDone)
        .animation(.easeInOut(duration: 0.3), value: isGlowing)
    }

    // MARK: - Lasting Habits

    private let stockGreen = Color(red: 0.2, green: 0.85, blue: 0.55)
    private let stockGreenBright = Color(red: 0.3, green: 0.95, blue: 0.65)

    private var lastingHabitsPage: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.12),
                    Color(red: 0.06, green: 0.08, blue: 0.16),
                    Color(red: 0.05, green: 0.07, blue: 0.14),
                    Color(red: 0.03, green: 0.05, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    stockGreen.opacity(graphAnimProgress > 0.5 ? 0.08 : 0.02),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.45),
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()

        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14))
                        .foregroundStyle(stockGreen)
                        .symbolEffect(.pulse, isActive: textReveal[0])
                    Text("SPIRITUAL GROWTH")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(stockGreen)
                        .tracking(2)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14))
                        .foregroundStyle(stockGreen)
                        .symbolEffect(.pulse, isActive: textReveal[0])
                }
                .opacity(textReveal[0] ? 1 : 0)
                .scaleEffect(textReveal[0] ? 1 : 0.8)

                (Text("Putting God first builds\n")
                    .foregroundStyle(.white)
                + Text("holy habits.")
                    .foregroundStyle(stockGreen))
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .opacity(textReveal[0] ? 1 : 0)
                    .offset(y: textReveal[0] ? 0 : 20)
            }

            Spacer().frame(height: 24)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.10))
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [stockGreen.opacity(graphAnimProgress > 0.8 ? 0.4 : 0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Growth")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("+80%")
                                    .font(.system(size: 26, weight: .black))
                                    .foregroundStyle(stockGreen)
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(stockGreen)
                            }
                            .opacity(graphAnimProgress > 0.7 ? 1 : 0)
                            .scaleEffect(graphAnimProgress > 0.7 ? 1 : 0.8, anchor: .leading)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 6)

                    HStack(spacing: 0) {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text("Strong")
                                .frame(maxHeight: .infinity, alignment: .top)
                            Text("Growing")
                                .frame(maxHeight: .infinity, alignment: .center)
                            Text("Start")
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(width: 40)
                        .padding(.trailing, 4)

                        GeometryReader { geo in
                            let w = geo.size.width
                            let h = geo.size.height
                            let chartPadTop: CGFloat = 12
                            let chartPadBottom: CGFloat = 8
                            let chartH = h - chartPadTop - chartPadBottom
                            let pts: [CGPoint] = [
                                CGPoint(x: 0, y: chartPadTop + chartH * 0.92),
                                CGPoint(x: w * 0.1, y: chartPadTop + chartH * 0.85),
                                CGPoint(x: w * 0.2, y: chartPadTop + chartH * 0.76),
                                CGPoint(x: w * 0.3, y: chartPadTop + chartH * 0.66),
                                CGPoint(x: w * 0.4, y: chartPadTop + chartH * 0.55),
                                CGPoint(x: w * 0.5, y: chartPadTop + chartH * 0.43),
                                CGPoint(x: w * 0.6, y: chartPadTop + chartH * 0.32),
                                CGPoint(x: w * 0.7, y: chartPadTop + chartH * 0.22),
                                CGPoint(x: w * 0.8, y: chartPadTop + chartH * 0.14),
                                CGPoint(x: w * 0.9, y: chartPadTop + chartH * 0.08),
                                CGPoint(x: w * 0.98, y: chartPadTop + chartH * 0.04)
                            ]

                            ZStack {
                                ForEach(0..<3, id: \.self) { i in
                                    let yPos = chartPadTop + chartH * CGFloat(i) / 2.0
                                    Path { p in
                                        p.move(to: CGPoint(x: 0, y: yPos))
                                        p.addLine(to: CGPoint(x: w, y: yPos))
                                    }
                                    .stroke(Color.white.opacity(0.06), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                }

                                Path { path in
                                    let totalPts = Int(graphAnimProgress * Double(pts.count - 1))
                                    guard totalPts >= 1 else { return }
                                    path.move(to: pts[0])
                                    for i in 1...min(totalPts, pts.count - 1) {
                                        let prev = pts[i - 1]
                                        let curr = pts[i]
                                        let ctrl1 = CGPoint(x: prev.x + (curr.x - prev.x) * 0.5, y: prev.y)
                                        let ctrl2 = CGPoint(x: prev.x + (curr.x - prev.x) * 0.5, y: curr.y)
                                        path.addCurve(to: curr, control1: ctrl1, control2: ctrl2)
                                    }
                                }
                                .stroke(
                                    LinearGradient(
                                        colors: [stockGreen.opacity(0.4), stockGreen, stockGreenBright],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                                )
                                .shadow(color: stockGreen.opacity(0.6), radius: 8)

                                Path { path in
                                    let totalPts = Int(graphAnimProgress * Double(pts.count - 1))
                                    guard totalPts >= 1 else { return }
                                    let bottomY = chartPadTop + chartH
                                    path.move(to: CGPoint(x: pts[0].x, y: bottomY))
                                    path.addLine(to: pts[0])
                                    for i in 1...min(totalPts, pts.count - 1) {
                                        let prev = pts[i - 1]
                                        let curr = pts[i]
                                        let ctrl1 = CGPoint(x: prev.x + (curr.x - prev.x) * 0.5, y: prev.y)
                                        let ctrl2 = CGPoint(x: prev.x + (curr.x - prev.x) * 0.5, y: curr.y)
                                        path.addCurve(to: curr, control1: ctrl1, control2: ctrl2)
                                    }
                                    path.addLine(to: CGPoint(x: pts[min(totalPts, pts.count - 1)].x, y: bottomY))
                                    path.closeSubpath()
                                }
                                .fill(
                                    LinearGradient(
                                        colors: [stockGreen.opacity(0.25), stockGreen.opacity(0.05), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )

                                if graphAnimProgress > 0.85 {
                                    let lastIdx = min(Int(graphAnimProgress * Double(pts.count - 1)), pts.count - 1)
                                    let lastPt = pts[lastIdx]
                                    Circle()
                                        .fill(stockGreen)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: stockGreen.opacity(0.8), radius: 10)
                                        .shadow(color: stockGreenBright.opacity(0.5), radius: 20)
                                        .position(lastPt)
                                        .transition(.scale.combined(with: .opacity))

                                    Text("\u{1F680}")
                                        .font(.system(size: 24))
                                        .position(x: lastPt.x - 20, y: lastPt.y - 14)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                    }
                    .frame(height: 180)
                    .padding(.trailing, 12)
                    .padding(.bottom, 4)

                    HStack(spacing: 0) {
                        Spacer().frame(width: 44)
                        let timeLabels = ["Week 1", "Month 1", "Month 3", "Month 6+"]
                        ForEach(Array(timeLabels.enumerated()), id: \.offset) { idx, label in
                            let threshold = Double(idx) * 0.25
                            Text(label)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(graphAnimProgress > threshold ? stockGreen : .white.opacity(0.25))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 14)
                }
            }
            .opacity(textReveal[1] ? 1 : 0)
            .offset(y: textReveal[1] ? 0 : 30)

            Spacer().frame(height: 20)

            VStack(spacing: 12) {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(sunriseGold)
                    }
                }

                Text("\u{201C}My faith is getting stronger every day since I started using Put God First\u{201D}")
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(sunriseGold.opacity(0.15), lineWidth: 1)
                    )
            )
            .opacity(textReveal[2] ? 1 : 0)
            .offset(y: textReveal[2] ? 0 : 16)

            Spacer()

            VStack(spacing: 16) {
                pageIndicator(current: 25)

                onboardingButton("Ready to stop drifting?") {
                    advance()
                }
                .opacity(textReveal[2] ? 1 : 0)
                .scaleEffect(textReveal[2] ? 1 : 0.95)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 28)
        .onAppear {
            resetReveals()
            graphAnimProgress = 0
            habitsCrownDrop = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.6)) { textReveal[0] = true }
                typingHaptic()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { textReveal[1] = true }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 2.5)) {
                    graphAnimProgress = 1.0
                }
                let g = UIImpactFeedbackGenerator(style: .medium)
                g.impactOccurred(intensity: 0.6)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { textReveal[2] = true }
                let g = UINotificationFeedbackGenerator()
                g.notificationOccurred(.success)
            }
        }
        }
    }

    private func habitsStatPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(color.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Fair Trial Policy

    private var fairTrialPolicyPage: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.18, blue: 0.58),
                    Color(red: 0.22, green: 0.18, blue: 0.62),
                    Color(red: 0.18, green: 0.22, blue: 0.68),
                    Color(red: 0.15, green: 0.28, blue: 0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    sunriseGold.opacity(fairTrialGlowPulse ? 0.12 : 0.03),
                    dawnCream.opacity(fairTrialGlowPulse ? 0.06 : 0.01),
                    Color.clear
                ],
                center: UnitPoint(x: 0.3, y: 0.35),
                startRadius: 20,
                endRadius: 280
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Theme.icePurple.opacity(fairTrialGlowPulse ? 0.08 : 0.02),
                    Color.clear
                ],
                center: UnitPoint(x: 0.7, y: 0.8),
                startRadius: 10,
                endRadius: 200
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(0..<6, id: \.self) { i in
                    let xPos: [CGFloat] = [0.08, 0.88, 0.25, 0.72, 0.15, 0.6]
                    let sizes: [CGFloat] = [4, 3, 5, 3, 4, 3]
                    let pColors: [Color] = [.white, dawnCream, .white, sunriseGold, dawnCream, .white]
                    Circle()
                        .fill(pColors[i].opacity(0.35))
                        .frame(width: sizes[i], height: sizes[i])
                        .blur(radius: 1)
                        .position(
                            x: geo.size.width * xPos[i],
                            y: fairTrialParticlePhase[i] ? -10 : geo.size.height * 0.88
                        )
                        .opacity(fairTrialParticlePhase[i] ? 0 : 0.7)
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 20)

                HStack(spacing: 8) {
                    Text("\u{1F381}")
                        .font(.system(size: 16))
                    Text("fair trial policy")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.15, green: 0.1, blue: 0.35))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.white)
                        .shadow(color: .white.opacity(fairTrialGlowPulse ? 0.3 : 0.1), radius: 12)
                )
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .opacity(textReveal[0] ? 1 : 0)
                .scaleEffect(textReveal[0] ? 1 : 0.5)

                Spacer().frame(height: 36)

                HStack(spacing: 0) {
                    VStack(spacing: 14) {
                        HStack(spacing: 6) {
                            Text("\u{1F64F}")
                                .font(.system(size: 13))
                            Text("spiritual peace")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.15, green: 0.1, blue: 0.35))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(.white.opacity(0.9)))

                        Text("\u{1F54A}\u{FE0F}")
                            .font(.system(size: 64))
                            .offset(y: fairTrialDoveFloat)
                            .shadow(color: .white.opacity(fairTrialGlowPulse ? 0.5 : 0.15), radius: 20)
                    }
                    .opacity(textReveal[1] ? 1 : 0)
                    .offset(x: textReveal[1] ? 0 : -30)

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: .white.opacity(fairTrialVsPulse ? 0.6 : 0.1), radius: fairTrialVsPulse ? 16 : 4)
                        Text("vs")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.icePurple)
                    }
                    .scaleEffect(fairTrialVsPulse ? 1.08 : 1.0)
                    .opacity(textReveal[1] ? 1 : 0)
                    .scaleEffect(textReveal[1] ? 1 : 0.3)

                    Spacer()

                    VStack(spacing: 14) {
                        Text("\u{2615}")
                            .font(.system(size: 64))

                        HStack(spacing: 6) {
                            Text("\u{2615}")
                                .font(.system(size: 13))
                            Text("the cost of one\ncoffee a month")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.15, green: 0.1, blue: 0.35))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(.white.opacity(0.9)))
                    }
                    .opacity(textReveal[2] ? 1 : 0)
                    .offset(x: textReveal[2] ? 0 : 30)
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 40)

                Text("Put God First is free\nfor you to try.")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .shadow(color: sunriseGold.opacity(fairTrialGlowPulse ? 0.25 : 0.08), radius: 15)
                    .opacity(textReveal[3] ? 1 : 0)
                    .offset(y: textReveal[3] ? 0 : 20)

                Spacer().frame(height: 16)

                Text("We depend on support from believers like you to keep building a Christ-centered tool that helps our generation stay committed to God.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .opacity(textReveal[4] ? 1 : 0)
                    .offset(y: textReveal[4] ? 0 : 14)

                Spacer()

                Button {
                    advance()
                } label: {
                    HStack(spacing: 8) {
                        Text("Sounds Good")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundStyle(Color(red: 0.15, green: 0.1, blue: 0.35))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(color: .white.opacity(0.2), radius: 12)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                }
                .padding(.horizontal, 28)
                .opacity(textReveal[4] ? 1 : 0)
                .offset(y: textReveal[4] ? 0 : 20)
                .scaleEffect(textReveal[4] ? 1 : 0.95)

                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            resetReveals()
            fairTrialDoveFloat = 0
            fairTrialGlowPulse = false
            fairTrialVsPulse = false
            fairTrialParticlePhase = Array(repeating: false, count: 6)

            for i in 0..<5 {
                let delay = 0.3 + Double(i) * 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                        textReveal[i] = true
                    }
                    typingHaptic()
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    fairTrialDoveFloat = -12
                }
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    fairTrialGlowPulse = true
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    fairTrialVsPulse = true
                }
            }

            for i in 0..<6 {
                let durations: [Double] = [7, 9, 6, 10, 8, 7]
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(
                        .easeInOut(duration: durations[i])
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.5)
                    ) {
                        fairTrialParticlePhase[i] = true
                    }
                }
            }
        }
    }

    // MARK: - Commitment Signature

    private var commitmentSignaturePage: some View {
        let hasSigned = !signatureLines.isEmpty

        return ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.18, blue: 0.58),
                    Color(red: 0.22, green: 0.18, blue: 0.62),
                    Color(red: 0.18, green: 0.22, blue: 0.68),
                    Color(red: 0.15, green: 0.28, blue: 0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    dawnCream.opacity(commitmentGlowPulse ? 0.1 : 0.02),
                    sunriseGold.opacity(commitmentGlowPulse ? 0.06 : 0.01),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.12),
                startRadius: 10,
                endRadius: 220
            )
            .ignoresSafeArea()

            GeometryReader { geo in
                ForEach(0..<6, id: \.self) { i in
                    let xPos: [CGFloat] = [0.1, 0.88, 0.32, 0.68, 0.18, 0.55]
                    let sizes: [CGFloat] = [3, 4, 3, 5, 3, 4]
                    let pColors: [Color] = [.white, dawnCream, .white, sunriseGold, dawnCream, .white]
                    Circle()
                        .fill(pColors[i].opacity(0.3))
                        .frame(width: sizes[i], height: sizes[i])
                        .blur(radius: 1)
                        .position(
                            x: geo.size.width * xPos[i],
                            y: warmOrbsFloat[i] ? -10 : geo.size.height * 0.85
                        )
                        .opacity(warmOrbsFloat[i] ? 0 : 0.5)
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 36)

                    Text("Make Your\nCommitment")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: sunriseGold.opacity(commitmentGlowPulse ? 0.25 : 0.08), radius: 12)
                        .padding(.horizontal, 28)
                        .opacity(textReveal[0] ? 1 : 0)
                        .offset(y: textReveal[0] ? 0 : 16)

                    Spacer().frame(height: 10)

                    Text("From today forward, I choose to:")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 28)
                        .opacity(textReveal[1] ? 1 : 0)
                        .offset(y: textReveal[1] ? 0 : 10)

                    Spacer().frame(height: 22)

                    VStack(alignment: .leading, spacing: 12) {
                        commitmentAnimatedBullet("Seek God before my phone", index: 0)
                        commitmentAnimatedBullet("Pray before using my phone", index: 1)
                        commitmentAnimatedBullet("Be intentional with my screen time", index: 2)
                        commitmentAnimatedBullet("Guard my heart and my mind", index: 3)
                    }
                    .padding(.horizontal, 28)

                    Spacer().frame(height: 22)

                    ZStack(alignment: .topTrailing) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white)
                            .frame(height: 160)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                sunriseGold.opacity(commitmentSignatureGlow ? 0.4 : 0.1),
                                                dawnCream.opacity(commitmentSignatureGlow ? 0.2 : 0.05)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .overlay(
                                signatureCanvasOverlay
                            )
                            .clipShape(.rect(cornerRadius: 20))
                            .shadow(color: sunriseGold.opacity(commitmentSignatureGlow ? 0.15 : 0.03), radius: 20)

                        Button {
                            signatureLines = []
                            currentSignatureLine = []
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(.black.opacity(0.3)))
                        }
                        .offset(x: 8, y: -8)
                    }
                    .padding(.horizontal, 28)
                    .opacity(textReveal[3] ? 1 : 0)
                    .scaleEffect(textReveal[3] ? 1 : 0.95)

                    Spacer().frame(height: 10)

                    Text("Sign as a reminder of the promise you\u{2019}re making.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .opacity(textReveal[3] ? 1 : 0)

                    Spacer().frame(height: 28)

                    if commitmentCheckmarkShown {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: Color.green.opacity(0.5), radius: 16)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .transition(.scale.combined(with: .opacity))

                            Text("You're committed!")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .transition(.opacity)
                        }
                        .padding(.horizontal, 28)
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                commitmentCheckmarkShown = true
                            }
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                advance()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundStyle(hasSigned ? Color(red: 0.15, green: 0.1, blue: 0.35) : Color(red: 0.15, green: 0.1, blue: 0.35).opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                Capsule().fill(hasSigned ? .white : .white.opacity(0.4))
                            )
                            .shadow(color: hasSigned ? .white.opacity(0.15) : .clear, radius: 12, y: 6)
                        }
                        .disabled(!hasSigned)
                        .padding(.horizontal, 28)
                    }

                    Spacer().frame(height: 50)
                }
            }
        }
        .onAppear {
            signatureLines = []
            currentSignatureLine = []
            resetReveals()
            commitmentGlowPulse = false
            commitmentCheckmarkShown = false
            commitmentBulletReveal = Array(repeating: false, count: 4)
            commitmentSignatureGlow = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                    textReveal[0] = true
                }
                typingHaptic()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeOut(duration: 0.5)) {
                    textReveal[1] = true
                }
            }

            for i in 0..<4 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + Double(i) * 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        commitmentBulletReveal[i] = true
                    }
                    typingHaptic()
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    textReveal[3] = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    commitmentGlowPulse = true
                }
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    commitmentSignatureGlow = true
                }
            }
        }
    }

    private func commitmentAnimatedBullet(_ text: String, index: Int) -> some View {
        let isRevealed = commitmentBulletReveal[safe: index] == true
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isRevealed ? sunriseGold : .white.opacity(0.2))
                    .frame(width: 24, height: 24)
                    .shadow(color: sunriseGold.opacity(isRevealed ? 0.4 : 0), radius: 6)
                if isRevealed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            Text(text)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .opacity(isRevealed ? 1 : 0.35)
        .offset(x: isRevealed ? 0 : -15)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: commitmentBulletReveal)
    }

    @ViewBuilder
    private var signatureCanvasOverlay: some View {
        Canvas { context, size in
            for line in signatureLines {
                guard line.count > 1 else { continue }
                var path = Path()
                path.move(to: line[0])
                for point in line.dropFirst() {
                    path.addLine(to: point)
                }
                context.stroke(path, with: .color(.black.opacity(0.8)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
            if currentSignatureLine.count > 1 {
                var path = Path()
                path.move(to: currentSignatureLine[0])
                for point in currentSignatureLine.dropFirst() {
                    path.addLine(to: point)
                }
                context.stroke(path, with: .color(.black.opacity(0.8)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentSignatureLine.append(value.location)
                }
                .onEnded { _ in
                    if !currentSignatureLine.isEmpty {
                        signatureLines.append(currentSignatureLine)
                        currentSignatureLine = []
                    }
                }
        )
    }

    // MARK: - Helpers

    private var displayName: String {
        let name = nameInput.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Friend" : name
    }

    private var confidenceEmoji: String {
        if prayerConfidence < 0.2 { return "\u{1F615}" }
        if prayerConfidence < 0.4 { return "\u{1F914}" }
        if prayerConfidence < 0.6 { return "\u{1F642}" }
        if prayerConfidence < 0.8 { return "\u{1F60A}" }
        return "\u{1F929}" 
    }

    private var confidenceLabel: String {
        if prayerConfidence < 0.25 { return "I struggle to focus" }
        if prayerConfidence < 0.5 { return "Working on consistency" }
        if prayerConfidence < 0.75 { return "Getting stronger" }
        return "Feeling confident"
    }

    private func resetReveals() {
        textReveal = Array(repeating: false, count: 8)
    }

    private func revealSequence(count: Int, baseDelay: Double, interval: Double) {
        resetReveals()
        for i in 0..<min(count, textReveal.count) {
            let delay = baseDelay + Double(i) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.5)) {
                    textReveal[i] = true
                }
                typingHaptic()
            }
        }
    }

    private func advance() {
        resetReveals()
        withAnimation(.easeInOut(duration: 0.4)) {
            currentPage += 1
        }
    }

    private func typingHaptic() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.impactOccurred(intensity: 0.4)
    }

    private func brainStatRow(label: String, value: Int, index: Int, color: Color) -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(color)

                Text("\(Int(brainStatCounters[index]))%")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                    .monospacedDigit()
                    .frame(width: 56, alignment: .leading)
                    .contentTransition(.numericText())
            }

            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(index < brainStatsRevealed ? 0.06 : 0))
        )
        .opacity(index < brainStatsRevealed ? 1 : 0)
        .offset(x: index < brainStatsRevealed ? 0 : -20)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: brainStatsRevealed)
    }

    private func hardwiredCard(icon: String, title: String, body: String, color: Color, index: Int) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Text(body)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Theme.cardBg)
        )
        .opacity(textReveal[min(index, textReveal.count - 1)] ? 1 : 0)
        .offset(y: textReveal[min(index, textReveal.count - 1)] ? 0 : 14)
    }

    private func bibleStatRow(label: String, value: Int, index: Int, color: Color, isIncrease: Bool = false) -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: isIncrease ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isIncrease ? Theme.limeGreen : color)

                Text("\(Int(statCounters[index]))%")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(isIncrease ? Theme.limeGreen : color)
                    .monospacedDigit()
                    .frame(width: 56, alignment: .leading)
                    .contentTransition(.numericText())
            }

            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(index < statsRevealed ? 0.06 : 0))
        )
        .opacity(index < statsRevealed ? 1 : 0)
        .offset(x: index < statsRevealed ? 0 : -20)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: statsRevealed)
    }

    private func beforeAfterItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(color)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func habitOption(_ text: String, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                phoneHabit = text
            }
            typingHaptic()
        } label: {
            HStack(spacing: 14) {
                Text(habitEmoji(for: text))
                    .font(.system(size: 24))
                    .frame(width: 32)

                Text(text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                if phoneHabit == text {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.blueAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(phoneHabit == text ? Theme.blueAccent.opacity(0.08) : Theme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(phoneHabit == text ? Theme.blueAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
    }

    private func habitEmoji(for text: String) -> String {
        if text.contains("Immediately") { return "\u{23F0}" }
        if text.contains("5 minutes") { return "\u{1F570}" }
        if text.contains("out of bed") { return "\u{1F6CF}\u{FE0F}" }
        return "\u{270B}" 
    }

    private func timeOption(_ minutes: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMinutes = minutes
            }
        } label: {
            HStack {
                Text(minutes == 15 ? "15+ minutes" : "\(minutes) minutes")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                if selectedMinutes == minutes {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.blueAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedMinutes == minutes ? Theme.blueAccent.opacity(0.08) : Theme.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(selectedMinutes == minutes ? Theme.blueAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
    }

    private func journeyBuildItem(_ text: String, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(index < journeyDotsLoaded ? Theme.blueAccent : Theme.cardBg)
                    .frame(width: 28, height: 28)

                if index < journeyDotsLoaded {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(index < journeyDotsLoaded ? Theme.textPrimary : Theme.textSecondary.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dayPathRow(day: Int, title: String, isFirst: Bool) -> some View {
        HStack(spacing: 14) {
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Theme.blueAccent.opacity(0.2))
                        .frame(width: 2, height: 12)
                }

                ZStack {
                    Circle()
                        .fill(day == 1 ? Theme.blueAccent : Theme.blueAccent.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Text("\(day)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(day == 1 ? .white : Theme.blueAccent)
                }

                Rectangle()
                    .fill(day < 7 ? Theme.blueAccent.opacity(0.2) : Color.clear)
                    .frame(width: 2, height: 12)
            }

            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Spacer()
        }
    }

    private func pathCard(day: Int, title: String, subtitle: String, icon: String, color: Color) -> some View {
        let isRevealed = day <= dayPathRevealed
        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(isRevealed ? 0.2 : 0.06), color.opacity(isRevealed ? 0.08 : 0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                if isRevealed {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("\(day)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary.opacity(0.3))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("DAY \(day)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(isRevealed ? color : Theme.textSecondary.opacity(0.3))
                        .tracking(1)

                    if day == 7 && isRevealed {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.limeGreen)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(isRevealed ? Theme.textPrimary : Theme.textSecondary.opacity(0.35))

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(isRevealed ? Theme.textSecondary : Theme.textSecondary.opacity(0.2))
            }

            Spacer()

            if isRevealed {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(color)
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isRevealed ? color.opacity(0.04) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isRevealed ? color.opacity(0.15) : Color.clear, lineWidth: 1)
                )
        )
        .opacity(isRevealed ? 1 : 0.4)
        .offset(x: isRevealed ? 0 : -12)
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: dayPathRevealed)
    }

    private func animatedDayRow(day: Int, title: String, icon: String, color: Color, isFirst: Bool) -> some View {
        let isRevealed = day <= dayPathRevealed
        return HStack(spacing: 14) {
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(isRevealed ? 0.5 : 0.1), color.opacity(isRevealed ? 0.2 : 0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2.5, height: 14)
                }

                ZStack {
                    Circle()
                        .fill(isRevealed ? color : Theme.cardBg)
                        .frame(width: 36, height: 36)
                        .shadow(color: isRevealed ? color.opacity(0.4) : .clear, radius: 8)

                    if isRevealed {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("\(day)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                }

                Rectangle()
                    .fill(day < 7 ? color.opacity(isRevealed ? 0.2 : 0.05) : Color.clear)
                    .frame(width: 2.5, height: 14)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Day \(day)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(isRevealed ? color : Theme.textSecondary.opacity(0.3))
                    .textCase(.uppercase)

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(isRevealed ? Theme.textPrimary : Theme.textSecondary.opacity(0.35))
            }

            Spacer()

            if day == 7 && isRevealed {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.limeGreen)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .opacity(isRevealed ? 1 : 0.5)
        .offset(x: isRevealed ? 0 : -12)
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: dayPathRevealed)
    }

    private func socialAppCard(icon: String, name: String, color: Color, index: Int) -> some View {
        let isRevealed = index < blockerAppsRevealed
        let isBlocked = blockerStrikethrough[index]
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(isBlocked ? 0.05 : 0.35),
                            color.opacity(isBlocked ? 0.02 : 0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(color.opacity(isBlocked ? 0.08 : 0.4), lineWidth: 1)
                )
                .frame(height: 88)

            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(isBlocked ? .white.opacity(0.12) : color)
                    .blur(radius: isBlocked ? 2 : 0)
                Text(name)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(isBlocked ? .white.opacity(0.12) : .white.opacity(0.8))
                    .blur(radius: isBlocked ? 1 : 0)
            }

            if isBlocked {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.red.opacity(0.15))
                        .frame(height: 88)

                    Circle()
                        .fill(Color.red.opacity(0.9))
                        .frame(width: 34, height: 34)
                        .shadow(color: .red.opacity(0.6), radius: 10)
                        .shadow(color: .red.opacity(0.3), radius: 20)
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .transition(.scale(scale: 0.1).combined(with: .opacity))
            }
        }
        .opacity(isRevealed ? 1 : 0)
        .scaleEffect(isRevealed ? (isBlocked && blockerCardsShrink ? 0.92 : 1.0) : 0.6)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: blockerAppsRevealed)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: blockerStrikethrough[index])
        .animation(.easeIn(duration: 0.3), value: blockerCardsShrink)
    }

    private func requestFamilyControls() {
        Task {
            let success = await ScreenTimeService.shared.requestAuthorization()
            if success {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    familyControlsAuthorized = true
                }
                revealSequence(count: 5, baseDelay: 0.1, interval: 0.25)
            } else {
                showAuthError = true
            }
        }
    }

    private func trustReinforcer(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Theme.limeGreen)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Spacer()
        }
    }

    private func welcomePageIndicator(current: Int) -> some View {
        EmptyView()
    }

    private func welcomeButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.2, green: 0.08, blue: 0.45))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule().fill(.white)
                )
                .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
        }
    }

    private func mapIndicatorIndex(_ dotIndex: Int, total: Int) -> Int {
        let progress = Double(currentPage) / Double(max(totalPages - 1, 1))
        let center = Int(progress * Double(total - 1))
        let start = max(0, center - total / 2)
        return start + dotIndex
    }

    private func pageIndicator(current: Int) -> some View {
        EmptyView()
    }

    private func onboardingButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            )
            .shadow(color: Theme.logoIndigo.opacity(0.4), radius: 12, y: 6)
        }
    }

    // MARK: - Warm Background

    @Environment(\.colorScheme) private var colorScheme

    @ViewBuilder
    private var warmOnboardingBg: some View {
        ZStack {
            Group {
                if colorScheme == .dark {
                    LinearGradient(
                        colors: [
                            Color(red: 0.02, green: 0.02, blue: 0.04),
                            Color(red: 0.03, green: 0.02, blue: 0.05),
                            Color(red: 0.04, green: 0.03, blue: 0.06),
                            Color(red: 0.03, green: 0.02, blue: 0.04)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.98, blue: 0.95),
                            Color(red: 1.0, green: 0.97, blue: 0.93),
                            Color(red: 0.99, green: 0.96, blue: 0.93),
                            Color(red: 0.98, green: 0.95, blue: 0.94)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    sunriseGold.opacity(warmPulse ? (colorScheme == .dark ? 0.04 : 0.12) : 0.02),
                    sunrisePeach.opacity(warmPulse ? 0.06 : 0.02),
                    Color.clear
                ],
                center: UnitPoint(x: 0.75, y: 0.08),
                startRadius: 20,
                endRadius: 350
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    horizonWarm.opacity(warmPulse ? (colorScheme == .dark ? 0.03 : 0.08) : 0.01),
                    dawnCream.opacity(0.03),
                    Color.clear
                ],
                center: UnitPoint(x: 0.15, y: 0.9),
                startRadius: 10,
                endRadius: 280
            )
            .ignoresSafeArea()

            warmFloatingOrbs
        }
        .onAppear {
            for i in 0..<8 {
                let durations: [Double] = [8, 10, 7, 11, 9, 12, 8, 10]
                withAnimation(
                    .easeInOut(duration: durations[i])
                    .repeatForever(autoreverses: false)
                    .delay(Double(i) * 0.6)
                ) {
                    warmOrbsFloat[i] = true
                }
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                warmPulse = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                warmIconGlow = true
            }
        }
    }

    private var warmFloatingOrbs: some View {
        GeometryReader { geo in
            ForEach(0..<8, id: \.self) { i in
                let xPos: [CGFloat] = [0.1, 0.85, 0.3, 0.7, 0.15, 0.6, 0.45, 0.9]
                let sizes: [CGFloat] = [6, 4, 8, 5, 7, 3, 6, 4]
                let orbColors: [Color] = [
                    sunriseGold.opacity(0.3),
                    dawnCream.opacity(0.4),
                    horizonWarm.opacity(0.25),
                    sunriseGold.opacity(0.35),
                    dawnCream.opacity(0.3),
                    sunrisePeach.opacity(0.2),
                    sunriseGold.opacity(0.25),
                    horizonWarm.opacity(0.3)
                ]
                let startY: [CGFloat] = [0.9, 0.95, 0.85, 0.92, 0.88, 0.96, 0.9, 0.93]

                Circle()
                    .fill(orbColors[i])
                    .frame(width: sizes[i], height: sizes[i])
                    .blur(radius: sizes[i] > 5 ? 2 : 1)
                    .position(
                        x: geo.size.width * xPos[i],
                        y: warmOrbsFloat[i] ? -20 : geo.size.height * startY[i]
                    )
                    .opacity(warmOrbsFloat[i] ? 0 : 0.7)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
