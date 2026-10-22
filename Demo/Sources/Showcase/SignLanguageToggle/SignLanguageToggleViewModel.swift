//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

final class SignLanguageToggleViewModel: ObservableObject {
    private static let unsignedItem = PlayerItem.urn("urn:rts:video:cc02e588-f0d2-3c28-bc58-c6f338b06785")
    private static let signedItem = PlayerItem.urn("urn:rts:video:0fabbd87-102e-3c48-8bb9-7730679f2f96")

    let player = Player(item: unsignedItem, configuration: .standard)

    @Published var isSigned = false {
        didSet {
            let item = isSigned ? Self.signedItem : Self.unsignedItem
            let position = at(player.time())
            player.items = [item]
            player.resume(position, in: item)
        }
    }

    func play() {
        player.becomeActive()
        player.play()
    }
}
