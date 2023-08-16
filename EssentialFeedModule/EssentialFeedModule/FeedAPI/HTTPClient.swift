//
//  HTTPClient.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 16/08/23.
//

import Foundation

///this interface can be implemented by external modules
///The 'public' access control makes visible for external modules

public enum HTTPCLientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPCLientResult) -> Void)
}
