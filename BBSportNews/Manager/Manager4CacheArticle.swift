//
//  Manager4CacheArticle.swift
//  BBSportNews
//
//  Created by dat on 10/24/17.
//  Copyright © 2017 dat. All rights reserved.
//

import Foundation

class Manager4CacheArticle{
    public static let shared = Manager4CacheArticle()
    let pendingOperations = PendingOperations()
    let maxFailedRequest = 3
    var dicOfCachingArticleOperation = [String: SendSimpleCacheRequestOperation]()
    
    /// get local cache request path
    var prefixLocalRequestCachePath: String? {
        return "/HttpRequestCache"
    }
    
    /// cache all articles
    func cacheAllArticles(articles: [Article]?) {
        guard let articles = articles else {
            return
        }
        // add all request into download queue
        for article in articles {
            startCacheArticles(urlStr: article.url, numberOfFailedRequest: 0)
        }
    }
    
    /// cancel all cache request operations
    func cancelAllArticles() {
        pendingOperations.sendRequestCacheQueue.cancelAllOperations()
        Manager4CacheArticleHtmlContent.shared.cancelAllImages()
    }
    
    /// start call request to cache article if not try too much times
    ///
    /// - Parameters:
    ///   - urlStr: url of article
    ///   - numberOfRequested: number of fail request
    func startCacheArticles(urlStr: String?, numberOfFailedRequest: Int?) {
        
        guard let urlStr = urlStr,
        let numberOfFailedRequest = numberOfFailedRequest,
        numberOfFailedRequest <= maxFailedRequest else {
            return
        }
        let sendRequestOperation = SendSimpleCacheRequestOperation(urlStr: urlStr, numberOfFailedRequest: numberOfFailedRequest)
        dicOfCachingArticleOperation[urlStr] = sendRequestOperation
        pendingOperations.sendRequestCacheQueue.addOperation(sendRequestOperation)
    }
    
    /// stop caching article
    ///
    /// - Parameter urlStr: url of article
    func stopCachingArticle(urlStr: String) {
        guard let sendRequestOperation = dicOfCachingArticleOperation[urlStr] else {
            return
        }
        sendRequestOperation.cancel()
        removeCachedArticle(urlStr: urlStr)
    }
    
    /// remove cached article from dicOfCachingArticleOperation
    ///
    /// - Parameter urlStr: url of article
    func removeCachedArticle(urlStr: String?) {
        guard let urlStr = urlStr else { return }
        dicOfCachingArticleOperation[urlStr] = nil
    }
}

// operation for run caching article from server
class SendSimpleCacheRequestOperation: ModifyOperation {
    var urlStr: String
    var numberOfFailedRequest: Int
    
    init(urlStr: String, numberOfFailedRequest: Int) {
        self.urlStr = urlStr
        self.numberOfFailedRequest = numberOfFailedRequest
    }
    override func start() {
        super.start()
        print("start cache for article \(urlStr)")
        Manager4Network.shared.getDataFromUrl(urlString: urlStr, completionHandler: {
            [weak self](data, error, _) in
            Manager4CacheArticle.shared.removeCachedArticle(urlStr: self?.urlStr)
            if let numberOfFailedRequest = self?.numberOfFailedRequest,
                data == nil{
                // try again if network error
                Manager4CacheArticle.shared.startCacheArticles(urlStr: self?.urlStr, numberOfFailedRequest: numberOfFailedRequest + 1)
            } else if data != nil {
                Manager4CacheArticleHtmlContent.shared.cacheAllArticleImages(data!, urlString: self?.urlStr)
            }
            self?.completeOperation()
        })
        
    }
}



class ModifyOperation: Operation {
    private(set) var error: NSError?
    private var _executing: Bool = false // Notice the _ before the name
    private var _finished: Bool = false // Notice the _ before the name
    override var isAsynchronous: Bool { return true }
    override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting") // This must match the overriden variable
            _executing = newValue
            didChangeValue(forKey: "isExecuting") // This must match the overriden variable
        }
    }
    override var isFinished: Bool {
        get { return _finished}
        set {
            willChangeValue(forKey: "isFinished") // This must match the overriden variable
            _finished = newValue
            didChangeValue(forKey: "isFinished") // This must match the overriden variable
        }
    }
    func completeOperation() {
        isFinished = true
        isExecuting = false
    }
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
    }
}
