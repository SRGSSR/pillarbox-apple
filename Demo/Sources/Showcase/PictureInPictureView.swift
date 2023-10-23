//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SwiftUI

struct PictureInPictureView: View {
    @ObservedObject var player: Player
    let pictureInPicture: PictureInPicture
    @Environment(\.dismiss) var dismiss: DismissAction
    @EnvironmentObject var router: Router

    var body: some View {
        VStack(spacing: 0) {
            playbackView()
        }
        .background(.black)
    }
}

extension PictureInPictureView {
    @ViewBuilder
    private func playbackView() -> some View {
        ZStack {
            // swiftlint:disable:next trailing_closure
            VideoView(player: player, pictureInPicture: pictureInPicture)
                .onAppear {
                    if player.items.isEmpty {
                        play()
                    }
                }
                .onPictureInPictureRestore(pictureInPicture) { completion in
                    router.present(.pip)
                    DispatchQueue.main.async {
                        completion(true)
                    }
                }
                .onPictureInPictureDidStop(pictureInPicture, didStop: {
                    player.removeAllItems()
                })
            HStack {
                playbackButton()
                pictureInPictureButton(pictureInPicture: pictureInPicture)
            }
        }
    }

    @ViewBuilder
    private func playbackButton() -> some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.playbackState == .playing ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
        }
    }

    @ViewBuilder
    private func pictureInPictureButton(pictureInPicture: PictureInPicture) -> some View {
        Button {
            dismiss()
            pictureInPicture.start()
        } label: {
            Image(systemName: "pip")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .tint(.white)
                .shadow(radius: 5)
        }
    }

    private func play() {
        player.append(.youTube(videoId: "ApM_KEr1ktQ"))
        player.play()
    }
}

#Preview {
    PictureInPictureView(player: Player(), pictureInPicture: PictureInPicture())
}
