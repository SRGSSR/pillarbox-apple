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
        case ns_st_ldw(Int?)
        case ns_st_po(Int?)

        init?(key: String, value: String) {
            switch key {
            case "ns_st_id":
                self = .ns_st_id(value)
            case "ns_st_ldw":
                self = .ns_st_ldw(Int(value))
            case "ns_st_po":
                self = .ns_st_po(Int(value))
            default:
                return nil
            }
        }
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
    public static func play(_ fields: Field...) -> Self {
        .init(kind: .play, fields: fields)
    }

    /// Pause.
    public static func pause(_ fields: Field...) -> Self {
        .init(kind: .pause, fields: fields)
    }

    /// End.
    public static func end(_ fields: Field...) -> Self {
        .init(kind: .end, fields: fields)
    }
}

extension ComScoreEvent {
    init?(from dictionary: [String: String]) {
        guard let event = dictionary["ns_st_ev"], let kind = Kind(rawValue: event) else { return nil }
        let fields = dictionary.compactMap { Field(key: $0, value: $1) }
        self.init(kind: kind, fields: fields)
    }

    static func isSubset(receivedEvent: ComScoreEvent, expectedEvent: ComScoreEvent) -> Bool {
        receivedEvent.kind == expectedEvent.kind && Set(expectedEvent.fields).isSubset(of: receivedEvent.fields)
    }
}
