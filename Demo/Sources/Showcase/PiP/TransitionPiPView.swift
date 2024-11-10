//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

private struct PresentedView: View {
    @ObservedObject var player: Player

    @State private var supportsPictureInPicture = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            PlaybackView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
            Toggle("Picture in Picture", isOn: $supportsPictureInPicture)
                .padding(.horizontal)
        }
    }
}

struct TransitionPiPView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    @State private var supportsPictureInPicture = true
    @State private var isPresented = false

    var body: some View {
        VStack {
            PlaybackView(player: model.player)
                .supportsPictureInPicture(supportsPictureInPicture && !isPresented)

            VStack(spacing: 20) {
                Toggle("Picture in Picture", isOn: $supportsPictureInPicture)
                Button(action: openModal) {
                    Text("Open modal")
                }
            }
            .padding(.horizontal)
        }
        .onAppear(perform: play)
        .fullScreenCover(isPresented: $isPresented) {
            PresentedView(player: model.player)
        }
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "transition-pip")
    }

    private func play() {
        model.media = media
        model.play()
    }

    private func openModal() {
        isPresented.toggle()
    }
}

extension TransitionPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TransitionPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
