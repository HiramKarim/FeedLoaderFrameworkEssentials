//
//  RemoteFeedLoader.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 09/08/23.
//

import Foundation

///this interface can be implemented by external modules
///The 'public' access control makes visible for external modules

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error) -> Void = { _ in }) {
        self.client.get(from: self.url) { error in
            completion(.connectivity)
        }
    }
}
