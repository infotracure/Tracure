//
//  DateUtils.swift
//  Runner
//
//  Created by ABHI on 23/06/25.
//

import Foundation

class DateUtils {
    static func parseISO8601DateTrimmingMicroseconds(from dateString: String) -> Date? {
        // Trim microseconds to milliseconds for compatibility
        let cleanDateString: String
        if let dotRange = dateString.range(of: "."),
           let zRange = dateString.range(of: "Z") {
            let fractionalPart = dateString[dotRange.upperBound..<zRange.lowerBound]
            let trimmedFraction = String(fractionalPart.prefix(3)) // First 3 digits only
            cleanDateString = dateString.replacingCharacters(in: dotRange.upperBound..<zRange.lowerBound, with: trimmedFraction)
        } else {
            cleanDateString = dateString
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: cleanDateString)
    }
}
