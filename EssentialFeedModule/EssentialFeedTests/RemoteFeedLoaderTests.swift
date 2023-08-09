//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 09/08/23.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        self.client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    var requestedURL: URL? { get set }
    func get(from url: URL)
}

class HTTPCLientSpy: HTTPClient {
    var requestedURL: URL?
    func get(from url: URL) {
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
        let sut = RemoteFeedLoader(client: client)
        
        ///When
        
        ///Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDatafromURL() {
        ///Given
        let client = HTTPCLientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        ///When
        sut.load()
        
        ///Then
        XCTAssertNotNil(client.requestedURL)
    }

}
