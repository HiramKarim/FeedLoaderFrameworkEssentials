//
//  LocalFeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 02/11/23.
//

import Foundation

public final class LocalFeedLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore,
                currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar.current
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp)
        else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}


extension LocalFeedLoader {
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toModel()))
            case .found, .empty:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found(_ , timestamp) where !self.validate(timestamp):
                self.store.deleteCachedFeed { _ in }
            case .empty, .found: break
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { feedItem in
            LocalFeedImage(id: feedItem.id,
                          description: feedItem.description,
                          location: feedItem.location,
                          url: feedItem.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        return map { feedItem in
            FeedImage(id: feedItem.id,
                      description: feedItem.description,
                      location: feedItem.location,
                      url: feedItem.url)
        }
    }
}
