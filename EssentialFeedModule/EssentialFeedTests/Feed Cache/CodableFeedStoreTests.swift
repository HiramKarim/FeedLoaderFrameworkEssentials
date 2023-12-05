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
            case .empty:break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp])
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache_twice() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty): break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp])
    }
    
}
