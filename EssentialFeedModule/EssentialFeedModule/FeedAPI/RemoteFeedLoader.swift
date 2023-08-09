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
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        self.client.get(from: self.url)
    }
}
