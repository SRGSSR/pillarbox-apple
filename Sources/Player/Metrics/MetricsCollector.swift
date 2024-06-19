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

    /// The available metrics history.
    ///
    /// Entries are sorted from the lowest to the most recent one.
    @Published public private(set) var metrics: [Metrics] = []

    /// Creates a metrics collector gathering metrics at the specified interval.
    ///
    /// - Parameter interval: The interval at which metrics must be gathered, according to progress of the current
    ///   time of the associated player timebase.
    ///
    /// Additional metrics will be collected when time jumps or when playback starts or stops.
    public init(interval: CMTime) {
        $player
            .removeDuplicates()
            .map { player -> AnyPublisher<Metrics?, Never> in
                guard let player else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return player.periodicMetricsPublisher(forInterval: interval)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .compactMap { $0 }
            .removeDuplicates()
            .scan([]) { $0 + [$1] }
            .receiveOnMainThread()
            .assign(to: &$metrics)
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
