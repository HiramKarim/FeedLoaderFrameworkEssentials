//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 17/08/23.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy() ///Mock
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://any-url.com")!
        let session = URLSessionSpy() ///Mock
        let task = URLSessionDataTaskSpy() ///Mock
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
}

//MARK: - HELPERS
private class URLSessionSpy: URLSession {
    var receivedURLs = [URL]()
    private var stubs = [URL: URLSessionDataTask]()
    
    func stub(url: URL, task: URLSessionDataTask) {
        stubs[url] = task
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        receivedURLs.append(url)
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
