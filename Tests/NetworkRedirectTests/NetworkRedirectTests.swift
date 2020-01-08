//
//  NetworkRedirectTests.swift
//  NetworkRedirectTests
//
//  Created by Sergey Krasiuk on 08/01/2020.
//  Copyright © 2020 Sergey Krasiuk. All rights reserved.
//

import XCTest
@testable import NetworkRedirect

class NetworkRedirectTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDefaultMaximumRedirects() {
        
        XCTAssertTrue(NetworkRedirect.shared.maxNumberOfRedirections == 3)
    }

    func testLimithRedirections() {

        let expectation = self.expectation(description: "out of max number of redirects")
        var responseError: Error?
        let testURL = URL(string: "http://www.mocky.io/v2/5e0af46b3300007e1120a7ef")!

        NetworkRedirect.shared.maxNumberOfRedirections = 2
        NetworkRedirect.shared.request(withURL: testURL) { (result) in

            DispatchQueue.main.async {
                switch result {
                    case .failure(let error):
                        responseError = error

                default: break
                }

                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(responseError)
        XCTAssertEqual(responseError!.localizedDescription, "Too many HTTP redirects")
    }
    
    func testRequestDataWithRedirections() {
        
        let expectation = self.expectation(description: "get data after several redirects")
        var responseText: String?
        let testURL = URL(string: "http://www.mocky.io/v2/5e15b85f3400005200406787")!
        
        NetworkRedirect.shared.maxNumberOfRedirections = 3
        NetworkRedirect.shared.request(withURL: testURL) { (result) in
            
            DispatchQueue.main.async {
                switch result {
                    case .success(let text):
                        responseText = text
                        
                default: break
                }
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(responseText, "world")
        XCTAssertNotNil(responseText)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
