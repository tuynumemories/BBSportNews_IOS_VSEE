//
//  BBSportNewsTests.swift
//  BBSportNewsTests
//
//  Created by dat on 10/23/17.
//  Copyright © 2017 dat. All rights reserved.
//

import XCTest
@testable import BBSportNews

class BBSportNewsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testArticlesCache() {
        Manager4Network.shared.clearRequestCache()
        let expect = expectation(description: "get all articles request")
        Manager4Network.shared.getArticlesListFromSV { (bbcNews, error, _) in
            XCTAssertNotNil(bbcNews, "Fail to get articles from sv")
            expect.fulfill()
            // get articles from cache
            Manager4Network.shared.getArticlesListFromSV(completionHandler: { (bbcNews2, error, _) in
                XCTAssertNotNil(bbcNews, "Fail to get articles from Cache sv")
            })
        }
        waitForExpectations(timeout: Manager4Network.NW_TIMEOUT + 2.0, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
