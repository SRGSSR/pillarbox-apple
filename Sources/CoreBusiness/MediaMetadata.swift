//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import UIKit

public struct MediaMetadata {
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    public let mediaComposition: MediaComposition
    public let resource: Resource
    public let image: UIImage?

    public var title: String? {
        let mainChapter = mediaComposition.mainChapter
        guard mainChapter.contentType != .livestream else { return mainChapter.title }
        if let show = mediaComposition.show, Self.areRedundant(chapter: mainChapter, show: show) {
            return Self.dateFormatter.string(from: mainChapter.date)
        }
        else {
            return mainChapter.title
        }
    }

    public var subtitle: String? {
        guard mediaComposition.mainChapter.contentType != .livestream else { return nil }
        return mediaComposition.show?.title
    }

    public var description: String? {
        mediaComposition.mainChapter.description
    }

    var analyticsData: [String: String] {
        var analyticsData = mediaComposition.analyticsData
        analyticsData.merge(mediaComposition.mainChapter.analyticsData) { _, new in new }
        analyticsData.merge(resource.analyticsData) { _, new in new }
        return analyticsData
    }

    var analyticsMetadata: [String: String] {
        var analyticsMetadata = mediaComposition.analyticsMetadata
        analyticsMetadata.merge(mediaComposition.mainChapter.analyticsMetadata) { _, new in new }
        analyticsMetadata.merge(resource.analyticsMetadata) { _, new in new }
        return analyticsMetadata
    }

    init(mediaComposition: MediaComposition, resource: Resource, image: UIImage?) {
        self.mediaComposition = mediaComposition
        self.resource = resource
        self.image = image
    }

    private static func areRedundant(chapter: Chapter, show: Show) -> Bool {
        chapter.title.lowercased() == show.title.lowercased()
    }
}
