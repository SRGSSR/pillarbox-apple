//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

enum PlayerPosition {
    case top
    case bottom
}

final class MultiViewModel: ObservableObject {
    @Published var media1: Media? {
        didSet {
            guard media1 != oldValue else { return }
            Self.update(player: player1, with: media1)
        }
    }

    @Published var media2: Media? {
        didSet {
            guard media2 != oldValue else { return }
            Self.update(player: player2, with: media2)
        }
    }

    @Published var activePosition: PlayerPosition = .top {
        didSet {
            switch activePosition {
            case .top:
                Self.make(activePlayer: topPlayer, inactivePlayer: bottomPlayer)
            case .bottom:
                Self.make(activePlayer: bottomPlayer, inactivePlayer: topPlayer)
            }
        }
    }

    var topPlayer: Player {
        isSwapped ? player2 : player1
    }

    var bottomPlayer: Player {
        isSwapped ? player1 : player2
    }

    private var activePlayer: Player {
        switch activePosition {
        case .top:
            return topPlayer
        case .bottom:
            return bottomPlayer
        }
    }

    private var inactivePlayer: Player {
        switch activePosition {
        case .top:
            return bottomPlayer
        case .bottom:
            return topPlayer
        }
    }

    @Published private var isSwapped = false {
        didSet {
            switch activePosition {
            case .top:
                activePosition = .bottom
            case .bottom:
                activePosition = .top
            }
        }
    }

    let player1 = Player(configuration: .standard)
    let player2 = Player(configuration: .standard)

    init() {
        Self.make(activePlayer: player1, inactivePlayer: player2)
    }

    private static func update(player: Player, with media: Media?) {
        if let playerItem = media?.item() {
            player.items = [playerItem]
        }
        else {
            player.removeAllItems()
        }
    }

    private static func make(activePlayer: Player, inactivePlayer: Player) {
        activePlayer.becomeActive()
        activePlayer.isTrackingEnabled = true
        activePlayer.isMuted = false

        inactivePlayer.isTrackingEnabled = false
        inactivePlayer.isMuted = true
    }

    func play() {
        player1.play()
        player2.play()
    }

    func swap() {
        isSwapped.toggle()
    }
}

extension MultiViewModel: PictureInPicturePersistable {
    func pictureInPictureDidStart() {
        inactivePlayer.pause()
    }
}
