//
//  BBCSportNews.swift
//  BBSportNews
//
//  Created by dat on 10/24/17.
//  Copyright © 2017 dat. All rights reserved.
//

import Foundation

struct BBCSportNews: Codable {
    var status: String?
    var source: String?
    var articles: [Article]?
}
