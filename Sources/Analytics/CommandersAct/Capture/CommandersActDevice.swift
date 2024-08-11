//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// The device labels associated with a Commanders Act hit.
///
/// Mainly used for development-oriented purposes (e.g. unit testing).
public struct CommandersActDevice: Decodable {
    /// The SDK identifier.
    public let sdk_id: String
}

extension CommandersActDevice {
    enum CodingKeys: String, CodingKey {
        case sdk_id
    }
}
