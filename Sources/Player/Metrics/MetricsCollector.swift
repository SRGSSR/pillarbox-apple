//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import CoreMedia
import SwiftUI

/// An observable object collecting player metrics.
///
/// A metrics collector is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// used to collect metrics associated with a ``Player`` at a regular interval.
///
/// ## Usage
///
/// A metrics collector is used as follows:
///
/// 1. Instantiate a `MetricsCollector` in your view hierarchy, setting up the refresh interval you need.
/// 2. Bind the progress tracker to a ``Player`` instance by applying the ``SwiftUI/View/bind(_:to:)`` modifier.
/// 3. Current metrics can be retrieved from the ``metrics`` property and displayed in any way you want, e.g. in a
///    textual form or with charts.
public final class MetricsCollector: ObservableObject {
    /// The player to attach.
    ///
    /// Use `View.bind(_:to:)` in SwiftUI code.
    @Published public var player: Player?

    /// The available metrics history for the item being played, if any.
    ///
    /// Entries are sorted from the lowest to the most recent one.
    @Published public private(set) var metrics: [Metrics] = []

    /// The metric event history for the item being played, if any.
    @Published public private(set) var metricEvents: [MetricEvent] = []

    /// Creates a metrics collector gathering metrics at the specified interval.
    ///
    /// - Parameter interval: The interval at which metrics must be gathered, according to progress of the current
    ///   time of the associated player timebase.
    ///
    /// Additional metrics will be collected when time jumps or when playback starts or stops.
    public init(interval: CMTime) {
        configureMetricsPublisher(interval: interval)
        configureMetricEventsPublisher()
    }

    private func configureMetricsPublisher(interval: CMTime) {
        $player
            .removeDuplicates()
            .map { player -> AnyPublisher<[Metrics], Never> in
                guard let player else {
                    return Just([]).eraseToAnyPublisher()
                }
                return player.periodicMetricsPublisher(forInterval: interval)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$metrics)
    }

    private func configureMetricEventsPublisher() {
        $player
            .removeDuplicates()
            .map { player -> AnyPublisher<[MetricEvent], Never> in
                guard let player else {
                    return Just([]).eraseToAnyPublisher()
                }
                return player.metricEventsPublisher
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$metricEvents)
    }
}

public extension View {
    /// Binds a metrics collector to a player.
    ///
    /// - Parameters:
    ///   - metricsCollector: The metrics collector to bind.
    ///   - player: The player to observe.
    func bind(_ metricsCollector: MetricsCollector, to player: Player?) -> some View {
        onAppear {
            metricsCollector.player = player
        }
        .onChange(of: player) { newValue in
            metricsCollector.player = newValue
        }
    }
}
