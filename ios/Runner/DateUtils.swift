//
//  DateUtils.swift
//  Runner
//
//  Created by ABHI on 23/06/25.
//

import Foundation

class DateUtils {

    static func parseISO8601DateTrimmingMicroseconds(from dateString: String) -> Date? {

        let cleanDateString: String
        if let dotRange = dateString.range(of: "."),
           let zRange = dateString.range(of: "Z") {
            let fractionalPart = dateString[dotRange.upperBound..<zRange.lowerBound]
            let trimmedFraction = String(fractionalPart.prefix(3))
            cleanDateString = dateString.replacingCharacters(
                in: dotRange.upperBound..<zRange.lowerBound,
                with: trimmedFraction
            )
        } else {
            cleanDateString = dateString
        }

        let formatter = ISO8601DateFormatter()

        // 1️⃣ Try full ISO-8601 datetime first
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: cleanDateString) {
            return date
        }

        // 2️⃣ Fallback: yyyy-MM-dd
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: cleanDateString)
    }
}
