//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

private struct AnyError: Error {}

extension MetricEvent {
    static let anyAssetLoading = Self(kind: .assetLoading(.init()))
    static let anyResourceLoading = Self(kind: .resourceLoading(.init()))
    static let anyFailure = Self(kind: .failure(AnyError()))
    static let anyWarning = Self(kind: .warning(AnyError()))
}
