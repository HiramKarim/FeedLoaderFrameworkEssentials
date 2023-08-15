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
        sut.load { _ in }
        
        ///Then
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDatafromURL() {
        ///Given
        let url = URL(string: "https://a-url.com")!
        let (sut , client) = makeSUTandClientHTTP(url: url)
        
        ///When
        sut.load { _ in }
        sut.load { _ in }
        
        ///Then
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientErrorError() {
        ///Given
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUTandClientHTTP(url: url)
        var capturedError = [RemoteFeedLoader.Error]()
        let clientError = NSError(domain: "Test", code: 0)
        
        ///When
        sut.load { error in
            capturedError.append(error)
        }
        
        client.complete(with: clientError)
        
        ///Then
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUTandClientHTTP()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, statusCode in
            
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load { capturedErrors.append($0) }
            client.complete(with: statusCode, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponsewithInvalidJSON() {
        let (sut, client) = makeSUTandClientHTTP()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { errors in
            capturedErrors.append(errors)
        }
        
        let invalidJSON = Data("invalid json".utf8)
        client.complete(with: 200, data: invalidJSON)
        
        XCTAssertEqual(capturedErrors, [.invalidData])
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
        private var messages = [(url: URL, completion: (HTTPCLientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPCLientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: NSError, at position:Int = 0) {
            messages[position].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }

}
