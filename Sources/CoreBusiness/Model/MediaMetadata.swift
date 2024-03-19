//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

/// Metadata associated with content loaded from a URN.
public struct MediaMetadata {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    /// The playback context.
    public let mediaComposition: MediaComposition

    /// The resource to be played.
    public let resource: Resource

    /// An associated image suitable for artwork display.
    public let image: UIImage?

    /// The title recommended for display.
    public var title: String {
        let mainChapter = mediaComposition.mainChapter
        guard mainChapter.contentType != .livestream else { return mainChapter.title }
        if let show = mediaComposition.show, Self.areRedundant(chapter: mainChapter, show: show) {
            return Self.dateFormatter.string(from: mainChapter.date)
        }
        else {
            return mainChapter.title
        }
    }

    /// The subtitle recommended for display.
    public var subtitle: String? {
        guard mediaComposition.mainChapter.contentType != .livestream else { return nil }
        return mediaComposition.show?.title
    }

    /// The content description.
    public var description: String? {
        mediaComposition.mainChapter.description
    }

    /// The stream type.
    public var streamType: StreamType {
        resource.streamType
    }

    /// The consolidated comScore analytics data.
    var analyticsData: [String: String] {
        var analyticsData = mediaComposition.mainChapter.analyticsData
        guard !analyticsData.isEmpty else { return [:] }
        analyticsData.merge(mediaComposition.analyticsData) { _, new in new }
        analyticsData.merge(resource.analyticsData) { _, new in new }
        return analyticsData
    }

    /// The consolidated Commanders Act analytics data.
    var analyticsMetadata: [String: String] {
        var analyticsMetadata = mediaComposition.mainChapter.analyticsMetadata
        guard !analyticsMetadata.isEmpty else { return [:] }
        analyticsMetadata.merge(mediaComposition.analyticsMetadata) { _, new in new }
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
