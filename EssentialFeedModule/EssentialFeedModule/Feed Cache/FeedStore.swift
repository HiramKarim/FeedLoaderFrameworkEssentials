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

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL?
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL?) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
