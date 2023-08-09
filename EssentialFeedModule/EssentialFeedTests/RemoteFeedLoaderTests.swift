//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 09/08/23.
//

import XCTest
@testable import EssentialFeedModule ///makes the internal types visible to the test target

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
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestDatafromURL() {
        ///Given
        let url = URL(string: "https://a-url.com")!
        let (sut , client) = makeSUTandClientHTTP(url: url)
        
        ///When
        sut.load()
        
        ///Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDatafromURL() {
        ///Given
        let url = URL(string: "https://a-url.com")!
        let (sut , client) = makeSUTandClientHTTP(url: url)
        
        ///When
        sut.load()
        sut.load()
        
        ///Then
        XCTAssertEqual(client.requestedURLs, [url, url])
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
        var requestedURLs = [URL]()
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }

}
