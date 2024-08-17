//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

private struct AnyError: Error {}

extension MetricEvent {
    static let anyMetadataReady = Self(kind: .metadataReady(.init()))
    static let anyAssetReady = Self(kind: .assetReady(.init()))
    static let anyFailure = Self(kind: .failure(AnyError()))
    static let anyWarning = Self(kind: .warning(AnyError()))
}
