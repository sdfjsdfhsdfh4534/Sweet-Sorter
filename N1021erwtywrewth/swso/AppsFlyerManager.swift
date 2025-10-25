import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

class AppsFlyerManager: NSObject, AppsFlyerLibDelegate {
    static let shared = AppsFlyerManager()
    private var h0hpf3e7 = false
    private var eaf2w7uu: ((String?) -> Void)?

    func deme59ii(completion: @escaping (String?) -> Void) {
        self.eaf2w7uu = completion

        DispatchQueue.main.asyncAfter(deadline: .now() + c2nxz5zh) {
            self.forceUpdateATTStatus()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + ycbj8ahy) {
            if !self.h0hpf3e7 {
                self.eaf2w7uu?(nil)
            }
        }
    }

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        if let campaign = data["campaign"] as? String {
            let components = campaign.split(separator: "_")
            var parameters = ""
            for (index, value) in components.enumerated() {
                parameters += "sub\(index + 1)=\(value)"
                if index < components.count - 1 {
                    parameters += "&"
                }
            }
            h0hpf3e7 = true
            eaf2w7uu?("&" + parameters)
        } else {
            h0hpf3e7 = true
            eaf2w7uu?(nil)
        }
    }

    func onConversionDataFail(_ error: Error) {
        eaf2w7uu?(nil)
    }
    
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        if let campaign = attributionData["campaign"] as? String {
            let components = campaign.split(separator: "_")
            var parameters = ""
            for (index, value) in components.enumerated() {
                parameters += "sub\(index + 1)=\(value)"
                if index < components.count - 1 {
                    parameters += "&"
                }
            }
            h0hpf3e7 = true
            eaf2w7uu?("&" + parameters)
        }
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        eaf2w7uu?(nil)
    }
    
    private func forceUpdateATTStatus() {
        let currentStatus = ATTrackingManager.trackingAuthorizationStatus
        
        if currentStatus == .authorized {
            AppsFlyerLib.shared().start()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + os8cnlv0) {
                let isTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
                if isTrackingEnabled {
                    AppsFlyerLib.shared().start()
                }
            }
        }
    }
} 
