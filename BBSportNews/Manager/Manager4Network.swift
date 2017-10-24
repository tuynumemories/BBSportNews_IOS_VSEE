//
//  Manager4Network.swift
//  BBSportNews
//
//  Created by dat on 10/23/17.
//  Copyright © 2017 dat. All rights reserved.
//

import UIKit

enum BackendError: Error {
    case urlError(reason: String)
    case objectSerialization(reason: String)
}

class Manager4Network{
    public static let shared = Manager4Network()
    public static let NW_TIMEOUT: TimeInterval = 10.0
    
    func getArticlesListFromSV(completionHandler: ((BBCSportNews?, Error?, Bool) -> Void)?) {
        getDataFromUrl(
            urlString: "https://newsapi.org/v1/articles?source=bbc-sport&sortBy=top&apiKey=a720b6e614e14f8ca47f0441f5972e76",
            completionHandler: {
            (data, error, isCached) in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let todo = try decoder.decode(BBCSportNews.self, from: data)
                    completionHandler?(todo, nil, isCached)
                } catch {
                    print("error trying to convert data to JSON : \(error)")
                    completionHandler?(nil, error, isCached)
                }
            } else {
                completionHandler?(nil, error, isCached)
            }
        }
        )
    }
    
    func getImageFromUrl(urlString: String, completionHandler: ((UIImage?, Error?) -> Void)?) {
        getDataFromUrl(urlString: urlString) { (data, error, isCached) in
            if let data = data {
                completionHandler?(UIImage(data: data), error)
            } else {
                completionHandler?(nil, error)
            }
        }
       
    }
    
    func clearRequestCache() {
        URLCache.shared.removeAllCachedResponses() // clear cache
    }
    
    func getDataFromUrl(urlString: String, completionHandler: ((Data?, Error?, Bool) -> Void)?) {
        
        // set up URLRequest with URL
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            let error = BackendError.urlError(reason: "Could not construct URL")
            completionHandler?(nil, error, false)
            return
        }
        // run when finish fetching result
        let finished = {
            (bbCSportNews: Data?, error: Error?, isCached: Bool) in
            if !Thread.isMainThread {
                DispatchQueue.main.async {
                    completionHandler?(bbCSportNews, error, isCached)
                }
            } else {
                completionHandler?(bbCSportNews, error, isCached)
            }
            
        }
        // Make request
        let session = URLSession.shared
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: Manager4Network.NW_TIMEOUT)
        // Check if response is aldready in cache
        if let cacheResponse = URLCache.shared.cachedResponse(for: request)  {
            finished(cacheResponse.data, nil, true)
            return
        }
        
//        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            // handle response to request
            // check for error
            guard error == nil else {
                finished(nil, error!, false)
                return
            }
            // make sure we got data in the response
            guard let responseData = data else {
                print("Error: did not receive data")
                let error = BackendError.objectSerialization(reason: "No data in response")
                finished(nil, error, false)
                return
            }
            finished(responseData, nil, false)
        })
        task.resume()
    }
}
