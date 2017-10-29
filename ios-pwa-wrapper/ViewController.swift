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
    @IBOutlet weak var offlineContainer: UIStackView!
    @IBOutlet weak var offlineIcon: UIImageView!
    @IBOutlet weak var offlineButton: UIButton!
    
    // MARK: Globals
    var webView: WKWebView!
    var progressBar : UIProgressView!

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
    // handle back press
    @IBAction func onLeftButtonClick(_ sender: Any) {
        if (webView.canGoBack) {
            webView.goBack()
        } else {
            // exit app
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
    }
    // open menu in page
    @IBAction func onRightButtonClick(_ sender: Any) {
        webView.evaluateJavaScript(menuButtonJavascript, completionHandler: nil)
    }
    @IBAction func onOfflineButtonClick(_ sender: Any) {
        offlineContainer.isHidden = true
        webViewContainer.isHidden = false
        loadAppUrl()
    }
    
    // Observers for updating UI
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(WKWebView.isLoading)) {
            // does not fire for PWAs if links are clicked
            // leftButton.isEnabled = webView.canGoBack
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
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webViewContainer.addSubview(webView)
        
        // settings
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.ignoresViewportScaleLimits = false
        webView.configuration.preferences.javaScriptEnabled = true
        // user agent
        if (useCustomUserAgent) {
            webView.customUserAgent = customUserAgent
        }
        if (useUserAgentPostfix) {
            if (useCustomUserAgent) {
                webView.customUserAgent = customUserAgent + " " + userAgentPostfix
            } else {
                webView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
                    if let resultObject = result {
                        self.webView.customUserAgent = (String(describing: resultObject) + " " + userAgentPostfix)
                    }
                })
            }
        }
        webView.configuration.applicationNameForUserAgent = ""

        // init observers
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // Initialize UI elements
    // call after WebView has been initialized
    func setupUI() {
        // leftButton.isEnabled = false

        // progress bar
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: 40))
        progressBar.autoresizingMask = [.flexibleWidth]
        progressBar.progress = 0.0
        progressBar.tintColor = progressBarColor
        webView.addSubview(progressBar)
        
        // offline container
        offlineIcon.tintColor = offlineIconColor
        offlineButton.tintColor = buttonColor
        offlineContainer.isHidden = true
        
        // setup navigation
        navigationItem.title = appTitle
        if (forceLargeTitle) {
            navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.always
        }
        if (useLightStatusBarStyle) {
            self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        }
        
        /*
        // @DEBUG: test offline view
        offlineContainer.isHidden = false
        webViewContainer.isHidden = true
        */
    }
    
    // load startpage
    func loadAppUrl() {
        let urlRequest = URLRequest(url: webAppUrl!)
        webView.load(urlRequest)
    }
    
    // Initialize App and start loading
    func setupApp() {
        setupWebView()
        setupUI()
        loadAppUrl()
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
        if (changeAppTitleToPageTitle) {
            navigationItem.title = webView.title
        }
        // hide progress bar after initial load
        progressBar.isHidden = true
    }
    // didFailProvisionalNavigation
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show offline screen
        offlineContainer.isHidden = false
        webViewContainer.isHidden = true
    }
}

// WebView additional handlers
extension ViewController: WKUIDelegate {
    // handle links opening in new tabs
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (navigationAction.targetFrame == nil) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    // restrict navigation to target host, open external links in 3rd party apps
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
