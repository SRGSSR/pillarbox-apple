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

    private static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private static let minuteFormatter = {
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
        let description = "\(date(for: media)) | \(duration(for: media))"
        if let show = media.show {
            return "\(icon(for: media)) | \(show.title) | \(description)"
        }
        else {
            return "\(icon(for: media)) | \(description)"
        }
    }

    static func duration(for media: SRGMedia) -> String {
        minuteFormatter.string(from: max(media.duration / 1000, 60))!
    }

    static func systemImage(for media: SRGMedia) -> String? {
        guard media.mediaType != .none else { return nil }
        return media.mediaType == .audio ? "headphones" : "movieclapper.fill"
    }

    static func style(for media: SRGMedia) -> Style {
        media.timeAvailability(at: .now) == .available ? .standard : .disabled
    }

    static func date(for media: SRGMedia) -> String {
        dateFormatter.string(from: media.date)
    }

    private static func icon(for media: SRGMedia) -> String {
        media.mediaType == .audio ? "🎧" : "🎬"
    }
}
