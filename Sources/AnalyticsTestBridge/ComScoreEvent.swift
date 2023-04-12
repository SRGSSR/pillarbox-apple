//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Labels associated with a ComScore event.
public struct ComScoreLabels {
    let dictionary: [String: String]

    /// Value of `ns_st_po`.
    public var ns_st_po: Int? {
        extract(key: "ns_st_po") { Int($0) }
    }

    /// Value of `ns_st_ldw`.
    public var ns_st_ldw: Int? {
        extract(key: "ns_st_ldw") { Int($0) }
    }

    func extract<T>(key: String, conversion: (String) -> T?) -> T? {
        guard let value = dictionary[key] else { return nil }
        return conversion(value)
    }
}

/// A comScore event expectation.
public struct ComScoreEventExpectation {
    let name: String
    let evaluate: (ComScoreLabels) -> Void

    /// Play.
    public static func play(evaluate: @escaping (ComScoreLabels) -> Void) -> Self {
        .init(name: "play", evaluate: evaluate)
    }

    /// Pause.
    public static func pause(evaluate: @escaping (ComScoreLabels) -> Void) -> Self {
        .init(name: "pause", evaluate: evaluate)
    }

    /// End.
    public static func end(evaluate: @escaping (ComScoreLabels) -> Void) -> Self {
        .init(name: "end", evaluate: evaluate)
    }
}

struct ComScoreEvent {
    let name: String
    let labels: ComScoreLabels

    init?(from dictionary: [String: String]) {
        guard let name = dictionary["ns_st_ev"] else { return nil }
        self.name = name
        self.labels = ComScoreLabels(dictionary: dictionary)
    }
}

func match(event: ComScoreEvent, with expectation: ComScoreEventExpectation) -> Bool {
    guard event.name == expectation.name else { return false }
    expectation.evaluate(event.labels)
    return true
}
