//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 09/08/23.
//

import XCTest
@testable import EssentialFeedModule ///makes the internal types visible to the test target

final class RemoteFeedLoaderTests: XCTestCase {
    
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
        let clientError = NSError(domain: "Test", code: 0)
        
        ///When
        expect(sut, toCompleteWithResult: failure(RemoteFeedLoader.Error.invalidData)) {
            ///Then
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUTandClientHTTP()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, statusCode in
            expect(sut, toCompleteWithResult: failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(with: statusCode, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponsewithInvalidJSON() {
        let (sut, client) = makeSUTandClientHTTP()
        
        expect(sut, toCompleteWithResult: failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(with: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUTandClientHTTP()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(with: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUTandClientHTTP()
        
        let item1 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "htt://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "htt://a-url.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(with: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPCLientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResult = [RemoteFeedLoader.Result]()
        sut?.load { errors in
            capturedResult.append(errors)
        }
        
        sut = nil
        client.complete(with: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    //MARK: - HELPERS
    private func makeSUTandClientHTTP(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader,
        client: HTTPCLientSpy) {
        let client = HTTPCLientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithResult expectedResult: RemoteFeedLoader.Result,
                        when actionCallback: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        actionCallback()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)
        
        let itemJSON = [
            "id": item.id.uuidString,
            "description":item.description,
            "location":item.location,
            "image": item.imageURL?.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        
        return (item, itemJSON)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    //MARK: - SPY
    
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
        
        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }

}
