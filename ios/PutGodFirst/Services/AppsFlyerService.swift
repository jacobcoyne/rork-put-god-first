import Foundation
import AppsFlyerLib

class AppsFlyerService: NSObject {
    static let shared = AppsFlyerService()

    private override init() {
        super.init()
    }

    func configure() {
        AppsFlyerLib.shared().appsFlyerDevKey = Config.EXPO_PUBLIC_APPSFLYER_DEV_KEY
        AppsFlyerLib.shared().appleAppID = Config.EXPO_PUBLIC_APPLE_APP_ID
        AppsFlyerLib.shared().delegate = self
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
    }

    func start() {
        AppsFlyerLib.shared().start()
    }

    func logEvent(_ eventName: String, values: [String: Any]? = nil) {
        AppsFlyerLib.shared().logEvent(eventName, withValues: values)
    }
}

extension AppsFlyerService: AppsFlyerLibDelegate {
    nonisolated func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        if let status = conversionInfo["af_status"] as? String {
            if status == "Non-organic" {
                if let sourceID = conversionInfo["media_source"],
                   let campaign = conversionInfo["campaign"] {
                    print("[AppsFlyer] Non-Organic install - Media Source: \(sourceID), Campaign: \(campaign)")
                }
            } else {
                print("[AppsFlyer] Organic install")
            }
        }
    }

    nonisolated func onConversionDataFail(_ error: any Error) {
        print("[AppsFlyer] Conversion data error: \(error.localizedDescription)")
    }
}
