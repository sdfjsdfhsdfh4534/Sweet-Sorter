import SwiftUI
import WebKit
import UserNotifications
import Combine

class f6d9vrhd: ObservableObject {
    @Published var webView: WKWebView?
    @Published var canGoBack = false
    @Published var o44y320j: [WKWebView] = []
    @Published var isLoading = false
    private var navigationTimer: Timer?
    private var lastBackButtonTap: Date?
    
    func sugcgql9(_ webView: WKWebView) {
        self.webView = webView
        t5g7n4yq()
    }
    
    func t5g7n4yq() {
        let activeWebView = blorlot2()
        canGoBack = activeWebView.canGoBack || !o44y320j.isEmpty
    }
    
    func goBack() {
        let now = Date()
        
        if let lastTap = lastBackButtonTap, now.timeIntervalSince(lastTap) < 2.0 {
            forceGoBack()
            lastBackButtonTap = nil
            return
        }
        
        lastBackButtonTap = now
        let activeWebView = blorlot2()
        
        if isLoading {
            activeWebView.stopLoading()
            stopLoading()
        }
        
        if activeWebView.canGoBack {
            startNavigationTimeout()
            activeWebView.goBack()
        } else if !o44y320j.isEmpty {
            if let lastOverlay = o44y320j.last {
                ro05nxcz(lastOverlay)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.t5g7n4yq()
        }
    }
    
    func startLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        startNavigationTimeout()
    }
    
    func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
        stopNavigationTimeout()
    }
    
    private func startNavigationTimeout() {
        stopNavigationTimeout()
        navigationTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.handleNavigationTimeout()
        }
    }
    
    private func stopNavigationTimeout() {
        navigationTimer?.invalidate()
        navigationTimer = nil
    }
    
    private func handleNavigationTimeout() {
        let activeWebView = blorlot2()
        
        // Останавливаем загрузку если она зависла
        if isLoading {
            activeWebView.stopLoading()
            stopLoading()
            
            if activeWebView.canGoBack {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    activeWebView.goBack()
                    self.startNavigationTimeout() // Запускаем таймер снова
                }
            }
        }
        
        t5g7n4yq()
    }
    
    private func stopLoadingWithTimeout() {
        let activeWebView = blorlot2()
        activeWebView.stopLoading()
        stopLoading()
        
        // Попробуем перейти назад после остановки загрузки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if activeWebView.canGoBack {
                activeWebView.goBack()
            }
            self.t5g7n4yq()
        }
    }
    
    func handleCancelledNavigation(_ webView: WKWebView) {
        stopLoading()
        
        webView.evaluateJavaScript("window.history.back();") { result, error in
            if let error = error {
                // Если JavaScript не сработал, пробуем альтернативные методы
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.tryAlternativeBackNavigation(webView)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.t5g7n4yq()
                }
            }
        }
    }
    
    private func tryAlternativeBackNavigation(_ webView: WKWebView) {
        // Получаем список истории через JavaScript
        webView.evaluateJavaScript("window.history.length") { result, error in
            if let historyLength = result as? Int, historyLength > 1 {
                // Пробуем перейти на предыдущую страницу через JavaScript
                webView.evaluateJavaScript("window.history.go(-1);") { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.t5g7n4yq()
                    }
                }
            } else {
                if !self.o44y320j.isEmpty {
                    if let lastOverlay = self.o44y320j.last {
                        self.ro05nxcz(lastOverlay)
                    }
                } else {
                    webView.reload()
                }
            }
        }
    }
    
    func forceGoBack() {
        let activeWebView = blorlot2()
        
        activeWebView.stopLoading()
        stopLoading()
        
        var attempts = 0
        let maxAttempts = 3
        
        func attemptGoBack() {
            attempts += 1
            
            if activeWebView.canGoBack && attempts <= maxAttempts {
                activeWebView.goBack()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if self.isLoading && attempts < maxAttempts {
                        activeWebView.stopLoading()
                        self.stopLoading()
                        attemptGoBack()
                    } else {
                        self.t5g7n4yq()
                    }
                }
            } else if !o44y320j.isEmpty {
                if let lastOverlay = o44y320j.last {
                    ro05nxcz(lastOverlay)
                }
            }
        }
        
        attemptGoBack()
    }
    
    func pluaz0bs(to url: URL) {
        o44y320j.removeAll()
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        
        startLoading()
        webView?.load(request)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.t5g7n4yq()
        }
    }
    
    func py204rbm(_ webView: WKWebView) {
        o44y320j.append(webView)
        t5g7n4yq()
    }
    
    func ro05nxcz(_ webView: WKWebView) {
        o44y320j.removeAll { $0 === webView }
        t5g7n4yq()
    }
    
    private func blorlot2() -> WKWebView {
        return o44y320j.last ?? webView ?? WKWebView()
    }
}

