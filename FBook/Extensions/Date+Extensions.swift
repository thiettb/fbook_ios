//
//  Date+Extensions.swift
//  FBook
//
//  Created by tran.xuan.diep on 9/15/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {

        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) seconds ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hours ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }

    func toServerString() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = kDateServerFormat
        return dateFormat.string(from: self)
    }
    
    func toSeverStringkDateFormatYMD() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = kDateFormatYMD
        return dateFormat.string(from: self)
    }
}
