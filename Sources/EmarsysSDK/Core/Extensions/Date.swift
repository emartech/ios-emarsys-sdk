//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

extension Date {
    
    static var utcFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar.init(identifier: .gregorian)
        return formatter
    }()
    
    func toUTC() -> String {
        return Date.utcFormatter.string(from: self)
    }
    
}
