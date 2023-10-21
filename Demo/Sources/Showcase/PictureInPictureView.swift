//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct PictureInPictureView: View {
    @ObservedObject var player: Player

    var body: some View {
        EmptyView()
    }
}

#Preview {
    PictureInPictureView(player: Player())
}
