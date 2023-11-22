//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Hiram Castro on 18/11/23.
//

import Foundation
import EssentialFeedModule

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueImage(), uniqueImage()]
    let localItems = items.map { feedItem in
        LocalFeedImage(id: feedItem.id,
                      description: feedItem.description,
                      location: feedItem.location,
                      url: feedItem.url)
    }
    return (items, localItems)
}

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -7)
    }

    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
