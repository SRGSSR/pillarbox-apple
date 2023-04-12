//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A comScore event.
public struct ComScoreEvent: Equatable {
    /// The field related to the event.
    public enum Field: Hashable, Equatable {
        case ns_st_id(String)
        case ns_st_ldw(Int)
        case ns_st_po(Int)
    }

    /// The event kind.
    public enum Kind: String {
        case play
        case pause
        case end
    }

    let kind: Kind
    let fields: [Field]

    private init(kind: Kind, fields: [Field]) {
        self.kind = kind
        self.fields = fields
    }

    /// Play.
    public static func play(_ fields: [Field]) -> Self {
        .init(kind: .play, fields: fields)
    }

    /// Pause.
    public static func pause(_ fields: [Field]) -> Self {
        .init(kind: .pause, fields: fields)
    }

    /// End.
    public static func end(_ fields: [Field]) -> Self {
        .init(kind: .end, fields: fields)
    }
}

extension ComScoreEvent {
    init?(from dictionary: [String: String]) {
        guard let event = dictionary["ns_st_ev"], let kind = Kind(rawValue: event) else { return nil }
        self.init(kind: kind, fields: Self.fields(from: dictionary))
    }

    private static func fields(from dictionary: [String: String]) -> [Field] {
        [
            .ns_st_id(dictionary["ns_st_id"]!),
            .ns_st_ldw(Int(dictionary["ns_st_ldw"]!)!),
            .ns_st_po(Int(dictionary["ns_st_po"]!)!)
        ]
    }

    static func isSubset(receivedEvent: ComScoreEvent, expectedEvent: ComScoreEvent) -> Bool {
        receivedEvent.kind == expectedEvent.kind && Set(expectedEvent.fields).isSubset(of: receivedEvent.fields)
    }
}
