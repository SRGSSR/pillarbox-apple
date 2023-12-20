//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct MultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var model = MultiViewModel.persisted ?? MultiViewModel()

    var body: some View {
        VStack(spacing: 10) {
            Group {
                playerView(player: model.player1, position: .top)
                playerView(player: model.player2, position: .bottom)
            }
            .background(.black)
        }
        .persistDuringPictureInPicture(model)
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
        .onAppear {
            model.media1 = media1
            model.media2 = media2
            model.play()
        }
        .tracked(name: "multi")
    }

    @ViewBuilder
    private func playerView(player: Player, position: PlayerPosition) -> some View {
        SingleView(player: player, isPictureInPictureSupported: model.activePosition == position)
            .onTapGesture {
                model.activePosition = position
            }
            .accessibilityAddTraits(.isButton)
            .saturation(model.activePosition == position ? 1 : 0)
    }
}

extension MultiView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    MultiView(
        media1: Media(from: URNTemplate.onDemandHorizontalVideo),
        media2: Media(from: URNTemplate.onDemandVideo)
    )
}
