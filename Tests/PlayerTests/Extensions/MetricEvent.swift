//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private struct AnyError: Error {}

extension MetricEvent.Kind {
    static let anyAssetLoading = Self.assetLoading(.init())
    static let anyResourceLoading = Self.resourceLoading(.init())
    static let anyFailure = Self.failure(AnyError())
    static let anyWarning = Self.warning(AnyError())
    static let anyResumeAfterStall = Self.resumeAfterStall(.init())
}
