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
            VideoView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
            Toggle("Supports PiP", isOn: $supportsPictureInPicture)
            Button(action: player.togglePlayPause) {
                Text("Play / pause")
            }
        }
        .overlay(alignment: .topTrailing) {
            PiPButton()
                .padding()
        }
        .overlay(alignment: .topLeading) {
            CloseButton()
                .padding(.horizontal)
                .frame(minHeight: 35)
        }
    }
}

struct TransitionAdvancedPiPView: View {
    let media: Media

    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()

    @State private var supportsPictureInPicture = true
    @State private var isPresented = false

    var body: some View {
        VStack(spacing: 20) {
            VideoView(player: model.player)
                .supportsPictureInPicture(supportsPictureInPicture)
                .accessibilityAddTraits(.isButton)
            Toggle("Supports PiP", isOn: $supportsPictureInPicture)

            HStack {
                Button(action: model.player.togglePlayPause) {
                    Text("Play / pause")
                }
                Spacer()
                Button(action: openModal) {
                    Text("Open modal")
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            PiPButton()
                .padding()
        }
        .onAppear(perform: play)
        .fullScreenCover(isPresented: $isPresented) {
            PresentedView(player: model.player)
        }
        .enabledForInAppPictureInPicture(persisting: model)
        .tracked(name: "transition-basic-pip")
    }

    private func play() {
        model.media = media
        model.play()
    }

    private func openModal() {
        isPresented.toggle()
    }
}

extension TransitionAdvancedPiPView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    TransitionAdvancedPiPView(media: URLMedia.onDemandVideoLocalHLS)
}
