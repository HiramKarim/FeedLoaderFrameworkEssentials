//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 18/11/23.
//

import XCTest
import EssentialFeedModule

final class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    private typealias timestampblock = () -> Date
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping timestampblock = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line)
    -> (sut: LocalFeedLoader,
        store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }

    
}
