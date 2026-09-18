//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxAnalytics
import PillarboxMonitoring
import PillarboxPlayer

public extension PlayerItem {
    /// Creates a player item from a URN.
    ///
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - server: The server which the URN is played from.
    ///   - httpHeaders: HTTP headers to set when requesting the content.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///   - commandersActSource: The source of events sent to Commanders Act.
    ///
    /// Metadata is automatically associated with the item. In addition to trackers you provide, tracking is performed
    /// according to SRG SSR analytics standards.
    static func urn(
        _ urn: String,
        server: Server = .production,
        httpHeaders: [String: String] = [:],
        trackerAdapters: [TrackerAdapter<MediaMetadata>] = [],
        commandersActSource: CommandersActSource? = nil
    ) -> Self {
        self.init(
            assetLoaderType: URNAssetLoader.self,
            input: .init(urn: urn, server: server, httpHeaders: httpHeaders),
            trackerAdapters: [
                ComScoreTracker.adapter { $0.analyticsData },
                CommandersActTracker.adapter(configuration: commandersActSource) { $0.analyticsMetadata },
                MetricsTracker.adapter(
                    configuration: .init(
                        identifier: urn,
                        serviceUrl: URL(string: "https://monitoring.pillarbox.ch/api/events")!
                    ),
                    behavior: .mandatory
                ) { metadata in
                    MetricsTracker.Metadata(
                        metadataUrl: metadata.mediaCompositionUrl,
                        metadataHeaders: metadata.mediaCompositionHeaders,
                        assetUrl: metadata.resource?.url
                    )
                }
            ] + trackerAdapters
        )
    }
}
