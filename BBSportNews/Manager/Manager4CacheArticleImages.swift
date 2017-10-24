//
//  Manager4CacheArticleImages.swift
//  BBSportNews
//
//  Created by dat on 10/24/17.
//  Copyright © 2017 dat. All rights reserved.
//

import Foundation
import WebKit

class Manager4CacheArticleImages{
    public static let shared = Manager4CacheArticleImages()
    let pendingOperations = PendingOperations()

    // Use webview to cache all content in html article
    @available(iOS 8.0, *)
    lazy var wkWebView: WKWebView = { [weak self] in
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
        }()
    
    lazy var uiWebView: UIWebView = { [weak self] in
        let webView:UIWebView = UIWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
        }()
    
    /// cancel all cache request operations
    func cancelAllImages() {
        pendingOperations.sendImageRequestCacheQueue.cancelAllOperations()
    }
    
    /// cache all articles
    func cacheAllArticleImages(_ articleContentData: Data, urlString: String?) {
        guard let articleContent = String(data: articleContentData, encoding: String.Encoding.utf8),
        let urlString = urlString else {
            return
        }
        
        var sendRequestOperation: SendSimpleCacheImageRequestOperation
        if #available(iOS 8, *) {
            sendRequestOperation = SendSimpleCacheImageRequestOperationWKWebview(articleContent, wkWebview: wkWebView, urlString: urlString)
        } else {
            sendRequestOperation = SendSimpleCacheImageRequestOperationUIWebview(articleContent, uiWebview: uiWebView, urlString: urlString)
        }
        pendingOperations.sendImageRequestCacheQueue.addOperation(sendRequestOperation)

    }
}



// operation for run caching article from server
class SendSimpleCacheImageRequestOperation: ModifyOperation {
    var htmlString: String
    var urlString: String
    init(_ htmlString: String, urlString: String) {
        self.htmlString = htmlString
        self.urlString = urlString
    }
    
    public func webViewDidStartLoad() {
        print("start to load")
    }
    public func webViewDidFinishLoad() {
        print("finish to load")
        self.completeOperation()
    }
    public func webViewDidFailLoad(_ error: Error) {
        print(error.localizedDescription)
    }
}

/// use WKWebView to cache for ios >= 8.0
class SendSimpleCacheImageRequestOperationWKWebview: SendSimpleCacheImageRequestOperation {
    weak var wkWebview: WKWebView?
    
    init(_ htmlString: String, wkWebview: WKWebView?, urlString: String) {
        super.init(htmlString, urlString: urlString)
        self.wkWebview = wkWebview
    }
    override func start() {
        super.start()
        DispatchQueue.main.async {
            print("Cache image for \(self.urlString)")
            self.wkWebview?.navigationDelegate = self
            self.wkWebview?.loadHTMLString(self.htmlString, baseURL: nil)
        }
    }
}

/// use UIWebView to cache for ios < 8.0
class SendSimpleCacheImageRequestOperationUIWebview: SendSimpleCacheImageRequestOperation {
    weak var uiWebview: UIWebView?
    
    init(_ htmlString: String, uiWebview: UIWebView?, urlString: String) {
        super.init(htmlString, urlString: urlString)
        self.uiWebview = uiWebview
    }
    override func start() {
        super.start()
        DispatchQueue.main.async {
            print("Cache image for \(self.urlString)")
            self.uiWebview?.delegate = self
            self.uiWebview?.loadHTMLString(self.htmlString, baseURL: nil)
        }
    }
}

// MARK: - WKNavigationDelegate
extension SendSimpleCacheImageRequestOperationWKWebview: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webViewDidStartLoad()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        wkWebview?.navigationDelegate = nil
        webViewDidFinishLoad()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        wkWebview?.navigationDelegate = nil
        webViewDidFailLoad(error)
    }
}
// MARK: - UIWebViewDelegate
extension SendSimpleCacheImageRequestOperationUIWebview: UIWebViewDelegate {
    public func webViewDidStartLoad(_ webView: UIWebView) {
        webViewDidStartLoad()
    }
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        uiWebview?.delegate = nil
        webViewDidFinishLoad()
    }
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        uiWebview?.delegate = nil
        webViewDidFailLoad(error)
    }
}
