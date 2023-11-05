//
//  FeedStore.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 02/11/23.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func insert(_ items: [LocalFeedItem], _ timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}