struct zestp4m0: View {
    let url: URL
    let vz58a0os: oquisik9
    let pazqgxm6: ((URL) -> Void)?
    
    @StateObject private var xga71bi3 = f6d9vrhd()

    init(url: URL, vz58a0os: oquisik9 = .none, pazqgxm6: ((URL) -> Void)? = nil) {
        self.url = url
        self.vz58a0os = vz58a0os
        self.pazqgxm6 = pazqgxm6
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                z2a8qfvp(url: url, pazqgxm6: pazqgxm6, xga71bi3: xga71bi3)
                
                ForEach(Array(xga71bi3.o44y320j.enumerated()), id: \.offset) { index, overlayWebView in
                    eppacdk7(webView: overlayWebView, xga71bi3: xga71bi3)
                }
            }
            
            if vz58a0os != .none {
                ygvg4hj8(vz58a0os: vz58a0os, xga71bi3: xga71bi3, rgllvp31: url)
            }
        }
    }
}

struct z2a8qfvp: UIViewRepresentable {
    let url: URL
    let pazqgxm6: ((URL) -> Void)?
    let xga71bi3: f6d9vrhd

    init(url: URL, pazqgxm6: ((URL) -> Void)? = nil, xga71bi3: f6d9vrhd) {
        self.url = url
        self.pazqgxm6 = pazqgxm6
        self.xga71bi3 = xga71bi3
    }

    func makeUIView(context: Context) -> UIView {
        requestNotificationPermission()
        let config = WKWebViewConfiguration()
        
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        if #available(iOS 14.0, *) {
            config.limitsNavigationsToAppBoundDomains = false
        }
        
        config.preferences.isFraudulentWebsiteWarningEnabled = false
        config.suppressesIncrementalRendering = false
        
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        config.allowsAirPlayForMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.overrideUserInterfaceStyle = .dark
        webView.allowsBackForwardNavigationGestures = false // Отключаем для единообразия
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        webView.load(request)
        
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        containerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(d3lkphxo.j137k2fl(_:)))
        swipeGesture.direction = .right
        containerView.addGestureRecognizer(swipeGesture)
        
        DispatchQueue.main.async {
            xga71bi3.sugcgql9(webView)
        }
        
        return containerView
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка при запросе разрешения: \(error.localizedDescription)")
                return
            }
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    func makeCoordinator() -> d3lkphxo {
        d3lkphxo(pazqgxm6: pazqgxm6, xga71bi3: xga71bi3)
    }
}

struct ygvg4hj8: View {
    let vz58a0os: oquisik9
    @ObservedObject var xga71bi3: f6d9vrhd
    let rgllvp31: URL
    
