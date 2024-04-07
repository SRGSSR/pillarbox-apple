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

    /// Returns metadata items matching one of the specified identifiers.
    ///
    /// - Parameters:
    ///   - items: The items to filter.
    ///   - identifiers: The identifiers to filter items against.
    ///
    /// The initial item order is preserved.
    static func metadataItems(
        from items: [AVMetadataItem],
        filteredByIdentifiers identifiers: [AVMetadataIdentifier]
    ) -> [AVMetadataItem] {
        items.filter { item in
            guard let identifier = item.identifier else { return false }
            return identifiers.contains(identifier)
        }
    }
}
