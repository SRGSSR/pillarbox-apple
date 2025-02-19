//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

extension MetricPayload: CustomDebugStringConvertible {
    // swiftlint:disable:next missing_docs
    public var debugDescription: String {
        eventName.rawValue
    }
}
