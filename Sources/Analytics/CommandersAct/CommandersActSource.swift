//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A struct describing the source of an event sent to Commanders Act.
public struct CommandersActSource {
    let labels: [String: String]

    /// Creates Commanders Act source information.
    /// 
    /// - Parameters:
    ///   - page: Page information.
    ///   - section: Section information.
    ///   - source: The source of the event.
    ///   - labels: Additional information associated with the source.
    public init(page: CommandersActLocation, section: CommandersActLocation? = nil, labels: [String: String] = [:]) {
        self.labels = labels.merging([
            "page_id": page.identifier,
            "page_version": page.version,
            "section_position_in_page": page.position,
            "section_id": section?.identifier,
            "section_version": section?.version,
            "item_position_in_section": section?.position
        ].compactMapValues(\.self)) { _, new in new }
    }
}
