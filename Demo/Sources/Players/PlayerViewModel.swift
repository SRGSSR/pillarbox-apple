//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

final class PlayerViewModel: ObservableObject {
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

    @Published var layout: PlaybackView.Layout = .minimized

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

extension PlayerViewModel: PictureInPicturePersistable {
    func pictureInPictureWillStart() {
        print("--> will start")
    }

    func pictureInPictureDidStart() {
        print("--> did start")
    }

    func pictureInPictureWillStop() {
        print("--> will stop")
    }

    func pictureInPictureDidStop() {
        print("--> did stop")
    }

    func pictureInPictureDidClose() {
        print("--> did close")
    }
}
