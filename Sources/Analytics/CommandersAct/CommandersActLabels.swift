//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// The labels associated with a Commanders Act hit.
///
/// Mainly used for development-oriented purposes (e.g. unit testing).
public struct CommandersActLabels: Decodable {
    private let _media_position: String?
    private let _media_timeshift: String?
    private let _media_volume: String?

    let event_name: String?
    let listener_session_id: String?
    let media_title: String?

    // MARK: Common labels

    /// The value of `app_library_version`.
    public let app_library_version: String?

    /// The value of `navigation_app_site_name`.
    public let navigation_app_site_name: String?

    /// The value of `navigation_device`.
    public let navigation_device: String?

    // MARK: Page view labels

    /// The value of `navigation_property_type`.
    public let navigation_property_type: String?

    /// The value of `navigation_bu_distributer`.
    public let navigation_bu_distributer: String?

    /// The value of `navigation_level_0`.
    public let navigation_level_0: String?

    /// The value of `navigation_level_1`.
    public let navigation_level_1: String?

    /// The value of `navigation_level_2`.
    public let navigation_level_2: String?

    /// The value of `navigation_level_3`.
    public let navigation_level_3: String?

    /// The value of `navigation_level_4`.
    public let navigation_level_4: String?

    /// The value of `navigation_level_5`.
    public let navigation_level_5: String?

    /// The value of `navigation_level_6`.
    public let navigation_level_6: String?

    /// The value of `navigation_level_7`.
    public let navigation_level_7: String?

    /// The value of `navigation_level_8`.
    public let navigation_level_8: String?

    /// The value of `navigation_level_9`.
    public let navigation_level_9: String?

    /// The value of `page_type`.
    public let page_type: String?

    /// The value of `content_title`.
    public let content_title: String?

    // MARK: Streaming labels

    /// The value of `media_player_display`.
    public let media_player_display: String?

    /// The value of `media_player_version`.
    public let media_player_version: String?

    /// The value of `media_position`.
    public var media_position: Int? {
        extract(\._media_position)
    }

    /// The value of `media_timeshift`.
    public var media_timeshift: Int? {
        extract(\._media_timeshift)
    }

    /// The value of `media_volume`.
    public var media_volume: Int? {
        extract(\._media_volume)
    }

    private func extract<T>(_ keyPath: KeyPath<Self, String?>) -> T? where T: LosslessStringConvertible {
        guard let value = self[keyPath: keyPath] else { return nil }
        return .init(value)
    }
}

private extension CommandersActLabels {
    enum CodingKeys: String, CodingKey {
        case event_name
        case listener_session_id
        case media_title
        case app_library_version
        case navigation_app_site_name
        case navigation_device
        case navigation_property_type
        case navigation_bu_distributer
        case navigation_level_0
        case navigation_level_1
        case navigation_level_2
        case navigation_level_3
        case navigation_level_4
        case navigation_level_5
        case navigation_level_6
        case navigation_level_7
        case navigation_level_8
        case navigation_level_9
        case page_type
        case content_title
        case media_player_display
        case media_player_version
        case _media_position = "media_position"
        case _media_timeshift = "media_timeshift"
        case _media_volume = "media_volume"
    }
}
