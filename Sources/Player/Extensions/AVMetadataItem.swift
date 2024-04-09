//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

public extension AVMetadataItem {
    static let defaultPreferredLanguages = Array(Locale.preferredLanguages.prefix(1) + ["und"])

    /// Creates a metadata item.
    ///
    /// - Parameters:
    ///   - identifier: The identifier for the metadata item.
    ///   - value: The value for the metadata item.
    /// - Returns: A new metadata item.
    convenience init?<T>(for id: AVMetadataIdentifier, value: T?, extendedLanguageTag: String = "und") {
        guard let value else { return nil }
        let item = AVMutableMetadataItem()
        item.value = value as? NSCopying & NSObjectProtocol
        guard let value = item.value else { return nil }
        item.identifier = id
        item.extendedLanguageTag = extendedLanguageTag
        self.init(propertiesOf: item) { $0.respond(value: value) }
    }
}
