//
//  FeedCachePolicy.swift
//  EssentialFeedModule
//
//  Created by Hiram Castro on 21/11/23.
//

import Foundation

public final class FeedCachePolicy {
    
    private let currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar.current
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp)
        else {
            return false
        }
        return currentDate() < maxCacheAge
    }
    
}
