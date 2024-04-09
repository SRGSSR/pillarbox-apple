//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

public extension AVMetadataItem {
    typealias Value = any NSCopying & NSObjectProtocol

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

    static func extract(
        items: [AVMetadataItem],
        filteredByIdentifiers identifiers: [AVMetadataIdentifier],
        bestMatchingPreferredLanguages preferredLanguages: [String] = defaultPreferredLanguages
    ) -> AnyPublisher<[AVMetadataIdentifier: Value], Never> {
        let filteredItems = AVMetadataItem.metadataItems(
            from: AVMetadataItem.metadataItems(from: items, filteredByIdentifiers: identifiers),
            filteredAndSortedAccordingToPreferredLanguages: preferredLanguages
        )
        return Publishers.MergeMany(filteredItems.map { item in
            item.propertyPublisher(.value)
                .replaceError(with: nil)
                .compactMap { value -> (key: AVMetadataIdentifier, value: Value)? in
                    guard let value, let identifier = item.identifier else {
                        return nil
                    }
                    return (key: identifier, value: value)
                }
        })
        .scan([AVMetadataIdentifier: Value]()) { initial, next in
            var updated = initial
            updated[next.key] = next.value
            return updated
        }
        .eraseToAnyPublisher()
    }
}
