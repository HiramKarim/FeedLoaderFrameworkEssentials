//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 09/08/23.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        self.client.get(from: self.url)
    }
}

protocol HTTPClient {
    var requestedURL: URL? { get set }
    func get(from url: URL)
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
        let (_ , client) = makeSUTandClientHTTP()
        
        ///When
        
        ///Then
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDatafromURL() {
        ///Given
        let url = URL(string: "https://a-url.com")!
        let (sut , client) = makeSUTandClientHTTP(url: url)
        
        ///When
        sut.load()
        
        ///Then
        XCTAssertNotNil(client.requestedURL)
    }
    
    //MARK: - HELPERS
    private func makeSUTandClientHTTP(
        url: URL = URL(string: "https://a-url.com")!
    ) -> (sut: RemoteFeedLoader,
        client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPCLientSpy: HTTPClient {
        var requestedURL: URL?
        func get(from url: URL) {
            requestedURL = url
        }
    }

}
