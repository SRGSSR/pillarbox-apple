//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DateFormat {
    case standard
    case relative
}

private let kDateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

private let kRelativeDateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter
}()

func DateFormatter(format: DateFormat) -> DateFormatter {
    switch format {
    case .standard:
        kDateFormatter
    case .relative:
        kRelativeDateFormatter
    }
}
