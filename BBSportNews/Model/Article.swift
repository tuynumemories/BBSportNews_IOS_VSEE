//
//  Article.swift
//  BBSportNews
//
//  Created by dat on 10/24/17.
//  Copyright © 2017 dat. All rights reserved.
//

import Foundation

struct Article: Codable {
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    
    func getNiceFormOfPublishedAt() -> String {
        guard let publishedAt = publishedAt else {
            return ""
        }
        var newPublishedAt = publishedAt.replacingOccurrences(of: "T", with: " ", options: .literal, range: nil)
        newPublishedAt = newPublishedAt.replacingOccurrences(of: "Z", with: " ", options: .literal, range: nil)
        return newPublishedAt
    }
}
