//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

extension MediaComposition {
    struct Resource: Decodable {
        enum CodingKeys: String, CodingKey {
            case _analyticsData = "analyticsData"
            case _analyticsMetadata = "analyticsMetadata"
            case _drms = "drmList"
            case isDvr = "dvr"
            case isLive = "live"
            case presentation
            case streamingMethod = "streaming"
            case tokenType
            case url
        }

        // swiftlint:disable:next discouraged_optional_collection
        private let _analyticsData: [String: String]?
        // swiftlint:disable:next discouraged_optional_collection
        private let _analyticsMetadata: [String: String]?
        // swiftlint:disable:next discouraged_optional_collection
        private let _drms: [DRM]?

        let isDvr: Bool
        let isLive: Bool
        let presentation: Presentation
        let streamingMethod: StreamingMethod
        let tokenType: TokenType
        let url: URL

        var analyticsData: [String: String] {
            _analyticsData ?? [:]
        }

        var analyticsMetadata: [String: String] {
            _analyticsMetadata ?? [:]
        }

        var drms: [DRM] {
            _drms ?? []
        }

        var streamType: StreamType {
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
    }
}
