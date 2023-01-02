//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

@MainActor
class PlaylistViewModel: ObservableObject {
    @Published var medias: [Media] {
        didSet {
            mutableMedias = medias
        }
    }
    var mutableMedias: [Media] = []
    let player = Player()

    init(medias: [Media] = []) {
        self.medias = medias
    }
}
