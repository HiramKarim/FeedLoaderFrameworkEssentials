//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 05/12/23.
//

import XCTest
import EssentialFeedModule

class CodableFeedStore {
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
    
}

final class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                
                break
            case let .failure(error):
                
                break
            case let .found(feed: localFeed, timestamp: timestamp):
                
                break
            }
            exp.fulfill()
        }
        
        wait(for: [exp])
    }
    
}
