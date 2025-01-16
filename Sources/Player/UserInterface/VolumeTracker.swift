//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import MediaPlayer

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

    @Published public var volume: Float = 0 {
        didSet {
            Self.volumeSlider?.value = volume
        }
    }

    public init() {
        Self.volumePublisher
            .assign(to: &$volume)
    }
}
