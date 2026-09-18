//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Represents empty custom data.
public struct EmptyCustomData: Equatable, Codable {
    // Insert a dummy variable. Empty codable objects are otherwise not serialized when used with SwiftData, leading to crashes when restoring supposedly
    // non-nil objects from storage.
    private var _reserved = ""
}
