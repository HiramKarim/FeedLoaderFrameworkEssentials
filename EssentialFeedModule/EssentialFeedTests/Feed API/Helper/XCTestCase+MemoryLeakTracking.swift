//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 24/08/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
        addTeardownBlock {
            XCTAssertNil(instance, "Instance should have been deadllocated. Potential memory leak.", file: file, line: line)
        }
    }
}
