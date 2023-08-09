//
//  FeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 09/08/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error) 
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
