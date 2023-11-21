//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel

enum MediaDescription {
    enum Style {
        case standard
        case disabled
    }

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private static var minuteFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = .minute
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    static func title(for media: SRGMedia) -> String {
        media.title
    }

    static func subtitle(for media: SRGMedia) -> String {
        let description = "\(date(for: media)) - \(duration(for: media)) \(icon(for: media))"
        if let show = media.show {
            return "\(show.title) - \(description)"
        }
        else {
            return description
        }
    }

    static func style(for media: SRGMedia) -> Style {
        media.timeAvailability(at: Date()) == .available ? .standard : .disabled
    }

    private static func date(for media: SRGMedia) -> String {
        dateFormatter.string(from: media.date)
    }

    private static func duration(for media: SRGMedia) -> String {
        minuteFormatter.string(from: max(media.duration / 1000, 60))!
    }

    private static func icon(for media: SRGMedia) -> String {
        media.mediaType == .audio ? "🎧" : "🎬"
    }
}
