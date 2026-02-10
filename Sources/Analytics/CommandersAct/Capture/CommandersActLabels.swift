//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// The labels associated with a Commanders Act hit.
///
/// Mainly used for development-oriented purposes (e.g., unit testing).
public struct CommandersActLabels: Decodable {
    private let _media_airplay_on: String?
    private let _media_audiodescription_on: String?
    private let _media_position: String?
    private let _media_subtitles_on: String?
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

    /// The value of `consent_services`.
    public let consent_services: String?

    /// The Commanders Act contextual information.
    public let context: CommandersActContext

    /// The Commanders Act user information.
    public let user: CommandersActUser

    // MARK: Page view labels

    /// The value of `navigation_property_type`.
    public let navigation_property_type: String?

    /// The value of `content_bu_owner`.
    public let content_bu_owner: String?

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

    /// The value of `page_name`.
    public let page_name: String?

    // MARK: Streaming labels

    /// The value of `media_airplay_on`.
    public var media_airplay_on: Bool? {
        // swiftlint:disable:previous discouraged_optional_boolean
        extract(\._media_airplay_on)
    }

    /// The value of `media_audio_track`.
    public var media_audio_track: String?

    /// The value of `media_audiodescription_on`.
    public var media_audiodescription_on: Bool? {
        // swiftlint:disable:previous discouraged_optional_boolean
        extract(\._media_audiodescription_on)
    }

    /// The value of `media_player_display`.
    public let media_player_display: String?

    /// The value of `media_player_version`.
    public let media_player_version: String?

    /// The value of `media_position`.
    public var media_position: Int? {
        extract(\._media_position)
    }

    /// The value of `media_subtitles_on`.
    public var media_subtitles_on: Bool? {
        // swiftlint:disable:previous discouraged_optional_boolean
        extract(\._media_subtitles_on)
    }

    /// The value of `media_subtitle_selection`.
    public var media_subtitle_selection: String?

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
        case _media_airplay_on = "media_airplay_on"
        case _media_audiodescription_on = "media_audiodescription_on"
        case _media_position = "media_position"
        case _media_subtitles_on = "media_subtitles_on"
        case _media_timeshift = "media_timeshift"
        case _media_volume = "media_volume"
        case context
        case event_name
        case listener_session_id
        case media_title
        case app_library_version
        case navigation_app_site_name
        case navigation_device
        case consent_services
        case navigation_property_type
        case content_bu_owner
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
        case page_name
        case media_audio_track
        case media_player_display
        case media_player_version
        case media_subtitle_selection
        case user
    }
}