    init(vz58a0os: oquisik9, xga71bi3: f6d9vrhd, rgllvp31: URL) {
        self.vz58a0os = vz58a0os
        self.xga71bi3 = xga71bi3
        self.rgllvp31 = rgllvp31
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                xga71bi3.goBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(xga71bi3.canGoBack ? .white : .gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .disabled(!xga71bi3.canGoBack)
            
            if vz58a0os == .ncwvz0ri {
                // Разделитель
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                
                // Кнопка домой
                Button(action: {
                    xga71bi3.pluaz0bs(to: rgllvp31)
                }) {
                    Image(systemName: "house")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.black)
        .frame(height: 50)
        .background(Color.black) 
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension z2a8qfvp {
    class d3lkphxo: NSObject, WKNavigationDelegate, WKUIDelegate {
        let pazqgxm6: ((URL) -> Void)?
        private var ufhizdz0 = false
        weak var xga71bi3: f6d9vrhd?

        init(pazqgxm6: ((URL) -> Void)? = nil, xga71bi3: f6d9vrhd) {
            self.pazqgxm6 = pazqgxm6
            self.xga71bi3 = xga71bi3
        }
        
        @objc func j137k2fl(_ gesture: UISwipeGestureRecognizer) {
            xga71bi3?.goBack()
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.xga71bi3?.startLoading()
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // Навигация началась, но страница может еще загружаться
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if !ufhizdz0, let currentURL = webView.url {
                ufhizdz0 = true
                pazqgxm6?(currentURL)
            }
            
            DispatchQueue.main.async {
                self.xga71bi3?.stopLoading()
                self.xga71bi3?.t5g7n4yq()
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                DispatchQueue.main.async {
                    self.xga71bi3?.handleCancelledNavigation(webView)
                }
            } else {
                DispatchQueue.main.async {
                    self.xga71bi3?.stopLoading()
                    self.xga71bi3?.t5g7n4yq()
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                DispatchQueue.main.async {
                    self.xga71bi3?.handleCancelledNavigation(webView)
                }
            } else {
                DispatchQueue.main.async {
                    self.xga71bi3?.stopLoading()
                    self.xga71bi3?.t5g7n4yq()
                }
            }
        }
        


        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let url = navigationAction.request.url {
                let scheme = url.scheme?.lowercased() ?? ""
                
                if scheme == "about" {
                    decisionHandler(.allow)
                    return
                }
                
                if url.host?.contains("challenges.cloudflare.com") == true {
                    decisionHandler(.allow)
                    return
                }
                
                if ["http", "https"].contains(scheme) {
                    decisionHandler(.allow)
                } else if ["tel", "mailto", "sms"].contains(scheme) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.allow)
            }
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            let overlayWebView = WKWebView(frame: .zero, configuration: configuration)
            overlayWebView.navigationDelegate = self
            overlayWebView.uiDelegate = self
            overlayWebView.overrideUserInterfaceStyle = .dark
            overlayWebView.allowsBackForwardNavigationGestures = false
            overlayWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            
            DispatchQueue.main.async {
                self.xga71bi3?.py204rbm(overlayWebView)
                
                var request = navigationAction.request
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
                overlayWebView.load(request)
            }
            
            return overlayWebView
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = defaultText
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(nil)
            })
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(alert.textFields?.first?.text)
            })
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            }
        }
    }
}

struct eppacdk7: UIViewRepresentable {
    let webView: WKWebView
    let xga71bi3: f6d9vrhd
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .black.withAlphaComponent(0.95)
        
        containerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: containerView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        let swipeGesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(xmy1i8nw.j137k2fl(_:)))
        swipeGesture.direction = .right
        containerView.addGestureRecognizer(swipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(xmy1i8nw.dr2qghhe(_:)))
        tapGesture.numberOfTapsRequired = 2
        containerView.addGestureRecognizer(tapGesture)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> xmy1i8nw {
        xmy1i8nw(webView: webView, xga71bi3: xga71bi3)
    }
}

class xmy1i8nw: NSObject {
    let webView: WKWebView
    let xga71bi3: f6d9vrhd
    
    init(webView: WKWebView, xga71bi3: f6d9vrhd) {
        self.webView = webView
        self.xga71bi3 = xga71bi3
    }
    
    @objc func j137k2fl(_ gesture: UISwipeGestureRecognizer) {
        // Используем улучшенную логику навигации назад
        xga71bi3.goBack()
    }
    
    @objc func dr2qghhe(_ gesture: UITapGestureRecognizer) {
        xga71bi3.ro05nxcz(webView)
    }
}
