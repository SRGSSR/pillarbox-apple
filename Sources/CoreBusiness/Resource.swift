//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

public struct Resource: Decodable {
    enum CodingKeys: String, CodingKey {
        case _analyticsData = "analyticsData"
        case _analyticsMetadata = "analyticsMetadata"
        case _drms = "drmList"
        case isDvr = "dvr"
        case isLive = "live"
        case streamingMethod = "streaming"
        case tokenType
        case url
    }

    public let url: URL
    public let streamingMethod: StreamingMethod

    public var analyticsData: [String: String] {
        _analyticsData ?? [:]
    }

    public var analyticsMetadata: [String: String] {
        _analyticsMetadata ?? [:]
    }

    public var streamType: StreamType {
        if isDvr {
            return .dvr
        }
        else if isLive {
            return .live
        }
        else {
            return .onDemand
        }
    }

    public let tokenType: TokenType

    public var drms: [DRM] {
        _drms ?? []
    }

    private let isDvr: Bool
    private let isLive: Bool
    // swiftlint:disable:next discouraged_optional_collection
    private let _drms: [DRM]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsData: [String: String]?
    // swiftlint:disable:next discouraged_optional_collection
    private let _analyticsMetadata: [String: String]?
}
