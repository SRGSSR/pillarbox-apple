//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

public extension MediaComposition {
    /// A description of a playable resource.
    struct Resource: Decodable {
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

        /// The resource URL.
        public let url: URL

        /// The streaming method.
        public let streamingMethod: StreamingMethod

        /// comScore analytics data.
        public var analyticsData: [String: String] {
            _analyticsData ?? [:]
        }

        /// Commanders Act analytics data.
        public var analyticsMetadata: [String: String] {
            _analyticsMetadata ?? [:]
        }

        /// The stream type.
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

        /// The token type.
        public let tokenType: TokenType

        /// The list of DRMs required to play the resource.
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
}
