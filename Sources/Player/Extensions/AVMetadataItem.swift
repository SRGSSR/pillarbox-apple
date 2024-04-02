//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVMetadataItem {
    /// Creates a metadata item.
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the metadata item.
    ///   - value: The value for the metadata item.
    /// - Returns: A new metadata item.
    convenience init?<T>(for id: AVMetadataIdentifier, value: T?) {
        guard let value else { return nil }
        let item = AVMutableMetadataItem()
        item.value = value as? NSCopying & NSObjectProtocol
        guard let value = item.value else { return nil }
        item.identifier = id
        item.extendedLanguageTag = "und"
        self.init(propertiesOf: item) { $0.respond(value: value) }
    }
}
