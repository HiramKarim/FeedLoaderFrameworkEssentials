//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 09/08/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    var requestedURL: URL?
    static var shared = HTTPClient()
    
    func get(from url: URL) { }
}

class HTTPCLientSpy: HTTPClient {
    override func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_init_doesNotRequestDataFromURL() {
        ///Given
        let client = HTTPCLientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        ///When
        
        ///Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDatafromURL() {
        ///Given
        let client = HTTPCLientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        ///When
        sut.load()
        
        ///Then
        XCTAssertNotNil(client.requestedURL)
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
