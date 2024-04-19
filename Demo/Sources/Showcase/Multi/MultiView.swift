//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

// Behavior: h-exp, v-exp
struct MultiView: View {
    let media1: Media
    let media2: Media

    @StateObject private var model = MultiViewModel.persisted ?? MultiViewModel()

    var body: some View {
        VStack(spacing: 10) {
            playerView(player: model.topPlayer, position: .top)
            swapButton()
            playerView(player: model.bottomPlayer, position: .bottom)
        }
        .background(.black)
        .enabledForInAppPictureInPicture(persisting: model)
        .overlay(alignment: .topLeading) {
            HStack {
                CloseButton()
                routePickerView()
                PiPButton()
            }
            .padding(.horizontal)
            .frame(minHeight: 35)
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
        SingleView(player: player)
            .monoscopic(model.isMonoscopic(at: position))
            .supportsPictureInPicture(model.activePosition == position)
            .onTapGesture {
                model.activePosition = position
            }
            .accessibilityAddTraits(.isButton)
            .saturation(model.activePosition == position ? 1 : 0)
    }

    @ViewBuilder
    private func swapButton() -> some View {
        Button(action: model.swap) {
            Label("Swap", systemImage: "rectangle.2.swap")
        }
    }

    @ViewBuilder
    private func routePickerView() -> some View {
        RoutePickerView(prioritizesVideoDevices: true)
            .tint(.white)
            .frame(width: 45, height: 45)
    }
}

extension MultiView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    MultiView(
        media1: Media(from: URNTemplate.onDemandHorizontalVideo),
        media2: Media(from: URNTemplate.onDemandVideo)
    )
}
