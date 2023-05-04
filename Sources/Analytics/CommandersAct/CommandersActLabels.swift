//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Labels associated with a Commanders Act event.
public struct CommandersActLabels: Decodable {
    private var _media_position: String?
    private var _media_timeshift: String?

    var event_name: String?
    var listener_session_id: String?

    /// Value of `app_library_version`.
    public var app_library_version: String?

    /// Value of `navigation_app_site_name`.
    public var navigation_app_site_name: String?

    /// Value of `navigation_property_type`.
    public var navigation_property_type: String?

    /// Value of `navigation_bu_distributer`.
    public var navigation_bu_distributer: String?

    /// Value of `navigation_device`.
    public var navigation_device: String?

    /// Value of `navigation_level_0`.
    public var navigation_level_0: String?

    /// Value of `navigation_level_1`.
    public var navigation_level_1: String?

    /// Value of `navigation_level_2`.
    public var navigation_level_2: String?

    /// Value of `navigation_level_3`.
    public var navigation_level_3: String?

    /// Value of `navigation_level_4`.
    public var navigation_level_4: String?

    /// Value of `navigation_level_5`.
    public var navigation_level_5: String?

    /// Value of `navigation_level_6`.
    public var navigation_level_6: String?

    /// Value of `navigation_level_7`.
    public var navigation_level_7: String?

    /// Value of `navigation_level_8`.
    public var navigation_level_8: String?

    /// Value of `navigation_level_9`.
    public var navigation_level_9: String?

    /// Value of `page_type`.
    public var page_type: String?

    /// Value of `event_title`.
    /// FIXME: This field was introduced to avoid clashes with `event_name` but still needs to be discussed.
    public var event_title: String?

    /// Value of `event_type`.
    public var event_type: String?

    /// Value of `event_value`.
    public var event_value: String?

    /// Value of `event_source`.
    public var event_source: String?

    /// Value of `event_value_1`.
    public var event_value_1: String?

    /// Value of `event_value_2`.
    public var event_value_2: String?

    /// Value of `event_value_3`.
    public var event_value_3: String?

    /// Value of `event_value_4`.
    public var event_value_4: String?

    /// Value of `event_value_5`.
    public var event_value_5: String?

    /// Value of `media_player_display`.
    public var media_player_display: String?

    /// Value of `media_player_version`.
    public var media_player_version: String?

    /// Value of `media_volume`.
    public var media_volume: String?

    /// Value of `media_position`.
    public var media_position: Int? {
        guard let _media_position else { return nil }
        return Int(_media_position)
    }

    /// Value of `media_timeshift`.
    public var media_timeshift: Int? {
        guard let _media_timeshift else { return nil }
        return Int(_media_timeshift)
    }
}

private extension CommandersActLabels {
    enum CodingKeys: String, CodingKey {
        case event_name
        case listener_session_id
        case app_library_version
        case navigation_app_site_name
        case navigation_property_type
        case navigation_bu_distributer
        case navigation_device
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
        case event_title
        case event_type
        case event_value
        case event_source
        case event_value_1
        case event_value_2
        case event_value_3
        case event_value_4
        case event_value_5
        case media_player_display
        case media_player_version
        case media_volume
        case _media_position = "media_position"
        case _media_timeshift = "media_timeshift"
    }
}
