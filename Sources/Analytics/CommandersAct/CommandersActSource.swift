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
    ///   - labels: Additional information associated with the source.
    public init(page: CommandersActPage, section: CommandersActSection?, labels: [String: String] = [:]) {
        self.labels = labels
    }
}
