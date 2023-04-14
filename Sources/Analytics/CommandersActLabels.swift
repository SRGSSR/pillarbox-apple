//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Labels associated with a Commanders Act event.
public struct CommandersActLabels: Decodable {
    let dictionary: [String: String]

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
}
