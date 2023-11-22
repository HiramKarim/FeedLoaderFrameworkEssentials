//
//  FeedCachePolicy.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 21/11/23.
//

import Foundation

public final class FeedCachePolicy {

    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    func validate(_ timestamp: Date, againt date: Date) -> Bool {
        let calendar = Calendar.current
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp)
        else {
            return false
        }
        return date < maxCacheAge
    }
    
}
