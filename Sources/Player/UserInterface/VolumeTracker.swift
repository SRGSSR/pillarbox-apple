//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import MediaPlayer

/// An observable object tracking system volume level.
///
/// A volume tracker is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// used to manage the system volume.
@available(iOS 16, *)
@available(tvOS, unavailable)
public final class VolumeTracker: ObservableObject {
    private static let volumeView = MPVolumeView()

    private static let volumeSlider: UISlider? = {
        volumeView.subviews.compactMap { $0 as? UISlider }.first
    }()

    private static let volumePublisher: AnyPublisher<Float, Never> = {
        AVAudioSession.sharedInstance().publisher(for: \.outputVolume).eraseToAnyPublisher()
    }()

    /// The current volume.
    ///
    /// Valid values range from 0 (muted) to 1 (maximum).
    @Published public var volume: Float = 0 {
        didSet {
            Self.volumeSlider?.value = volume.clamped(to: 0...1)
        }
    }

    /// Creates a volume tracker.
    public init() {
        Self.volumePublisher
            .assign(to: &$volume)
    }
}
