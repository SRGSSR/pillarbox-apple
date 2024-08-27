//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

private struct AnyError: Error {}

extension MetricEvent {
    static let anyMetadata = Self(kind: .metadata(experience: .init(), service: .init()))
    static let anyAsset = Self(kind: .asset(experience: .init()))
    static let anyFailure = Self(kind: .failure(AnyError()))
    static let anyWarning = Self(kind: .warning(AnyError()))
}
