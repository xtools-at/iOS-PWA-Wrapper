//
//  ViewController.swift
//  ios-pwa-wrapper
//
//  Created by Martin Kainzbauer on 25/10/2017.
//  Copyright © 2017 Martin Kainzbauer. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var leftButton: UIBarButtonItem!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var webViewContainer: UIView!
    // MARK: Globals
    var webView: WKWebView!
    var progressBar : UIProgressView!
    let appUrl = URL(string: "https://www.duckduckgo.com/")
    let allowedOrigin = "duckduckgo.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupApp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UI Actions
    @IBAction func onLeftButtonClick(_ sender: Any) {
        if (webView.canGoBack) {
            webView.goBack()
        }
    }
    @IBAction func onRightButtonClick(_ sender: Any) {
        webView.evaluateJavaScript("alert('boom')", completionHandler: nil)
    }
    
    // Observers for updating UI
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(WKWebView.isLoading)) {
            leftButton.isEnabled = webView.canGoBack
        }
        if (keyPath == #keyPath(WKWebView.estimatedProgress)) {
            progressBar.progress = Float(webView.estimatedProgress)
            rightButton.isEnabled = (webView.estimatedProgress == 1)
        }
    }
    
    // Initialize WKWebView
    func setupWebView() {
        // set up webview
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: webViewContainer.frame.height))
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webViewContainer.addSubview(webView)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // settings
        webView.allowsBackForwardNavigationGestures = true

        // init observers
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // Initialize UI
    func setupUI() {
        // UI elements
        leftButton.isEnabled = false
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: 50))
        progressBar.autoresizingMask = [.flexibleWidth]
        progressBar.progress = 0.0
        progressBar.tintColor = UIColor.green.withAlphaComponent(0.6)
        webView.addSubview(progressBar)
    }
    
    // Initialize App and start loading
    func setupApp() {
        setupWebView()
        setupUI()

        // load startpage
        let urlRequest = URLRequest(url: appUrl!)
        webView.load(urlRequest)
    }
    
    // Cleanup
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

// WebView Event Listeners
extension ViewController: WKNavigationDelegate {
    // didFinish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // set title
        navigationItem.title = webView.title
        // hide progress bar
        progressBar.isHidden = true
    }
    // didFailProvisionalNavigation
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show offline screen
        // @TODO
        let alert = UIAlertController(title: "You're offline", message: "didFailProvisionalNavigation", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    // didFail
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // show offline screen
        // @TODO
        let alert = UIAlertController(title: "You're offline", message: "didFail", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// WebView
extension ViewController: WKUIDelegate {
    // handle links opening in new tabs
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (navigationAction.targetFrame == nil) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    // restrict navigation to target host, open external links in Safari
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestUrl = navigationAction.request.url {
            if let requestHost = requestUrl.host {
                if (requestHost.range(of: allowedOrigin) != nil ) {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                    if (UIApplication.shared.canOpenURL(requestUrl)) {
                        UIApplication.shared.open(requestUrl)
                    }
                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}
