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

struct Article: Codable {
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
}

struct BBCSportNews: Codable {
    var status: String?
    var source: String?
    var articles: [Article]?
}

class Manager4Network{
    public static let shared = Manager4Network()
    
    func getArticlesListFromSV(completionHandler: ((BBCSportNews?, Error?) -> Void)?) {
        getDataFromUrl(
            urlString: "https://newsapi.org/v1/articles?source=bbc-sport&sortBy=top&apiKey=a720b6e614e14f8ca47f0441f5972e76",
            completionHandler: {
            (data, error) in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let todo = try decoder.decode(BBCSportNews.self, from: data)
                    completionHandler?(todo, nil)
                } catch {
                    print("error trying to convert data to JSON : \(error)")
                    completionHandler?(nil, error)
                }
            } else {
                completionHandler?(nil, error)
            }
        }
        )
    }
    
    func getImageFromUrl(urlString: String, completionHandler: ((UIImage?, Error?) -> Void)?) {
        getDataFromUrl(urlString: urlString) { (data, error) in
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
    
    func getDataFromUrl(urlString: String, completionHandler: ((Data?, Error?) -> Void)?) {
        
        // set up URLRequest with URL
        guard let url = URL(string: urlString) else {
            print("Error: cannot create URL")
            let error = BackendError.urlError(reason: "Could not construct URL")
            completionHandler?(nil, error)
            return
        }
        // run when finish fetching result
        let finished = {
            (bbCSportNews: Data?, error: Error?) in
            DispatchQueue.main.async {
                completionHandler?(bbCSportNews, error)
            }
        }
        // Make request
        let session = URLSession.shared
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        if let cacheResponse = URLCache.shared.cachedResponse(for: request)  {
            finished(cacheResponse.data, nil)
            return
        }
        
//        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            // handle response to request
            // check for error
            guard error == nil else {
                finished(nil, error!)
                return
            }
            // make sure we got data in the response
            guard let responseData = data else {
                print("Error: did not receive data")
                let error = BackendError.objectSerialization(reason: "No data in response")
                finished(nil, error)
                return
            }
            finished(responseData, nil)
        })
        task.resume()
    }
}
