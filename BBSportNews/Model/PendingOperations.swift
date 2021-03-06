//
//  PendingOperations.swift
//  BBSportNews
//
//  Created by dat on 10/24/17.
//  Copyright © 2017 dat. All rights reserved.
//

import Foundation

class PendingOperations {
    //    lazy var sendRequestInProgress = [IndexPath:Operation]()
    lazy var sendRequestCacheQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "sendRequestCacheQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    //    lazy var sendRequestInProgress = [IndexPath:Operation]()
    lazy var sendImageRequestCacheQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "sendImageRequestCacheQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}
