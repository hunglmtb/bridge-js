//
//  ViewController.swift
//  ExampleSwiftApp-iOS
//
//  Created by John Marcus Westin on 12/27/16.
//  Copyright © 2016 Marcus Westin. All rights reserved.
//

import UIKit
import WebKit
import WebViewJavascriptBridge

class ViewController: UIViewController,
WKNavigationDelegate,
WKScriptMessageHandler {
    
    var webView: WKWebView!

    override func loadView() {
        let config = WKWebViewConfiguration()
//        let source = "document.addEventListener('message', function(e){window.webkit.messageHandlers.iosListener.postMessage(e.data); })"
//        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//        config.userContentController.addUserScript(script)
//        config.userContentController.add(self, name: "iosListener")
    
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        let request = URLRequest.init(url: Bundle.main.url(forResource: "echo3", withExtension: "html")!)
        let url = URL(string: "https://iopay.iotex.io/vita")!
        let request2 = URLRequest(url: url)
        webView.load(request2)
//        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func bridgeForWebView(_ webView: WKWebView!) -> WKWebViewJavascriptBridge {
        let bridge = WKWebViewJavascriptBridge.init(for: webView)!
        return bridge
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        print("message: \(message.body)")
        // and whatever other actions you want to take
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Start loading")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("End loading")
        let bridge = self.bridgeForWebView(webView)
        bridge.registerHandler("Greet") { (data, responseCallback) in
            print("greet callback")
            print(data)
        }
    }
    
    
}
