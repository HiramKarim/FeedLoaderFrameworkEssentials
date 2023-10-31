//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 24/10/23.
//

import XCTest
import EssentialFeedModule

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private var deletionCompletions = [DeletionCompletion]()
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], _ timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class LocalFeedLoader {
    typealias currentDateblock = () -> Date
    private let store: FeedStore
    private let currentDate: currentDateblock
    
    init(store: FeedStore,
         currentDate: @escaping currentDateblock) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.store.insert(items, self.currentDate())
            }
        }
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    private typealias timestampblock = () -> Date
    
    func test_init_doesNotMessageStoreUponCreation(file: StaticString = #file, line: UInt = #line) {
        let (_, store) = makeSUT()
        trackForMemoryLeaks(store, file: file, line: line)
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion(file: StaticString = #file, line: UInt = #line) {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping timestampblock = Date.init,
                         file: StaticString = #file,
                         line: UInt = #line)
    -> (sut: LocalFeedLoader,
        store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
