//
//  FeedItem.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 09/08/23.
//

import Foundation

public struct FeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL?
    
    public init(id: UUID, description: String?, location: String?, url: URL?) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}

extension FeedImage: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case url = "image"
    }
}
