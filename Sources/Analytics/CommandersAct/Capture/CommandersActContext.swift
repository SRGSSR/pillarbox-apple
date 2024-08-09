//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// The context labels associated with a Commanders Act hit.
///
/// Mainly used for development-oriented purposes (e.g. unit testing).
public struct CommandersActContext: Decodable {
    /// The device information.
    public let device: CommandersActDevice
}

extension CommandersActContext {
    enum CodingKeys: String, CodingKey {
        case device
    }
}
