//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 18/11/23.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
