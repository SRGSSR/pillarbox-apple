//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

final class PlayerViewModel: ObservableObject, PictureInPicturePersistable {
    @Published var media: Media? {
        didSet {
            guard media != oldValue else { return }
            if let item = media?.item() {
                player.items = [item]
            }
            else {
                player.removeAllItems()
            }
        }
    }

#if os(iOS)
    @Published var layout: PlaybackView.Layout = .minimized
#endif

    let player = Player(configuration: .standard)
    private var cancellables = Set<AnyCancellable>()

    init() {
        configureLimitsPublisher()
    }

    func play() {
        player.becomeActive()
        player.play()
    }

    private func configureLimitsPublisher() {
        UserDefaults.standard.limitsPublisher()
            .assign(to: \.limits, on: player)
            .store(in: &cancellables)
    }
}
