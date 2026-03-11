//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxAnalytics
import PillarboxPlayer

/// A playback context.
public struct PlaybackContext {
    /// The default configuration.
    public static let `default` = Self()

    /// The playback configuration.
    public let configuration: PlaybackConfiguration

    /// The source of events sent to Commanders Act.
    public let commandersActSource: CommandersActSource?

    /// Creates a playback context.
    ///
    /// - Parameters:
    ///   - configuration: The playback configuration.
    ///   - commandersActSource: The source of events sent to Commanders Act.
    public init(configuration: PlaybackConfiguration = .default, commandersActSource: CommandersActSource? = nil) {
        self.configuration = configuration
        self.commandersActSource = commandersActSource
    }
}
