import SwiftUI
import WebKit

struct CustomWebView: UIViewRepresentable {
    let selectedTexture: String
    @Binding var isSoundMuted: Bool
    @Binding var currentScreen: ScreenState
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.add(context.coordinator, name: "onButtonClick")
        
        context.coordinator.webViewReference = webView
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let textureScript = "window.selectedTexture = '\(selectedTexture)';"
        webView.evaluateJavaScript(textureScript) { result, error in
            if let error = error {
                print("Error setting selectedTexture: \(error)")
            } else {
                print("Successfully set selectedTexture to: \(selectedTexture)")
            }
        }
        
        let soundScript = "window.isMuted = \(isSoundMuted ? "true" : "false");"
        webView.evaluateJavaScript(soundScript) { result, error in
            if let error = error {
                print("Error updating mute state: \(error)")
            } else {
                print("Successfully updated mute state.")
            }
        }
        
        //URL с параметром isMuted
        let baseAddress = "https://mobilbah.space"
        let queryString = "\(baseAddress)?isMuted=\(isSoundMuted)"
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: queryString) {
                let request = URLRequest(url: url)
                DispatchQueue.main.async {
                    webView.load(request)
                }
            }
        }
        
    }
    
    class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parentView: CustomWebView
        weak var webViewReference: WKWebView?
        
        init(_ parentView: CustomWebView) {
            self.parentView = parentView
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "onButtonClick" {
                if let body = message.body as? [String: String], let action = body["action"] {
                    DispatchQueue.main.async {
                        switch action {
                        case "start":
                            self.parentView.currentScreen = .play
                        case "color":
                            self.parentView.currentScreen = .mode
                        case "policy":
                            self.parentView.currentScreen = .policy
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        deinit {
            webViewReference?.configuration.userContentController.removeScriptMessageHandler(forName: "onButtonClick")
        }
    }
}
