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
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    static func title(for media: SRGMedia) -> String {
        media.title
    }

    static func subtitle(for media: SRGMedia) -> String {
        let icon = media.mediaType == .audio ? "🎧" : "🎬"
        let description = "\(dateFormatter.string(from: media.date)) \(icon)"
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
}
