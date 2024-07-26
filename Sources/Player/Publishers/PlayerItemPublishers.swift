//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

extension PlayerItem {
    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.Merge(assetLoadingMetricEventPublisher(), failureMetricEventPublisher())
            .eraseToAnyPublisher()
    }

    private func assetLoadingMetricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Empty().eraseToAnyPublisher()
    }

    private func failureMetricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Empty().eraseToAnyPublisher()
    }
}
