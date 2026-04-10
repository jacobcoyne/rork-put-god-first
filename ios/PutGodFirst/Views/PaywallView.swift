import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackageID: String = "$rc_annual"
    @State private var appear: Bool = false
    @State private var isPurchasing: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isRestoring: Bool = false
    @State private var loadFailed: Bool = false
    @State private var isPurchasingLifetime: Bool = false

    private var subscriptionService: SubscriptionService { SubscriptionService.shared }

    private var currentOffering: Offering? {
        subscriptionService.offerings?.current
    }

    private var subscriptionPackages: [Package] {
        currentOffering?.availablePackages.filter { $0.packageType != .lifetime } ?? []
    }

    private var selectedPackage: Package? {
        subscriptionPackages.first { $0.identifier == selectedPackageID }
    }

    private var weeklyPackage: Package? {
        subscriptionPackages.first { $0.packageType == .weekly }
    }

    private var annualPackage: Package? {
        subscriptionPackages.first { $0.packageType == .annual }
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

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.04, blue: 0.16),
                    Color(red: 0.10, green: 0.06, blue: 0.24),
                    Color(red: 0.14, green: 0.08, blue: 0.32)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection

                        noPaymentTrustCard

                        whyThisWorksSection

                        packagesSection

                        ctaSection

                        lifetimeUpsellButton

                        footerSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appear = true
            }
        }
        .task {
            await loadOfferings()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(colors: [Theme.dawnGold, Theme.dawnAmber], startPoint: .top, endPoint: .bottom)
                )
                .scaleEffect(appear ? 1 : 0.5)
                .opacity(appear ? 1 : 0)

            Text("God First Pro")
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(.white)
                .opacity(appear ? 1 : 0)

            Text("Transform your mornings. Transform your life.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .opacity(appear ? 1 : 0)
        }
        .padding(.top, 4)
    }

    private var whyThisWorksSection: some View {
        VStack(spacing: 12) {
            Text("Why This Works")
                .font(.system(size: 13, weight: .heavy))
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(Theme.dawnGold)
                .frame(maxWidth: .infinity, alignment: .leading)

            whyCard(
                icon: "shield.checkered",
                iconColor: Theme.logoIndigo,
                title: "App Blocking",
                description: "Block distracting apps until you complete your morning session with God"
            )

            whyCard(
                icon: "brain.head.profile.fill",
                iconColor: Theme.icePurple,
                title: "Scripture Memorization",
                description: "Recite verses aloud to unlock apps — hide God's Word in your heart"
            )

            whyCard(
                icon: "flame.fill",
                iconColor: Theme.dawnAmber,
                title: "Daily Streak System",
                description: "Build an unbreakable habit of putting God first every single morning"
            )

            whyCard(
                icon: "text.book.closed.fill",
                iconColor: Theme.iceBlue,
                title: "Curated Prayers & Devotionals",
                description: "Fresh content daily — prayers, devotionals, and declarations crafted for your walk"
            )
        }
        .opacity(appear ? 1 : 0)
    }

    private func whyCard(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    @ViewBuilder
    private var packagesSection: some View {
        if subscriptionService.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.white)
                Text("Loading plans...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.vertical, 20)
        } else if currentOffering != nil, !subscriptionPackages.isEmpty {
            sideBySidePlanCards
                .opacity(appear ? 1 : 0)
        } else {
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.dawnAmber)

                Text("Unable to load plans")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Please check your connection and try again.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)

                Button {
                    Task { await loadOfferings() }
                } label: {
                    Text("Try Again")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Theme.primaryGradient))
                }
            }
            .padding(.vertical, 20)
        }
    }

    private var annualSavingsPercent: String {
        guard let weekly = weeklyPackage, let annual = annualPackage else { return "Save 77%" }
        let weeklyYearly = (weekly.storeProduct.price as Decimal) * 52
        let annualPrice = annual.storeProduct.price as Decimal
        guard weeklyYearly > 0 else { return "" }
        let saved = ((weeklyYearly - annualPrice) / weeklyYearly) * 100
        return "Save \(NSDecimalNumber(decimal: saved).intValue)%"
    }

    private var sideBySidePlanCards: some View {
        VStack(spacing: 14) {
            if let annual = annualPackage {
                annualPlanCard(annual: annual)
            }
            if let weekly = weeklyPackage {
                weeklyPlanCard(weekly: weekly)
            }
        }
    }

    private func annualPlanCard(annual: Package) -> some View {
        let isSelected = selectedPackageID == annual.identifier
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedPackageID = annual.identifier }
        } label: {
            VStack(spacing: 0) {
                HStack {
                    Text("MOST POPULAR")
                        .font(.system(size: 10, weight: .black))
                        .tracking(1)
                        .foregroundStyle(.white)
                    Spacer()
                    Text(annualSavingsPercent)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Theme.dawnGold)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(colors: [Theme.logoIndigo, Theme.logoPurple], startPoint: .leading, endPoint: .trailing)
                )

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Annual")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(annualPerWeekString)
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(.white)
                            Text("/week")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.5))
                        }

                        Text("\(annual.storeProduct.localizedPriceString)/year")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 28))
                            .foregroundStyle(isSelected ? Theme.logoIndigo : .white.opacity(0.2))

                        if isSelected {
                            HStack(spacing: 3) {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 9, weight: .bold))
                                Text("3 DAYS FREE")
                                    .font(.system(size: 9, weight: .black))
                            }
                            .foregroundStyle(Theme.successEmerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Theme.successEmerald.opacity(0.15)))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white.opacity(isSelected ? 0.1 : 0.05))
                    if isSelected {
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                LinearGradient(colors: [Theme.logoBlue, Theme.logoPurple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2.5
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    }
                }
            )
            .clipShape(.rect(cornerRadius: 18))
            .shadow(color: isSelected ? Theme.logoIndigo.opacity(0.35) : .clear, radius: 20, y: 8)
        }
    }

    private func weeklyPlanCard(weekly: Package) -> some View {
        let isSelected = selectedPackageID == weekly.identifier
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedPackageID = weekly.identifier }
        } label: {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(weekly.storeProduct.localizedPriceString)
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(.white)
                        Text("/week")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                Spacer()

                VStack(spacing: 6) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 26))
                        .foregroundStyle(isSelected ? Theme.logoIndigo : .white.opacity(0.2))

                    if isSelected {
                        HStack(spacing: 3) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 9, weight: .bold))
                            Text("3 DAYS FREE")
                                .font(.system(size: 9, weight: .black))
                        }
                        .foregroundStyle(Theme.successEmerald)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.successEmerald.opacity(0.15)))
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white.opacity(isSelected ? 0.08 : 0.04))
                    if isSelected {
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                LinearGradient(colors: [Theme.logoBlue, Theme.logoPurple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 2.5
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    }
                }
            )
            .shadow(color: isSelected ? Theme.logoIndigo.opacity(0.3) : .clear, radius: 16, y: 6)
        }
    }

    private var ctaSection: some View {
        VStack(spacing: 10) {
            Button {
                Task { await purchaseSelected() }
            } label: {
                Group {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Start My Free Trial")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule().fill(
                        selectedPackage != nil
                            ? LinearGradient(colors: [Theme.logoBlue, Theme.logoIndigo, Theme.logoPurple], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                    )
                )
                .shadow(color: selectedPackage != nil ? Theme.logoIndigo.opacity(0.5) : .clear, radius: 16, y: 6)
            }
            .disabled(isPurchasing || isRestoring || selectedPackage == nil)
            .opacity(selectedPackage == nil && !subscriptionService.isLoading ? 0.6 : 1)
            .opacity(appear ? 1 : 0)

            if let pkg = selectedPackage {
                Text(subscriptionDetailText(for: pkg))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 12))
                Text("Cancel anytime. No commitment.")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white.opacity(0.4))
        }
    }

    @ViewBuilder
    private var lifetimeUpsellButton: some View {
        if let pkg = lifetimePackage {
            Button {
                Task { await purchaseLifetime(pkg) }
            } label: {
                HStack(spacing: 10) {
                    if isPurchasingLifetime {
                        ProgressView()
                            .tint(Theme.dawnGold)
                            .controlSize(.small)
                    } else {
                        Image(systemName: "infinity")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Theme.dawnGold)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lifetime Access")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                            Text("\(pkg.storeProduct.localizedPriceString) one-time payment")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.dawnGold.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Theme.dawnGold.opacity(0.25), lineWidth: 1)
                        )
                )
            }
            .disabled(isPurchasing || isRestoring || isPurchasingLifetime)
            .opacity(appear ? 1 : 0)
        }
    }

    private var footerSection: some View {
        VStack(spacing: 10) {
            Button {
                Task { await restore() }
            } label: {
                if isRestoring {
                    ProgressView()
                        .tint(Theme.primary)
                } else {
                    Text("Restore Purchases")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .disabled(isPurchasing || isRestoring)

            Text(subscriptionDisclosure)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            HStack(spacing: 20) {
                Link("Terms of Use (EULA)", destination: URL(string: "https://www.putgodfirstapp.com/terms")!)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                Link("Privacy Policy", destination: URL(string: "https://www.putgodfirstapp.com/privacy")!)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private var noPaymentTrustCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.green)
                Text("No Payment Due Now")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 12) {
                paywallTrustBullet(icon: "checkmark.seal.fill", color: .green, text: "You won\u{2019}t be charged for 3 days")
                paywallTrustBullet(icon: "arrow.counterclockwise", color: Theme.dawnGold, text: "Cancel anytime, no questions asked")
                paywallTrustBullet(icon: "bell.badge.fill", color: Theme.logoBlue, text: "We\u{2019}ll remind you before trial ends")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .opacity(appear ? 1 : 0)
    }

    private func paywallTrustBullet(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func loadOfferings() async {
        loadFailed = false
        await subscriptionService.fetchOfferings()
        if let offering = currentOffering, !offering.availablePackages.isEmpty {
            let ids = offering.availablePackages.map(\.identifier)
            if !ids.contains(selectedPackageID) {
                selectedPackageID = ids.first ?? selectedPackageID
            }
        } else {
            try? await Task.sleep(for: .seconds(2))
            await subscriptionService.fetchOfferings()
            if let offering = currentOffering, !offering.availablePackages.isEmpty {
                let ids = offering.availablePackages.map(\.identifier)
                if !ids.contains(selectedPackageID) {
                    selectedPackageID = ids.first ?? selectedPackageID
                }
            } else {
                loadFailed = true
            }
        }
    }

    private var purchaseButtonTitle: String {
        "Start My Free Trial"
    }

    private var subscriptionDisclosure: String {
        guard let pkg = selectedPackage else {
            return "Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Manage subscriptions in Settings."
        }
        let price = pkg.storeProduct.localizedPriceString
        let period = periodLabel(for: pkg)
        var text = "Payment of \(price)/\(period) will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. Manage subscriptions in your device Settings."
        if let intro = pkg.storeProduct.introductoryDiscount {
            let trialText = trialDurationText(intro.subscriptionPeriod)
            if !trialText.isEmpty {
                text = "Start your \(trialText) free trial. After the trial, " + text.prefix(1).lowercased() + text.dropFirst()
            }
        }
        return text
    }

    private func subscriptionDetailText(for pkg: Package) -> String {
        if pkg.packageType == .annual {
            if let intro = pkg.storeProduct.introductoryDiscount {
                let trialText = trialDurationText(intro.subscriptionPeriod)
                if !trialText.isEmpty {
                    return "\(trialText) free, then just \(annualPerWeekString)/week"
                }
            }
            return "Just \(annualPerWeekString)/week"
        }
        let price = pkg.storeProduct.localizedPriceString
        let period = periodLabel(for: pkg)
        if let intro = pkg.storeProduct.introductoryDiscount {
            let trialText = trialDurationText(intro.subscriptionPeriod)
            if !trialText.isEmpty {
                return "\(trialText) free, then \(price)/\(period)"
            }
        }
        return "\(price)/\(period) auto-renewable subscription"
    }

    private func periodLabel(for pkg: Package) -> String {
        switch pkg.packageType {
        case .annual: return "year"
        case .monthly: return "month"
        case .weekly: return "week"
        case .sixMonth: return "6 months"
        case .threeMonth: return "3 months"
        case .twoMonth: return "2 months"
        default: return "period"
        }
    }

    private func trialDurationText(_ period: SubscriptionPeriod) -> String {
        let value = period.value
        switch period.unit {
        case .day: return "\(value)-day"
        case .week: return "\(value)-week"
        case .month: return "\(value)-month"
        case .year: return "\(value)-year"
        @unknown default: return ""
        }
    }

    private var lifetimePackage: Package? {
        subscriptionService.lifetimePackage
    }

    private func purchaseSelected() async {
        guard let pkg = selectedPackage else {
            errorMessage = "No subscription plan selected. Please select a plan and try again."
            showError = true
            return
        }
        isPurchasing = true
        let success = await subscriptionService.purchase(package: pkg)
        isPurchasing = false
        if success {
            dismiss()
        } else if let err = subscriptionService.errorMessage {
            errorMessage = err
            showError = true
            subscriptionService.errorMessage = nil
        }
    }

    private func purchaseLifetime(_ pkg: Package) async {
        isPurchasingLifetime = true
        let success = await subscriptionService.purchase(package: pkg)
        isPurchasingLifetime = false
        if success {
            dismiss()
        } else if let err = subscriptionService.errorMessage {
            errorMessage = err
            showError = true
            subscriptionService.errorMessage = nil
        }
    }

    private func restore() async {
        isRestoring = true
        let success = await subscriptionService.restorePurchases()
        isRestoring = false
        if success {
            dismiss()
        } else if let err = subscriptionService.errorMessage {
            errorMessage = err
            showError = true
            subscriptionService.errorMessage = nil
        }
    }
}
