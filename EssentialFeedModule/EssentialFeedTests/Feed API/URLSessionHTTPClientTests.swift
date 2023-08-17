//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 17/08/23.
//

import Foundation
import XCTest
import EssentialFeedModule

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPCLientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy() ///Mock
        let task = URLSessionDataTaskSpy() ///Mock
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy() ///Mock
        let task = URLSessionDataTaskSpy() ///Mock
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp])
    }
    
}

//MARK: - HELPERS
private class URLSessionSpy: URLSession {
    private var stubs = [URL: URLSessionDataTask]()
    
    func stub(url: URL, task: URLSessionDataTask) {
        stubs[url] = task
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return stubs[url] ?? FakeURLSessionDataTask()
    }
}

class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {
        
    }
}

class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount = 0
    
    override func resume() {
        resumeCallCount += 1
    }
}
