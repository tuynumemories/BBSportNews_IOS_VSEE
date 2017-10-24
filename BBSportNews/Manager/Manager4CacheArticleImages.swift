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

    @available(iOS 8.0, *)
    lazy var wkWebView: WKWebView = { [weak self] in
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
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
        
        
        let sendRequestOperation = SendSimpleCacheImageRequestOperation(articleContent, wkWebview: wkWebView, urlString: urlString)
        pendingOperations.sendImageRequestCacheQueue.addOperation(sendRequestOperation)
//        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
//        guard let detect = detector else {
//            return
//        }
//        let matches = detect.matches(in: articleContent, options: .reportCompletion, range: NSMakeRange(0, articleContent.characters.count))
//
//        let imageExtensions = ["png", "jpg", "gif"]
//        for match in matches {
//            if let url = match.url {
//                let ext = url.pathExtension
//                if imageExtensions.contains(ext) {
//                    startCacheArticleImage(url)
//                }
//            }
//        }
    }
    
//    func startCacheArticleImage(_ url: URL) {
//        let sendRequestOperation = SendSimpleCacheImageRequestOperation(url, wkWebView: wkWebView)
//        pendingOperations.sendImageRequestCacheQueue.addOperation(sendRequestOperation)
//    }
}

// operation for run caching article from server
class SendSimpleCacheImageRequestOperation: ModifyOperation {
    var htmlString: String
    var urlString: String
    weak var wkWebview: WKWebView?
    
    init(_ htmlString: String, wkWebview: WKWebView?, urlString: String) {
        self.htmlString = htmlString
        self.wkWebview = wkWebview
        self.urlString = urlString
    }
    override func start() {
        super.start()
        DispatchQueue.main.async {
            self.wkWebview?.navigationDelegate = self
            self.wkWebview?.loadHTMLString(self.htmlString, baseURL: nil)
//            self.wkWebview?.load(<#T##request: URLRequest##URLRequest#>)
        }
    }
}

// MARK: - WKNavigationDelegate
extension SendSimpleCacheImageRequestOperation: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("start load content")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        wkWebview?.navigationDelegate = nil
        print("finish load content")
        self.completeOperation()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        wkWebview?.navigationDelegate = nil
        print("finish load content")
        self.completeOperation()
    }
}
