import Foundation
import RevenueCat

@MainActor
@Observable
final class SubscriptionService: NSObject {
    static let shared = SubscriptionService()

    var isProUser: Bool = false
    var isLifetimeUser: Bool = false
    var offerings: Offerings?
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var errorMessage: String?

    private let entitlementID = "Put God First: Christian Focus Pro"

    private override init() {
        super.init()
    }

    func configure() {
        #if DEBUG
        Purchases.logLevel = .debug
        let apiKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        #else
        let apiKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        #endif

        guard !apiKey.isEmpty else { return }
        Purchases.configure(withAPIKey: apiKey)
        Purchases.shared.delegate = self
    }

    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let entitlement = customerInfo.entitlements[entitlementID]
            isProUser = entitlement?.isActive == true
            isLifetimeUser = entitlement?.isActive == true && entitlement?.expirationDate == nil
        } catch {
            isProUser = false
            isLifetimeUser = false
        }
    }

    func fetchOfferings() async {
        isLoading = true
        defer { isLoading = false }
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var lifetimePackage: Package? {
        offerings?.current?.lifetime ?? offerings?.current?.availablePackages.first { $0.packageType == .lifetime }
    }

    func purchase(package: Package) async -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.userCancelled { return false }
            let entitlement = result.customerInfo.entitlements[entitlementID]
            let active = entitlement?.isActive == true
            isProUser = active
            isLifetimeUser = active && entitlement?.expirationDate == nil
            return active
        } catch {
            let nsError = error as NSError
            if nsError.code == ErrorCode.purchaseCancelledError.rawValue {
                return false
            }
            errorMessage = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let entitlement = customerInfo.entitlements[entitlementID]
            let active = entitlement?.isActive == true
            isProUser = active
            isLifetimeUser = active && entitlement?.expirationDate == nil
            return active
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

extension SubscriptionService: @preconcurrency PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            let entitlement = customerInfo.entitlements[entitlementID]
            isProUser = entitlement?.isActive == true
            isLifetimeUser = entitlement?.isActive == true && entitlement?.expirationDate == nil
        }
    }
}
