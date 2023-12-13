//
//  CodableFeedStore.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 11/12/23.
//
//  Side Notes:
//  Global Queue is concurrent. This means, threads run depending of procesor resources availability

import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [DTOCodableLocalFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    private struct DTOCodableLocalFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL?
        
        init(_ local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: self.id,
                                  description: self.description,
                                  location: self.location,
                                  url: self.url)
        }
    }
    
    private let storeURL: URL
    /// Background queue - This operation run serially
    /// This operation uses the shared serial background queue,we are not blocking clients or user interations, still doing the work serially
    private let  queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage],
                _ timestamp: Date,
                completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(DTOCodableLocalFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch let error {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard FileManager.default.fileExists(atPath: storeURL.path()) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch let error {
                completion(error)
            }
        }
    }
}
